### Source
Source: https://github.com/ZipCPU/sdspi/commit/e3d46ab24f79b62544fb11a49de77504bbdab83f

Code: https://github.com/ZipCPU/sdspi/commit/53e9a2bf66b8185e3f856a21f1d7c2d672f0da2b

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

# SD-Card controller, using a shared SPI interface

This Verilog core exports an SD card controller interface from internal to an
FPGA to the rest of the FPGA core, while taking care of the lower level details
internal to the interface.  Unlike the [other OpenCores SD Card controller](http://www.opencores.org/project,sdcard_mass_storage_controller) which offers a full SD interface, this controller focuses on the SPI interface of the SD Card. 
While this is a slower interface, the SPI interface is
necessary to access the card when using a [XuLA2 board](http://www.xess.com/shop/product/xula2-lx25/), or
in general any time the full 9--bit, bi--directional interface to the SD card
has not been implemented.
Further, for those who are die--hard Verilog authors, this core is written in
Verilog as opposed to the [XESS provided demonstration SD Card controller
found on GitHub](https://github.com/xesscorp/VHDL\_Lib/SDCard.vhd), which was
written
in VHDL.  For those who are not such die--hard Verilog authors, this controller
provides a lower level interface to the card than these other controllers. 
Whereas the XESS controller will automatically start up the card and interact
with it, this controller requires external software to be used when interacting
with the card.  This makes this SDSPI controller both more versatile, in the
face of potential changes to the card interface, but also less turn-key.

While this core was written for the purpose of being used with the [ZipCPU](https://github.com/ZipCPU/zipcpu),
as enhanced by the Wishbone DMA controller used by the ZipCPU, nothing in this
core prevents it from being used with any other architecture that supports
the 32-bit Wishbone interface of this core.

This core has been written as a wishbone slave, not a master.  Using the core
together with a separate master, such as a CPU or a DMA controller, only makes
sense.  This design choice, however, also restricts the core from being able to
use the multiple block write or multiple block read commands, restricting us to 
single block read and write commands alone.

For more information, please consult the specification document.

# Next Steps

Now that I have an initial SD Card controller working over the SPI port, I've
kind of fallen in love with the simple interface it uses.  I'm wondering if I
can use the same control interface for the full SD protocol.  To that end, I
intend to build a version of this controller that works with the full SD
protocol--even integrating a card detect bit into the control register.

# Commercial Applications

Should you find the GPLv3 license insufficient for your needs, other licenses
can be purchased from Gisselquist Technology, LLC.