### Source
BBB: https://github.com/efeslab/optimus-intel-fpga-bbb/tree/d639624652e4cf1173677a3e8bb7fc16f53ae433

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
	// It takes 11 cycles to respond to the almfull signals.
	// send out most N packets after almfull is set
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

		// Here, balance >= F(N) indicates you should start buffering requests when you already sent F(N) (some function of N, depends on reading the waveform).
		// The circuit is supposed to send out at most 7 packets after almfull is asserted.
		// However, there may be at more extra packets that needs to be stored than the size of the buffer, which causes buffer overflow.
		// The smaller the buffer size, the sooner the overflow will happen. You can completely avoid overflow by using a big buffer.
		// But here we assume the buffer is small enough to cause rare overflow at runtime (on FPGA).
		if (balance >= F(N) && valid) begin
			// I have to buffer since the balance is reaching the limit
			buffer[buffer_cnt] <= data;
			buffer_cnt <= buffer_cnt + 1;
			buffer_cnt2 <= buffer_cnt + 1;
			o_valid <= 0;
		end
		else if (~almfull && buffer_cnt != 0) begin
			// flush the buffer when I do not have to enque new data
			o_data <= buffer[buffer_cnt2 - buffer_cnt];
			o_valid <= 1;
			buffer_cnt <= buffer_cnt - 1;
		end
		else begin
			// When valid is true (i.e., weird_inst has a valid output) and there's anything in the buffer, the
			// output of weird_inst will be ignored.
			// This is the root cause
			o_data <= data;
			o_valid <= valid;
		end
	end
	// the following invariant should hold:
	// count(o_valid@[cycleN] == 1) + buffer_cnt@[cycleN] == count(valid@[cycleN-1] == 1)
endmodule
```