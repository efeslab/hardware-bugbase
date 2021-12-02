# D3 - Buffer Overflow - Optimus

A version of BBB that's close to the bug: https://github.com/efeslab/optimus-intel-fpga-bbb/tree/d639624652e4cf1173677a3e8bb7fc16f53ae433

The author of Optimus reports this bug; however, it was fixed before committed. The memory channel of Optimus contains a small buffer to temporally store a few packets when 1) the memory channel is "almost full" and 2) 8 packets (the max number of packets that can be sent when the channel is "almost full") were already sent after the "almost full" signal is received. In the buggy version, the buffer is one entry smaller than its expected size, causing an overflow in a special scenario.

More details of the bug can be found in the comments of the following synthetic code.

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

	// `balance` means how many packets has been sent after almful is set.
	// In an ideal world, `balance` should be at most 8. However, because the almfull signal takes several cycles to
  // propagate to weird_module, the actual allowance is less than 8.
	logic [4:0] balance;
	logic [2:0] buffer_cnt, buffer_cnt2;
  logic [63:0] buffer [BUF_SIZE-1:0];

	always_ff @(posedge clk) begin
		if (~almfull)
			balance <= 0;
		else if (o_valid)
			balance <= balance + 1;
		else
			balance <= balance;

		// Here, balance >= FN indicates you should start buffering requests when you already sent FN packets after almfull.
		// The developer incorrectly calculates the value of FN, causing the size of the buffer being smaller than the expected
    // size. As a result, the buffer would overflow in some extreme scenarios.
    if (balance >= FN && valid) begin
      // When the allowance is reached (i.e., 8 packets already sent our after almfull), the circuit puts data into the buffer.
			buffer[buffer_cnt] <= data;
			buffer_cnt <= buffer_cnt + 1;
			buffer_cnt2 <= buffer_cnt + 1;
			o_valid <= 0;
		end
		else if (~almfull && buffer_cnt != 0) begin
			o_data <= buffer[buffer_cnt2 - buffer_cnt];
			o_valid <= 1;
			buffer_cnt <= buffer_cnt - 1;
		end
		else begin
			o_data <= data;
			o_valid <= valid;
		end
	end
endmodule
```
