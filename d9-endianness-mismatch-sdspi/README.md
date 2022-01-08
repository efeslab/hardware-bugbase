# D9 - Endianness Mismatch - SDSPI

Code: https://github.com/ZipCPU/sdspi/commit/53e9a2bf66b8185e3f856a21f1d7c2d672f0da2b

This bug is discovered in an old commit of a hardware SD card driver. The author failed to use the same endianness to read from and write to the SD card. During write, this module takes 32-bit input, splits the input into four 8-bit registers, and writes them to the SD card. During read, it reads four 8-bit value from the SD card and merge them to a single 32-bit value. However, the splition and merging use different endianness.

When this bug is triggerred, the developer would notice incorrect result after writing data to the SD card and reading it out.

### Synthetic Code
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
