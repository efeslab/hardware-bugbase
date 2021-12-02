# C3 - Data-Control Asynchrony - SDSPI

Source: https://github.com/ZipCPU/sdspi/commit/e3d46ab24f79b62544fb11a49de77504bbdab83f

Code: https://github.com/ZipCPU/sdspi/commit/53e9a2bf66b8185e3f856a21f1d7c2d672f0da2b

This bug is found in the commit history of SDSPI, an SD card controller. In a burst-like read where a number of contiguous data entries are read from the SD card, the first entry will repeat twice, and the last entry will loss.

The root cause of this bug is that the control signal (i.e., `rd_ack` in the following synthetic code) is one cycle earlier than the actual data, as explained in the comments.

### Synthetic Code
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
