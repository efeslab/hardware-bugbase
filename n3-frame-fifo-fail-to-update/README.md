### Source
Verilog-axis(Verilog AXI Stream Components): https://github.com/alexforencich/verilog-axis/commit/a9c04a465150ae5fc9cd8f32906213d9ba9afb06

Bug type: Fail to keep value in reg (signal drop_frame_reg)


When an axis-FIFO buffer is full, it will stop writing new packets from the input.

The drop_frame_reg will be truned on and the FIFO should stop storing anything from the input until the tlast is set on (the current frame is finishing).

So the drop_frame_reg should be continuously be 1 until tlast rises.
The value should be “kept” in reg.

### Synthetic Code
```verilog
// Write logic
always @* begin
    write = 1'b0;

    drop_frame_next = 1'b0;
    overflow_next = 1'b0;
    bad_frame_next = 1'b0;
    good_frame_next = 1'b0;

    wr_ptr_next = wr_ptr_reg;
    wr_ptr_cur_next = wr_ptr_cur_reg;

    if (s_axis_tready && s_axis_tvalid) begin
        // transfer in
        if (!FRAME_FIFO) begin
            // normal FIFO mode
            write = 1'b1;
            wr_ptr_next = wr_ptr_reg + 1;
        end else if (full_cur || full_wr || drop_frame_reg) begin
            // full, packet overflow, or currently dropping frame
            // drop frame
            drop_frame_next = 1'b1;
            if (s_axis_tlast) begin
                // end of frame, reset write pointer
                wr_ptr_cur_next = wr_ptr_reg;
                drop_frame_next = 1'b0;
                overflow_next = 1'b1;
            end
        end else begin
            write = 1'b1;
            wr_ptr_cur_next = wr_ptr_cur_reg + 1;
            if (s_axis_tlast) begin
                // end of frame
                if (DROP_BAD_FRAME && USER_BAD_FRAME_MASK & ~(s_axis_tuser ^ USER_BAD_FRAME_VALUE)) begin
                    // bad packet, reset write pointer
                    wr_ptr_cur_next = wr_ptr_reg;
                    bad_frame_next = 1'b1;
                end else begin
                    // good packet, update write pointer
                    wr_ptr_next = wr_ptr_cur_reg + 1;
                    good_frame_next = 1'b1;
                end
            end
        end
    end
end
```