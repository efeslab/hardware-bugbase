module sdspi_wrapper (
  S_AXI_ACLK,
  S_AXI_ARESETN,
  S_AXI_AWADDR,
  S_AXI_AWPROT,
  S_AXI_AWVALID,
  S_AXI_AWREADY,
  S_AXI_WDATA,
  S_AXI_WSTRB,
  S_AXI_WVALID,
  S_AXI_WREADY,
  S_AXI_BRESP,
  S_AXI_BVALID,
  S_AXI_BREADY,
  S_AXI_ARADDR,
  S_AXI_ARPROT,
  S_AXI_ARVALID,
  S_AXI_ARREADY,
  S_AXI_RDATA,
  S_AXI_RRESP,
  S_AXI_RVALID,
  S_AXI_RREADY
);

input wire S_AXI_ACLK;
input wire S_AXI_ARESETN;
input wire [6 : 0] S_AXI_AWADDR;
input wire [2 : 0] S_AXI_AWPROT;
input wire S_AXI_AWVALID;
output wire S_AXI_AWREADY;
input wire [31 : 0] S_AXI_WDATA;
input wire [3 : 0] S_AXI_WSTRB;
input wire S_AXI_WVALID;
output wire S_AXI_WREADY;
output wire [1 : 0] S_AXI_BRESP;
output wire S_AXI_BVALID;
input wire S_AXI_BREADY;
input wire [6 : 0] S_AXI_ARADDR;
input wire [2 : 0] S_AXI_ARPROT;
input wire S_AXI_ARVALID;
output wire S_AXI_ARREADY;
output wire [31 : 0] S_AXI_RDATA;
output wire [1 : 0] S_AXI_RRESP;
output wire S_AXI_RVALID;
input wire S_AXI_RREADY;

  sdspi
  inst (
    .i_clk(S_AXI_ACLK),
    .i_wb_cyc(S_AXI_AWVALID),
    .i_wb_stb(S_AXI_WVALID),
    .i_wb_we(S_AXI_BREADY),
    .i_wb_addr(S_AXI_ARPROT[1:0]),
    .i_wb_data(S_AXI_WDATA),
    .o_wb_ack(S_AXI_AWREADY),
    .o_wb_stall(S_AXI_WREADY),
    .o_wb_data(S_AXI_RDATA),
    .o_cs_n(S_AXI_BVALID),
    .o_sck(S_AXI_ARREADY),
    .o_mosi(S_AXI_RVALID),
    .i_miso(S_AXI_ARPROT[2]),
    .o_int(S_AXI_BRESP[0]),
    .i_bus_grant(S_AXI_ARESETN),
    .o_debug()
  );
endmodule

