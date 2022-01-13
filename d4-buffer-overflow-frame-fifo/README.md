# D4 - Buffer Overflow - Frame FIFO

**Source:** https://github.com/alexforencich/verilog-axis/commit/3d90e80da8e60daf5727e003d3b059e9b21b41da

This bug is found in an AXI buffer implementation in an AXI component library. It can be only triggered when configuring the buffer as a frame buffer (i.e., with `FRAME_FIFO=1`) and disabling frame drop (i.e., with `DROP_WHEN_FULL=0`).

In the original code, there are two full indicators. The `full` variable indicates that the buffer is full; the `full_cur` variable indicates that the incoming frame is too large that itself is overlowing the buffer. However, the `full` variable is only updated when the whole frame is written to the buffer, instead of being updated at each cycle when there's an incoming packet (i.e., a piece of the frame). As a result, using `full` to control the ready signal of the input channel would result to an overflow.

### Code Snippet

```verilog
assign input_tready = !full;
// full identify whether the read pointer surpass wr_ptr
wire full = ((wr_ptr_reg[ADDR_WIDTH] != rd_ptr_reg[ADDR_WIDTH]) &&
              (wr_ptr_reg[ADDR_WIDTH-1:0] == rd_ptr_reg[ADDR_WIDTH-1:0]));wire full_cur = overflow_within_fifo;
// full_cur indicate whether the wr_ptr_cur pointer surpass wr_ptr
wire full_cur = ((wr_ptr_reg[ADDR_WIDTH] != wr_ptr_cur_reg[ADDR_WIDTH]) &&
                  (wr_ptr_reg[ADDR_WIDTH-1:0] == wr_ptr_cur_reg[ADDR_WIDTH-1:0]));
                  
always @* begin
    if (input_tvalid) begin
        if (!full) begin
            write = 1;
            wr_ptr_cur_next = wr_ptr_cur_reg + 1;
            if (input_tlast) begin
                // end of frame, only update wr_ptr here
                wr_ptr_next = wr_ptr_cur_reg + 1;
            end
        end
    end
```

