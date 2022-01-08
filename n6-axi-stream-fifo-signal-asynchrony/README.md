# C4 - Signal Asynchrony - AXI Stream FIFO

**Source:** Verilog-axis(Verilog AXI Stream Components): https://github.com/alexforencich/verilog-axis/commit/382226ad5966198862fb676c7a5810067c2c6a19

Bug type: Reset-Data Asynchrony


Data should not be accepted when reseting (input_tready should not be 1 when reseting)

### Synthetic Code
```verilog

// reset synchronization
always @(posedge input_clk or posedge async_rst) begin
    if (async_rst) begin
        input_rst_sync1 <= 1;
        input_rst_sync2 <= 1;
        input_rst_sync3 <= 1;
    end else begin
        input_rst_sync1 <= 0;
        input_rst_sync2 <= input_rst_sync1 | output_rst_sync1;
        input_rst_sync3 <= input_rst_sync2;
    end
end

// write
always @(posedge input_clk) begin
    if (input_rst_sync3) begin
        wr_ptr <= 0;
        wr_ptr_gray <= 0;
    end else if (write) begin
        mem[wr_ptr[ADDR_WIDTH-1:0]] <= data_in;
        wr_ptr_next = wr_ptr + 1;
        wr_ptr <= wr_ptr_next;
        wr_ptr_gray <= wr_ptr_next ^ (wr_ptr_next >> 1);
    end
end

assign input_axis_tready = ~full;  //Buggy here, should be ~full & ~input_rst_sync3;

```
