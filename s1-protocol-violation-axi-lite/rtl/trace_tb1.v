`ifndef VERILATOR
module testbench;
  reg [4095:0] vcdfile;
  reg clock;
`else
module testbench(input clock, output reg genclock);
  initial genclock = 1;
`endif
`ifndef VERILATOR
  reg genclock = 1;
`endif
  reg [31:0] cycle = 0;
  reg [0:0] PI_S_AXI_AWVALID;
  reg [0:0] PI_S_AXI_ARESETN;
  reg [3:0] PI_S_AXI_WSTRB;
  reg [0:0] PI_S_AXI_WVALID;
  reg [2:0] PI_S_AXI_ARPROT;
  reg [2:0] PI_S_AXI_AWPROT;
  reg [0:0] PI_S_AXI_RREADY;
  reg [6:0] PI_S_AXI_ARADDR;
  reg [0:0] PI_S_AXI_ARVALID;
  reg [6:0] PI_S_AXI_AWADDR;
  reg [31:0] PI_S_AXI_WDATA;
  reg [0:0] PI_S_AXI_BREADY;
  xlnxdemo UUT (
    .S_AXI_AWVALID(PI_S_AXI_AWVALID),
    .S_AXI_ARESETN(PI_S_AXI_ARESETN),
    .S_AXI_ACLK(clock),
    .S_AXI_WSTRB(PI_S_AXI_WSTRB),
    .S_AXI_WVALID(PI_S_AXI_WVALID),
    .S_AXI_ARPROT(PI_S_AXI_ARPROT),
    .S_AXI_AWPROT(PI_S_AXI_AWPROT),
    .S_AXI_RREADY(PI_S_AXI_RREADY),
    .S_AXI_ARADDR(PI_S_AXI_ARADDR),
    .S_AXI_ARVALID(PI_S_AXI_ARVALID),
    .S_AXI_AWADDR(PI_S_AXI_AWADDR),
    .S_AXI_WDATA(PI_S_AXI_WDATA),
    .S_AXI_BREADY(PI_S_AXI_BREADY)
  );
`ifndef VERILATOR
  initial begin
    if ($value$plusargs("vcd=%s", vcdfile)) begin
      $dumpfile(vcdfile);
      $dumpvars(0, testbench);
    end
    #5 clock = 0;
    while (genclock) begin
      #5 clock = 0;
      #5 clock = 1;
    end
  end
`endif
  initial begin
`ifndef VERILATOR
    #1;
`endif
    // UUT.$past$xlnxdemo.v:1095$145$0 = 1'b0;
    UUT.axi_araddr = 7'b0000000;
    UUT.axi_arready = 1'b0;
    UUT.axi_awaddr = 7'b0000000;
    UUT.axi_awready = 1'b0;
    UUT.axi_bresp = 2'b00;
    UUT.axi_bvalid = 1'b0;
    UUT.axi_rdata = 32'b00000000000000000000000000000000;
    UUT.axi_rresp = 2'b00;
    UUT.axi_rvalid = 1'b0;
    UUT.axi_wready = 1'b0;
    // UUT.properties.$formal$faxil_slave.v:236$753_EN = 1'b0;
    // UUT.properties.$formal$faxil_slave.v:239$756_CHECK = 1'b0;
    // UUT.properties.$formal$faxil_slave.v:241$757_CHECK = 1'b0;
    // UUT.properties.$formal$faxil_slave.v:345$773_CHECK = 1'b0;
    // UUT.properties.$formal$faxil_slave.v:345$773_EN = 1'b0;
    // UUT.properties.$formal$faxil_slave.v:346$774_CHECK = 1'b0;
    // UUT.properties.$formal$faxil_slave.v:347$775_CHECK = 1'b0;
    // UUT.properties.$formal$faxil_slave.v:353$776_CHECK = 1'b0;
    // UUT.properties.$formal$faxil_slave.v:353$776_EN = 1'b0;
    // UUT.properties.$formal$faxil_slave.v:354$777_CHECK = 1'b0;
    // UUT.properties.$formal$faxil_slave.v:590$788_CHECK = 1'b0;
    // UUT.properties.$formal$faxil_slave.v:592$789_CHECK = 1'b0;
    // UUT.properties.$formal$faxil_slave.v:594$790_CHECK = 1'b0;
    // UUT.properties.$formal$faxil_slave.v:600$791_CHECK = 1'b0;
    // UUT.properties.$formal$faxil_slave.v:600$791_EN = 1'b0;
    // UUT.properties.$formal$faxil_slave.v:603$792_CHECK = 1'b0;
    // UUT.properties.$formal$faxil_slave.v:603$792_EN = 1'b0;
    // UUT.properties.$formal$faxil_slave.v:606$793_CHECK = 1'b0;
    // UUT.properties.$formal$faxil_slave.v:606$793_EN = 1'b0;
    // UUT.properties.$formal$faxil_slave.v:685$794_CHECK = 1'b0;
    // UUT.properties.$formal$faxil_slave.v:685$794_EN = 1'b0;
    // UUT.properties.$formal$faxil_slave.v:687$795_CHECK = 1'b0;
    // UUT.properties.$formal$faxil_slave.v:695$796_CHECK = 1'b0;
    // UUT.properties.$formal$faxil_slave.v:695$796_EN = 1'b0;
    // UUT.properties.$past$faxil_slave.v:235$739$0 = 1'b0;
    // UUT.properties.$past$faxil_slave.v:320$741$0 = 1'b0;
    // UUT.properties.$past$faxil_slave.v:323$742$0 = 7'b0000000;
    // UUT.properties.$past$faxil_slave.v:328$743$0 = 1'b0;
    // UUT.properties.$past$faxil_slave.v:331$744$0 = 4'b0000;
    // UUT.properties.$past$faxil_slave.v:332$745$0 = 32'b00000000000000000000000000000000;
    // UUT.properties.$past$faxil_slave.v:337$746$0 = 1'b0;
    // UUT.properties.$past$faxil_slave.v:340$747$0 = 7'b0000000;
    // UUT.properties.$past$faxil_slave.v:344$748$0 = 1'b0;
    // UUT.properties.$past$faxil_slave.v:347$749$0 = 2'b00;
    // UUT.properties.$past$faxil_slave.v:348$750$0 = 32'b00000000000000000000000000000000;
    // UUT.properties.$past$faxil_slave.v:352$751$0 = 1'b0;
    // UUT.properties.$past$faxil_slave.v:355$752$0 = 2'b00;
    UUT.properties.CHECK_MAX_DELAY.f_axi_rd_ack_delay = 4'b0000;
    UUT.properties.CHECK_MAX_DELAY.f_axi_wr_ack_delay = 4'b0000;
    UUT.properties.CHECK_RESPONSE_STALLS.f_axi_bstall = 4'b0000;
    UUT.properties.CHECK_RESPONSE_STALLS.f_axi_rstall = 4'b0000;
    UUT.properties.CHECK_STALL_COUNT.f_axi_arstall = 4'b0000;
    UUT.properties.CHECK_STALL_COUNT.f_axi_awstall = 4'b0000;
    UUT.properties.CHECK_STALL_COUNT.f_axi_wstall = 4'b0000;
    UUT.properties.f_axi_awr_outstanding = 4'b0000;
    UUT.properties.f_axi_rd_outstanding = 4'b0000;
    UUT.properties.f_axi_wr_outstanding = 4'b0000;
    UUT.properties.f_past_valid = 1'b0;
    UUT.slv_reg0 = 32'b00000000000000000000000000000000;
    UUT.slv_reg1 = 32'b00000000000000000000000000000000;
    UUT.slv_reg10 = 32'b00000000000000000000000000000000;
    UUT.slv_reg11 = 32'b00000000000000000000000000000000;
    UUT.slv_reg12 = 32'b00000000000000000000000000000000;
    UUT.slv_reg13 = 32'b00000000000000000000000000000000;
    UUT.slv_reg14 = 32'b00000000000000000000000000000000;
    UUT.slv_reg15 = 32'b00000000000000000000000000000000;
    UUT.slv_reg16 = 32'b00000000000000000000000000000000;
    UUT.slv_reg17 = 32'b00000000000000000000000000000000;
    UUT.slv_reg18 = 32'b00000000000000000000000000000000;
    UUT.slv_reg19 = 32'b00000000000000000000000000000000;
    UUT.slv_reg2 = 32'b00000000000000000000000000000000;
    UUT.slv_reg20 = 32'b00000000000000000000000000000000;
    UUT.slv_reg21 = 32'b00000000000000000000000000000000;
    UUT.slv_reg22 = 32'b00000000000000000000000000000000;
    UUT.slv_reg23 = 32'b00000000000000000000000000000000;
    UUT.slv_reg24 = 32'b00000000000000000000000000000000;
    UUT.slv_reg25 = 32'b00000000000000000000000000000000;
    UUT.slv_reg26 = 32'b00000000000000000000000000000000;
    UUT.slv_reg27 = 32'b00000000000000000000000000000000;
    UUT.slv_reg28 = 32'b00000000000000000000000000000000;
    UUT.slv_reg29 = 32'b00000000000000000000000000000000;
    UUT.slv_reg3 = 32'b00000000000000000000000000000000;
    UUT.slv_reg30 = 32'b00000000000000000000000000000000;
    UUT.slv_reg31 = 32'b00000000000000000000000000000000;
    UUT.slv_reg4 = 32'b00000000000000000000000000000000;
    UUT.slv_reg5 = 32'b00000000000000000000000000000000;
    UUT.slv_reg6 = 32'b00000000000000000000000000000000;
    UUT.slv_reg7 = 32'b00000000000000000000000000000000;
    UUT.slv_reg8 = 32'b00000000000000000000000000000000;
    UUT.slv_reg9 = 32'b00000000000000000000000000000000;

    // state 0
    PI_S_AXI_AWVALID = 1'b0;
    PI_S_AXI_ARESETN = 1'b0;
    PI_S_AXI_WSTRB = 4'b1000;
    PI_S_AXI_WVALID = 1'b0;
    PI_S_AXI_ARPROT = 3'b000;
    PI_S_AXI_AWPROT = 3'b000;
    PI_S_AXI_RREADY = 1'b0;
    PI_S_AXI_ARADDR = 7'b1000000;
    PI_S_AXI_ARVALID = 1'b0;
    PI_S_AXI_AWADDR = 7'b1000000;
    PI_S_AXI_WDATA = 32'b10000000000000000000000000000000;
    PI_S_AXI_BREADY = 1'b0;
  end
  always @(posedge clock) begin
    // state 1
    if (cycle == 0) begin
      PI_S_AXI_AWVALID <= 1'b0;
      PI_S_AXI_ARESETN <= 1'b1;
      PI_S_AXI_WSTRB <= 4'b0000;
      PI_S_AXI_WVALID <= 1'b0;
      PI_S_AXI_ARPROT <= 3'b000;
      PI_S_AXI_AWPROT <= 3'b000;
      PI_S_AXI_RREADY <= 1'b0;
      PI_S_AXI_ARADDR <= 7'b0000000;
      PI_S_AXI_ARVALID <= 1'b0;
      PI_S_AXI_AWADDR <= 7'b0000000;
      PI_S_AXI_WDATA <= 32'b00000000000000000000000000000000;
      PI_S_AXI_BREADY <= 1'b0;
    end

    // state 2
    if (cycle == 1) begin
      PI_S_AXI_AWVALID <= 1'b1;
      PI_S_AXI_ARESETN <= 1'b1;
      PI_S_AXI_WSTRB <= 4'b1000;
      PI_S_AXI_WVALID <= 1'b1;
      PI_S_AXI_ARPROT <= 3'b000;
      PI_S_AXI_AWPROT <= 3'b000;
      PI_S_AXI_RREADY <= 1'b0;
      PI_S_AXI_ARADDR <= 7'b1000100;
      PI_S_AXI_ARVALID <= 1'b1;
      PI_S_AXI_AWADDR <= 7'b1000000;
      PI_S_AXI_WDATA <= 32'b10000000000000000000000000000000;
      PI_S_AXI_BREADY <= 1'b1;
    end

    // state 3
    if (cycle == 2) begin
      PI_S_AXI_AWVALID <= 1'b1;
      PI_S_AXI_ARESETN <= 1'b1;
      PI_S_AXI_WSTRB <= 4'b1000;
      PI_S_AXI_WVALID <= 1'b1;
      PI_S_AXI_ARPROT <= 3'b000;
      PI_S_AXI_AWPROT <= 3'b000;
      PI_S_AXI_RREADY <= 1'b0;
      PI_S_AXI_ARADDR <= 7'b1000100;
      PI_S_AXI_ARVALID <= 1'b1;
      PI_S_AXI_AWADDR <= 7'b1000000;
      PI_S_AXI_WDATA <= 32'b10000000000000000000000000000000;
      PI_S_AXI_BREADY <= 1'b1;
    end

    // state 4
    if (cycle == 3) begin
      PI_S_AXI_AWVALID <= 1'b0;
      PI_S_AXI_ARESETN <= 1'b1;
      PI_S_AXI_WSTRB <= 4'b1000;
      PI_S_AXI_WVALID <= 1'b1;
      PI_S_AXI_ARPROT <= 3'b000;
      PI_S_AXI_AWPROT <= 3'b000;
      PI_S_AXI_RREADY <= 1'b0;
      PI_S_AXI_ARADDR <= 7'b1000100;
      PI_S_AXI_ARVALID <= 1'b1;
      PI_S_AXI_AWADDR <= 7'b1000000;
      PI_S_AXI_WDATA <= 32'b10000000000000000000000000000000;
      PI_S_AXI_BREADY <= 1'b1;
    end

    // state 5
    if (cycle == 4) begin
      PI_S_AXI_AWVALID <= 1'b0;
      PI_S_AXI_ARESETN <= 1'b1;
      PI_S_AXI_WSTRB <= 4'b1000;
      PI_S_AXI_WVALID <= 1'b1;
      PI_S_AXI_ARPROT <= 3'b000;
      PI_S_AXI_AWPROT <= 3'b000;
      PI_S_AXI_RREADY <= 1'b1;
      PI_S_AXI_ARADDR <= 7'b1000100;
      PI_S_AXI_ARVALID <= 1'b1;
      PI_S_AXI_AWADDR <= 7'b1000000;
      PI_S_AXI_WDATA <= 32'b10000000000000000000000000000000;
      PI_S_AXI_BREADY <= 1'b1;
    end

    // state 6
    if (cycle == 5) begin
      PI_S_AXI_AWVALID <= 1'b0;
      PI_S_AXI_ARESETN <= 1'b1;
      PI_S_AXI_WSTRB <= 4'b1000;
      PI_S_AXI_WVALID <= 1'b1;
      PI_S_AXI_ARPROT <= 3'b000;
      PI_S_AXI_AWPROT <= 3'b000;
      PI_S_AXI_RREADY <= 1'b0;
      PI_S_AXI_ARADDR <= 7'b1000000;
      PI_S_AXI_ARVALID <= 1'b0;
      PI_S_AXI_AWADDR <= 7'b0000000;
      PI_S_AXI_WDATA <= 32'b10000000000000000000000000000000;
      PI_S_AXI_BREADY <= 1'b1;
    end

    genclock <= cycle < 6;
    cycle <= cycle + 1;
  end
endmodule
