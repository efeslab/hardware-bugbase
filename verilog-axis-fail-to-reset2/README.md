### Source
Verilog-axis(Verilog AXI Stream Components): https://github.com/alexforencich/verilog-axis/commit/0b2066abe3d8983a120cb8afe598c2710f2e5be6

Bug type: Fail to reset (signal drop_frame and wr_ptr_cur)

### Synthetic Code
```verilog

always @(posedge clk or posedge rst) begin
    if (rst) begin
        wr_ptr <= 0;
        // @@@Bug here: should have wr_ptr_cur <= 0;
        // @@@Bug here: should have drop_frame <= 0;
    end else if (write) begin
        if (full | full_cur | drop_frame) begin
            // buffer full, hold current pointer, drop packet at end
            drop_frame <= 1;
            if (input_axis_tlast) begin
                wr_ptr_cur <= wr_ptr;
                drop_frame <= 0;
            end
        end else begin
            mem[wr_ptr_cur[ADDR_WIDTH-1:0]] <= data_in;
            wr_ptr_cur <= wr_ptr_cur + 1;
            if (input_axis_tlast) begin
                if (input_axis_tuser) begin
                    // bad packet, reset write pointer
                    wr_ptr_cur <= wr_ptr;
                end else begin
                    // good packet, push new write pointer
                    wr_ptr <= wr_ptr_cur + 1;
                end
            end
        end
    end
end
```
