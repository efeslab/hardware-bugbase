# Bugs with code snippets

The simulation of manual debugging can be found [here](manual_debug_log).

## 1. Uncleared Valid Bit (SHA512)

### Code

```verilog
typedef enum {
  DO_IDLE,
  DO_WORK,
  DO_RESULT
 } state_t;
state_t state;
 
initial state = DO_IDLE;
always_ff @(posedge clk) begin
  case (state)
    DO_IDLE: if (start) state <= DO_WORK;
    DO_WORK: if (finish) state <= DO_RESULT;
    DO_RESULT: state <= DO_IDLE;
  endcase
end
 
always_ff @(posedge clk) begin
  if (reset) begin
    valid <= 0;
    data <= 0;
  end
  else begin
    case (state)
      DO_WORK:
        if (result_valid) begin
          valid <= 1; data <= get_result();
        end;
      DO_RESULT:
        valid <= 1;
        data <= get_result_summary();
        // The valid bit will still be 1 in the next cycle, because DO_IDLE does not clear it.
    endcase
  end
end
```

### Solution

- 

## 2. Assign 64bit to 42bit (SHA512)

### Code

``` verilog
logic [41:0] left;
logic [63:0] right;
assign left = 42'(right) >> 6;
```

### Solution

- 

## 3. Use of outdated valid bit in an FSM design (SSSP)

**i.e., "do vertex" one more time**

### Code

```verilog
module test (
    input logic clk,
    input logic valid
);

    typedef enum {
        DO_VERTEX,
        DO_EDGE
    } state_t;
    state_t state;
    initial state = DO_VERTEX;

    logic [15:0] count;
    initial count = 0;

    always_ff @(posedge clk) begin
        count <= count + valid;
    end

    always_ff @(posedge clk) begin
        if (count == 2) begin
            state <= DO_EDGE;
        end
    end

    always_ff @(posedge clk) begin
        // The following code may "do vertex" three times, if the second and third 'valid' come in adjacent cycles.
        // Delaying the 'valid' bit for a cycle can fix this problem.
        if (valid) begin
            case (state)
                DO_VERTEX: $display("do vertex!");
                DO_EDGE: $display("do edge!");
            endcase
        end
    end
endmodule
```

### Solution

- 

## 4. Buffer overflow (RSD)

### Code

```verilog
module test (
        input logic clk,

        // input channel, i_request and i_valid are asynchronize
        input logic [63:0] i_data,
        input logic i_valid,
        output logic i_request,

        // output channel, when o_almfull is asserted, no more than 8 packet can be issued
        output logic [63:0] o_data,
        output logic o_valid,
        input logic o_almfull
);

        always_ff @(posedge clk) begin
                i_request <= !o_almfull;
        end

        logic weird_out;
        logic weird_out_valid;

        // a weird module, take 64-bit input and generate 1-bit output
        weird_module weird_inst(
                .clk(clk),
                .i_data(i_data),
                .i_valid(i_valid),
                .o_data(weird_out), // this is an 1 bit output
                .o_valid(weird_out_valid)
        );

        logic [63:0] buffer;
        logic [5:0] ptr;
        initial buffer = 64'h0;
        initial ptr = 6'h0;

        // The buffer may overflow, if o_almfull is always true
        always_ff @(posedge clk) begin
                if (weird_out_valid) begin
                        buffer[63 - ptr] <= weird_out;
                        ptr <= ptr + 1;
                end
        end

        typedef enum {
                DO_WAIT,
                DO_OUT
        } state_t;
        state_t state;
        initial state = DO_WAIT;

        always_ff @(posedge clk) begin
                case(state)
                        DO_WAIT: if (weird_out_valid && wr_ptr == '1) state <= DO_OUT;
                        DO_OUT: if (!o_almfull) state <= DO_WAIT;
                endcase
        end

        always_ff @(posedge clk) begin
                case(state)
                        DO_WAIT: o_valid <= 0;
                        DO_OUT:
                                if (!o_almfull) begin
                                        o_valid <= 1;
                                        o_data <= buffer;
                                end
                                else begin
                                        o_valid <= 0;
                                end
                endcase
        end
endmodule
```

### Solution

- 

## 5. Buffer overflow / signal conflict (Optimus Sidebuf)

### Code

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
	weird_module weird_inst(
		.clk(clk),
		.almfull(almfull),
		.data(data),
		.valid(valid)
	);

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

		// Here, balance >= 5 indicates that the circuit will send out at most 7 packets after almfull is asserted.
		// However, there may be at most 6 extra packets that needs to be stored in the buffer, whose size is 5. 
		// As a result, this buffer may be overflowed.
		if (balance >= 5 && valid) begin
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
			// When valid is true (i.e., weird_inst has a valid output) and there's anything in the buffer, the
			// output of weird_inst will be ignored.
			o_data <= data;
			o_valid <= valid;
		end
	end

endmodule
```

### Solution

- 

## 6. Buffer overflow (Grayscale)

### Code

```verilog
module test (
        input logic clk,

        // read channel
        input logic rdch_almfull,
        output logic rdreq_valid,
        output t_rdreq rdreq,
        input logic rdrsp_valid,
        input t_rdrsp rdrsp,

        // write channel
        input logic wrch_almfull,
        output logic wrreq_valid,
        output t_wrreq wrreq,
        input logic wrrsp_valid,
        input t_wrrsp wrrsp
);

        t_wrreq enq_data;
        logic enq_data_valid;

        weird_module weird_inst(
                .clk(clk),
                .data_in(rdrsp),
                .data_in_valid(rdrsp_valid),
                .data_out(enq_data),
                .data_out_valid(enq_data_valid)
        );

        logic deq_en;
        initial deq_en = 0;

        fifo fifo_inst(
                .enq_data(enq_data),
                .enq_en(enq_data_valid),
                .deq_data(rdreq),
                .deq_en(deq_en)
        );

        always_ff @(posedge clk) begin
                if (~rdch_almfull) begin
                        rdreq <= get_next_rdreq();
                        rdreq_valid <= 1;
                end
                else begin
                        rdreq_valid <= 0;
                end
        end

        // If the write channel is full, and we keep sending read packets, we will eventially overflow the fifo.
        // The fix is also stop reading while the write buffer is almfull.
        always_ff @(posedge clk) begin
                if (~wrch_almfull) begin
                        wrreq <= enq_data;
                        wrreq_valid <= 1;
                end
                else begin
                        wrreq_valid <= 0;
                end
        end

endmodule
```

### Solution

- 

## 7. Path merging (SDSPI)

### Code

```verilog
module test(
        input logic clk,

        input logic rd_req,
        output logic rd_ack,
        output logic [63:0] rd_data
);

        logic [63:0] fifo_mem[63:0];
        logic [63:0] fifo_reg;
        logic [5:0] fifo_addr;

        initial fifo_addr = 0; // in real world, there's a complex protocol to reset it
        always @(posedge clk) begin
                // fifo_addr takes two cycles to be updated, while the latency of rd_ack is one cycle.
                // As a result, the first two reads will be the same.
                if (rd_req)
                        fifo_addr <= fifo_addr + 1;
        end

        always @(posedge clk) begin
                fifo_reg <= fifo_mem[fifo_addr];
        end

        always @(posedge clk) begin
                if (rd_req) begin
                        rd_ack <= 1;
                        rd_data <= fifo_reg;
                end
                else begin
                        rd_ack <= 0;
                end
        end
endmodule
```

### Solution

- 

## 8. Dead lock (SDSPI)

### Code

```verilog
module test(
        input logic clk,
        output logic o_sclk,

        input logic i_speed // i_speed != 0
);

        logic startup_hold;
        initial startup_hold = 1;

        logic [6:0] r_clk_counter;
        logic r_z_counter;
        initial r_clk_counter = 0;
        initial r_z_counter = 1;

        always_ff @(posedge clk) begin
                // During the startup of the circuit, startup_hold is always true. As a result, this block always falls into
                // the first if-statement, which prevents r_z_counter to be updated, which prevents o_sclk to be updated, which
                // prevents startup_hold to be updated.
                if (startup_hold) begin
                        r_clk_counter <= i_speed;
                        r_z_counter <= (i_speed == 0);
                end
                else if (!r_z_counter) begin
                        r_clk_counter <= (r_clk_counter - 1);
                        r_z_counter <= (r_clk_counter == 1);
                end
                else begin
                        r_clk_counter <= i_speed;
                        r_z_counter <= 0;
                end
        end

        initial o_sclk = 1;
        always_ff @(posedge clk) begin
                if (r_z_counter)
                        o_sclk <= !o_sclk;
        end

        logic [7:0] startup_counter;
        initial startup_counter = 64;
        always_ff @(posedge clk) begin
                if (startup_hold && !past_sclk && o_sclk) begin
                        if (|startup_counter)
                                startup_counter <= startup_counter - 1;
                        startup_hold <= (startup_counter > 0);
                end
        end
end
```

## 9. Endian? (SDSPI) (What's the name?)

### Code

```verilog
module test(
        input logic clk,

        input logic [3:0] addr;

        input logic rd_req,
        output logic rd_rsp,
        output logic [31:0] rd_data,

        input wr_req,
        input logic [31:0] wr_data
);

        logic [7:0] fifo_mem_0[15:0], fifo_mem_1[15:0], fifo_mem_2[15:0], fifo_mem_3[15:0];
        logic [31:0] fifo_reg;

        always @(posedge clk) begin
                // The folloing lines indicate that fifo_mem_0[addr] will be the highest bits of fifo_reg.
                // As a result, fifo_mem_0 is the highest bits during read but the lowest bits during write.
                fifo_reg <= {
                        fifo_mem_0[addr],
                        fifo_mem_1[addr],
                        fifo_mem_2[addr],
                        fifo_mem_3[addr]
                };

                if (rd_req) begin
                        rd_rsp <= 1;
                        rd_data <= fifo_reg;
                end
                else begin
                        rd_rsp <= 0;
                end
        end

        always @(posedge clk) begin
                if (wr_req) begin
                        fifo_mem_0[addr] <= wr_data[7:0];
                        fifo_mem_1[addr] <= wr_data[15:8];
                        fifo_mem_2[addr] <= wr_data[23:16];
                        fifo_mem_3[addr] <= wr_data[31:24];
                end
        end
endmodule
```

### Solution

- 

# Bugs without concrete code snippets

## 10. AXI missing corner cases x3



## 11. Bit drop influences precision (FFT)

```verilog
wire    [(OWID-1):0]    truncated_value, rounded_up;
wire                    last_valid_bit, first_lost_bit;

assign  truncated_value=i_val[(IWID-1-SHIFT):(IWID-SHIFT-OWID)];
assign  rounded_up=truncated_value + {{(OWID-1){1'b0}}, 1'b1 };
assign  last_valid_bit = truncated_value[0];
assign  first_lost_bit = i_val[(IWID-SHIFT-OWID-1)];

wire    [(IWID-SHIFT-OWID-2):0] other_lost_bits;
assign  other_lost_bits = i_val[(IWID-SHIFT-OWID-2):0];

always @(posedge i_clk)
    if (i_ce)
        begin
            if (!first_lost_bit) // Round down / truncate
                o_val <= truncated_value;
            else if (|other_lost_bits) // Round up to
                o_val <= rounded_up; // closest value
            else if (last_valid_bit) // Round up to
                o_val <= rounded_up; // nearest even
            else    // else round down to nearest even
                o_val <= truncated_value;
        end

```

## 12. Misindexing (FADD by Brendan)



## 13. CV32-div-too-long

1. In this CPU, the fetcher assumes that the branch is not taken and fetches instructions right after the branch. Branch decision are made in the EX stage, and when a branch is taken, the pipeline needs to be flushed.
2. In a very original implementation in 2018, the circuit propagates the instruction (that locates after a taken-branch) from ID to EX and disable register write to prevent side effect.
3. The implementation in 2 is buggy, because if the instruction right after a taken-branch is a multi-cycle instruction, the EX stage will take a long time to finish, and it will backpressure the ID stage to prevent new instructions from being propagated.
4. In a fix in 2018, when a branch is taken in EX (which means the instruction in ID is useless), the circuit will propagate a fake single cycle instruction (like a pipeline nop/bubble) to EX. The result of this fix is the code we say in the left side at the bottom of the page.
5. However, for some reason (e.g., a weird combination of operands), the fix in 4 cannot handle all cases of "multi-cycle instruction followed by a taken branch" correctly (which causes Issue 434). Therefore, the author commits a more fundamental fix (the commit mentioned above). In this fix, when the decoder finds deassert_we_i is 1, it will set afu_en to 0. (In the previous code, alu_en is decided by the instruction being decoded, regardless of deassert_we_i.) As a result, the control flow won't enter the if case in line 1542, and the DIV instruction won't be propagated to EX.


## 14. Failed to Reset (Vedrilog Axis)


### Code
```verilog
module axis_frame_len #
(
    // Width of AXI stream interfaces in bits
    parameter DATA_WIDTH = 64,
    // Propagate tkeep signal
    // If disabled, tkeep assumed to be 1'b1
    parameter KEEP_ENABLE = (DATA_WIDTH>8),
    // tkeep signal width (words per cycle)
    parameter KEEP_WIDTH = (DATA_WIDTH/8),
    // Width of length counter
    parameter LEN_WIDTH = 16
)
(
    input  wire                   clk,
    input  wire                   rst,

    /*
     * AXI monitor
     */
    input  wire [KEEP_WIDTH-1:0]  monitor_axis_tkeep,
    input  wire                   monitor_axis_tvalid,
    input  wire                   monitor_axis_tready,
    input  wire                   monitor_axis_tlast,

    /*
     * Status
     */
    output wire [LEN_WIDTH-1:0]   frame_len,
    output wire                   frame_len_valid
);

reg [LEN_WIDTH-1:0] frame_len_reg = 0, frame_len_next;
reg frame_len_valid_reg = 1'b0, frame_len_valid_next;
reg frame_reg = 1'b0, frame_next;

assign frame_len = frame_len_reg;
assign frame_len_valid = frame_len_valid_reg;

integer offset, i, bit_cnt;

always @* begin
    frame_len_next = frame_len_reg;
    frame_len_valid_next = 1'b0;
    frame_next = frame_reg;

    if (monitor_axis_tready && monitor_axis_tvalid) begin
        // valid transfer cycle

        if (monitor_axis_tlast) begin
            // end of frame
            frame_len_valid_next = 1'b1;
            frame_next = 1'b0;
        end else if (!frame_reg) begin
        // The bug occurs when two back-to-back data transfer packets come (with tlast set on every transfer), then this "else if" block won't be accessed, and the frame_len_next can't be reset correctly.

            frame_len_next = 0;
            frame_next = 1'b1;
        end

        // increment frame length by number of words transferred
        if (KEEP_ENABLE) begin
            bit_cnt = 0;
            for (i = 0; i <= KEEP_WIDTH; i = i + 1) begin
                if (monitor_axis_tkeep == ({KEEP_WIDTH{1'b1}}) >> (KEEP_WIDTH-i)) bit_cnt = i;
            end
            frame_len_next = frame_len_next + bit_cnt;
        end else begin
            frame_len_next = frame_len_next + 1;
        end
    end
end

always @(posedge clk) begin
    if (rst) begin
        frame_len_reg <= 0;
        frame_len_valid_reg <= 0;
        frame_reg <= 1'b0;
    end else begin
        frame_len_reg <= frame_len_next;
        frame_len_valid_reg <= frame_len_valid_next;
        frame_reg <= frame_next;
    end
end

endmodule
```
