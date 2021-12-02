# C2 - Producer-Consumer Mismatch - Optimus

BBB Commit: https://github.com/efeslab/optimus-intel-fpga-bbb/tree/d639624652e4cf1173677a3e8bb7fc16f53ae433

The hardware part of Optimus hypervisor is connected to 4 grayscale accelerators. The bug is in the memory channel of the hypervisor, and is not related to the accelerator. However, when the producer-consumer mismatch occurs, some memory request packets issued by the accelerator would lost, causing the accelerator to stuck.

This bug is never "fixed" in Optimus. The authors noticed the bug and cannot find the root cause. As a result, they redesigned the memory channel and reimplemented it to work around this bug.

Details of the bug is explained in the comments of the following synthetic code.

### Synthetic Code
```verilog
module weird_module(
	input logic clk,
	input logic almfull,
	output logic [63:0] data,
	output logic valid
);

	logic [63:0] value;
	initial value = 0;

	logic almfull_buf[9:0];
	integer i;
	always_ff @(posedge clk) begin
		for (i = 1; i < 10; i++) begin
			almfull_buf[i] <= almfull_buf[i-1];
		end
		almfull_buf[0] <= almfull;
	end

	always_ff @(posedge clk) begin
		if (~almfull_buf[9])
			value <= value + 1;
	end

	always_ff @(posedge clk) begin
		if (~almfull_buf[9]) begin
			data <= value;
			valid <= 1;
		end
		else begin
			valid <= 0;
		end
	end
endmodule

module test (
	input logic clk,

	// output channel, when o_almfull is asserted, no more than 8 packet can be issued
	output logic [63:0] o_data,
	output logic o_valid,
	input logic o_almfull
);

	logic [63:0] data;
	logic valid;
	logic almfull;
	initial almfull = 0;
	always_ff @(posedge clk) begin
		almfull <= o_almfull;
	end

	// This module may or may not generate data output at each cycle.
	// It takes 11 cycles to respond to the almfull signals and may send out at most N packets after the almfull bit is set.
  weird_module weird_inst(
		.clk(clk),
		.almfull(almfull),
		.data(data),
		.valid(valid)
	);

	// balance means how many packets has been sent after almful is set.
	// assert(balance <= 8)
	logic [4:0] balance;
	logic [2:0] buffer_cnt, buffer_cnt2;
	logic [63:0] buffer [4:0];

	always_ff @(posedge clk) begin
		if (~almfull)
			balance <= 0;
		else if (o_valid)
			balance <= balance + 1;
		else
			balance <= balance;
    
    if (balance >= FN && valid) begin
			// The packet needs to be buffered since the balance is reaching the limit.
      // FN is a carefully calculated so that the buffer won't overflow.
			buffer[buffer_cnt] <= data;
			buffer_cnt <= buffer_cnt + 1;
			buffer_cnt2 <= buffer_cnt + 1;
			o_valid <= 0;
		end
		else if (~almfull && buffer_cnt != 0) begin
			// When there's something in the buffer and the channel is available, the circuit always output the
      // packets stored in the buffer first.
			o_data <= buffer[buffer_cnt2 - buffer_cnt];
			o_valid <= 1;
			buffer_cnt <= buffer_cnt - 1;
		end
		else begin
      // When valid is true (i.e., weird_inst has a valid output) and there's something in the buffer, the
			// output of weird_inst will be ignored.
			// This block is the root cause of this bug.
			o_data <= data;
			o_valid <= valid;
		end
	end
endmodule
```
