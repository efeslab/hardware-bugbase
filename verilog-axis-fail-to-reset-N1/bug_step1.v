module axis_frame_len #
(
  parameter ASSERT_ON = 1'b1
)
(
  input logic [0:0] clk,
  input logic [0:0] rst,
  input logic [7:0] monitor_axis_tkeep,
  input logic [0:0] monitor_axis_tvalid,
  input logic [0:0] monitor_axis_tready,
  input logic [0:0] monitor_axis_tlast,
  output logic [15:0] frame_len,
  output logic [0:0] frame_len_valid
);

  logic [15:0] frame_len_reg ;
  logic [15:0] frame_len_next ;
  logic [0:0] frame_len_valid_reg ;
  logic [0:0] frame_len_valid_next ;
  logic [0:0] frame_reg ;
  logic [0:0] frame_next ;
  integer bit_cnt;
  assign frame_len = frame_len_reg;
  assign frame_len_valid = frame_len_valid_reg;

  always_comb begin
    frame_len_next = frame_len_reg;
    frame_len_valid_next = 1'h0;
    frame_next = frame_reg;
    if (monitor_axis_tready & monitor_axis_tvalid) begin
      if (monitor_axis_tlast) begin
        frame_len_valid_next = 1'h1;
        frame_next = 1'h0;
      end else if (~frame_reg) begin
        frame_len_next = 16'h0;
        frame_next = 1'h1;
      end 
      bit_cnt = 32'sh0;
      if (8'h0 == monitor_axis_tkeep) begin
        bit_cnt = 32'h0;
      end 
      if (8'h1 == monitor_axis_tkeep) begin
        bit_cnt = 32'h1;
      end 
      if (8'h3 == monitor_axis_tkeep) begin
        bit_cnt = 32'h2;
      end 
      if (8'h7 == monitor_axis_tkeep) begin
        bit_cnt = 32'h3;
      end 
      if (8'hf == monitor_axis_tkeep) begin
        bit_cnt = 32'h4;
      end 
      if (8'h1f == monitor_axis_tkeep) begin
        bit_cnt = 32'h5;
      end 
      if (8'h3f == monitor_axis_tkeep) begin
        bit_cnt = 32'h6;
      end 
      if (8'h7f == monitor_axis_tkeep) begin
        bit_cnt = 32'h7;
      end 
      if (8'hff == monitor_axis_tkeep) begin
        bit_cnt = 32'h8;
      end 
      frame_len_next = frame_len_next + bit_cnt[15:0];
    end 
  end

  initial begin
    frame_len_reg = 16'h0;
    frame_len_valid_reg = 1'h0;
    frame_reg = 1'h0;
  end

  always @(posedge clk) begin
    if (rst) begin
      frame_len_reg <= 16'h0;
      frame_len_valid_reg <= 1'h0;
      frame_reg <= 1'h0;
    end else begin
      frame_len_reg <= frame_len_next;
      frame_len_valid_reg <= frame_len_valid_next;
      frame_reg <= frame_next;
    end
  end
  logic [31:0] frame_reg__BRA__0__3A0__KET____COUNT__ ;

  always @(posedge clk) begin
    if (rst) frame_reg__BRA__0__3A0__KET____COUNT__ <= 32'h0; 
    else if (frame_reg[0]) frame_reg__BRA__0__3A0__KET____COUNT__ <= (32'h1 + frame_reg__BRA__0__3A0__KET____COUNT__); 
  end
  logic [31:0] frame_reg__BRA__0__3A0__KET____COUNT____BRA__31__3A0__KET____Q__ /* verilator tag TransRecTarget=frame_reg__BRA__0__3A0__KET____COUNT____BRA__31__3A0__KET__ */;

  always @(posedge clk) begin
    frame_reg__BRA__0__3A0__KET____COUNT____BRA__31__3A0__KET____Q__ <= frame_reg__BRA__0__3A0__KET____COUNT__[31:0];
    if (frame_reg__BRA__0__3A0__KET____COUNT__[31:0] != frame_reg__BRA__0__3A0__KET____COUNT____BRA__31__3A0__KET____Q__) $display("%%UPDATE: [%0t] frame_reg[0:0]__COUNT__[31:0] updated to %h", $time , frame_reg__BRA__0__3A0__KET____COUNT__[31:0]) /*verilator tag debug_display_1*/; 
  end

endmodule
