module axis_fifo #
(
  parameter ASSERT_ON = 1'b1
)
(
  input logic [0:0] clk,
  input logic [0:0] rst,
  input logic [7:0] s_axis_tdata,
  input logic [0:0] s_axis_tkeep,
  input logic [0:0] s_axis_tvalid,
  output logic [0:0] s_axis_tready,
  input logic [0:0] s_axis_tlast,
  input logic [7:0] s_axis_tid,
  input logic [7:0] s_axis_tdest,
  input logic [0:0] s_axis_tuser,
  output logic [7:0] m_axis_tdata,
  output logic [0:0] m_axis_tkeep,
  output logic [0:0] m_axis_tvalid,
  input logic [0:0] m_axis_tready,
  output logic [0:0] m_axis_tlast,
  output logic [7:0] m_axis_tid,
  output logic [7:0] m_axis_tdest,
  output logic [0:0] m_axis_tuser,
  output logic [0:0] status_overflow,
  output logic [0:0] status_bad_frame,
  output logic [0:0] status_good_frame
);

  logic [2:0] wr_ptr_reg ;
  logic [2:0] wr_ptr_next ;
  logic [2:0] wr_ptr_cur_reg ;
  logic [2:0] wr_ptr_cur_next ;
  logic [2:0] wr_addr_reg ;
  logic [2:0] rd_ptr_reg ;
  logic [2:0] rd_ptr_next ;
  logic [2:0] rd_addr_reg ;
  logic [25:0] mem [3:0] ;
  logic [25:0] mem_read_data_reg ;
  logic [0:0] mem_read_data_valid_reg ;
  logic [0:0] mem_read_data_valid_next ;
  logic [25:0] s_axis ;
  logic [25:0] m_axis_reg ;
  logic [0:0] m_axis_tvalid_reg ;
  logic [0:0] m_axis_tvalid_next ;
  logic [0:0] full_cur ;
  logic [0:0] empty ;
  logic [0:0] full_wr ;
  logic [0:0] write ;
  logic [0:0] read ;
  logic [0:0] store_output ;
  logic [0:0] drop_frame_reg ;
  logic [0:0] drop_frame_next ;
  logic [0:0] overflow_reg ;
  logic [0:0] overflow_next ;
  logic [0:0] bad_frame_reg ;
  logic [0:0] bad_frame_next ;
  logic [0:0] good_frame_reg ;
  logic [0:0] good_frame_next ;
  assign full_cur = (wr_ptr_cur_reg[2] != rd_ptr_reg[2]) & (wr_ptr_cur_reg[1:0] == rd_ptr_reg[1:0]);
  assign empty = wr_ptr_reg == rd_ptr_reg;
  assign full_wr = (wr_ptr_reg[2] != wr_ptr_cur_reg[2]) & (wr_ptr_reg[1:0] == wr_ptr_cur_reg[1:0]);
  assign s_axis[7:0] = s_axis_tdata;
  assign s_axis[8] = s_axis_tlast;
  assign s_axis[16:9] = s_axis_tid;
  assign s_axis[24:17] = s_axis_tdest;
  assign s_axis[25] = s_axis_tuser;
  assign m_axis_tvalid = m_axis_tvalid_reg;
  assign m_axis_tdata = m_axis_reg[7:0];
  assign m_axis_tlast = m_axis_reg[8];
  assign m_axis_tid = m_axis_reg[16:9];
  assign m_axis_tdest = m_axis_reg[24:17];
  assign m_axis_tuser = m_axis_reg[25];
  assign status_overflow = overflow_reg;
  assign status_bad_frame = bad_frame_reg;
  assign status_good_frame = good_frame_reg;

  always_comb begin
    write = 1'h0;
    drop_frame_next = 1'h0;
    overflow_next = 1'h0;
    bad_frame_next = 1'h0;
    good_frame_next = 1'h0;
    wr_ptr_next = wr_ptr_reg;
    wr_ptr_cur_next = wr_ptr_cur_reg;
    if (s_axis_tvalid) begin
      if (full_cur | full_wr | drop_frame_reg) begin
        drop_frame_next = 1'h1;
        if (s_axis_tlast) begin
          wr_ptr_cur_next = wr_ptr_reg;
          drop_frame_next = 1'h0;
          overflow_next = 1'h1;
        end 
      end else begin
        write = 1'h1;
        wr_ptr_cur_next = 3'h1 + wr_ptr_cur_reg;
        if (s_axis_tlast) begin
          wr_ptr_next = 3'h1 + wr_ptr_cur_reg;
          good_frame_next = 1'h1;
        end 
      end
    end 
  end

  always_comb begin
    read = 1'h0;
    rd_ptr_next = rd_ptr_reg;
    mem_read_data_valid_next = mem_read_data_valid_reg;
    if (store_output | ~mem_read_data_valid_reg) begin
      if (empty) begin
        mem_read_data_valid_next = 1'h0;
      end else begin
        read = 1'h1;
        mem_read_data_valid_next = 1'h1;
        rd_ptr_next = 3'h1 + rd_ptr_reg;
      end
    end 
  end

  always_comb begin
    store_output = 1'h0;
    m_axis_tvalid_next = m_axis_tvalid_reg;
    if (m_axis_tready | ~m_axis_tvalid) begin
      store_output = 1'h1;
      m_axis_tvalid_next = mem_read_data_valid_reg;
    end 
  end

  initial begin
    wr_ptr_reg = 3'h0;
    wr_ptr_cur_reg = 3'h0;
    wr_addr_reg = 3'h0;
    rd_ptr_reg = 3'h0;
    rd_addr_reg = 3'h0;
    mem_read_data_valid_reg = 1'h0;
    m_axis_tvalid_reg = 1'h0;
    drop_frame_reg = 1'h0;
    overflow_reg = 1'h0;
    bad_frame_reg = 1'h0;
    good_frame_reg = 1'h0;
    s_axis_tready = 1'h1;
    m_axis_tkeep = 1'h1;
  end

  always @(posedge clk) begin
    if (rst) begin
      wr_ptr_reg <= 3'h0;
      wr_ptr_cur_reg <= 3'h0;
      drop_frame_reg <= 1'h0;
      overflow_reg <= 1'h0;
      bad_frame_reg <= 1'h0;
      good_frame_reg <= 1'h0;
    end else begin
      wr_ptr_reg <= wr_ptr_next;
      wr_ptr_cur_reg <= wr_ptr_cur_next;
      drop_frame_reg <= drop_frame_next;
      overflow_reg <= overflow_next;
      bad_frame_reg <= bad_frame_next;
      good_frame_reg <= good_frame_next;
    end
    wr_addr_reg <= wr_ptr_cur_next;
    if (write) begin
      mem[wr_addr_reg[1:0]] <= s_axis;
    end 
  end

  always @(posedge clk) begin
    if (rst) begin
      rd_ptr_reg <= 3'h0;
      mem_read_data_valid_reg <= 1'h0;
    end else begin
      rd_ptr_reg <= rd_ptr_next;
      mem_read_data_valid_reg <= mem_read_data_valid_next;
    end
    rd_addr_reg <= rd_ptr_next;
    if (read) begin
      mem_read_data_reg <= mem[rd_addr_reg[1:0]];
    end 
  end

  always @(posedge clk) begin
    m_axis_tvalid_reg <= ~rst & m_axis_tvalid_next;
    if (store_output) begin
      m_axis_reg <= mem_read_data_reg;
    end 
  end
  logic [0:0] drop_frame_reg__BRA__0__KET____Q__ /* verilator tag TransRecTarget=drop_frame_reg__BRA__0__KET__ */;
  logic [0:0] drop_frame_next__BRA__0__KET____Q__ /* verilator tag TransRecTarget=drop_frame_next__BRA__0__KET__ */;
  logic [0:0] full_cur__BRA__0__KET____Q__ /* verilator tag TransRecTarget=full_cur__BRA__0__KET__ */;
  logic [0:0] full_wr__BRA__0__KET____Q__ /* verilator tag TransRecTarget=full_wr__BRA__0__KET__ */;
  logic [0:0] rst__BRA__0__KET____Q__ /* verilator tag TransRecTarget=rst__BRA__0__KET__ */;
  logic [0:0] s_axis_tvalid__BRA__0__KET____Q__ /* verilator tag TransRecTarget=s_axis_tvalid__BRA__0__KET__ */;
  logic [0:0] wr_ptr_cur_reg__BRA__2__KET____Q__ /* verilator tag TransRecTarget=wr_ptr_cur_reg__BRA__2__KET__ */;
  logic [0:0] rd_ptr_reg__BRA__2__KET____Q__ /* verilator tag TransRecTarget=rd_ptr_reg__BRA__2__KET__ */;
  logic [0:0] wr_ptr_reg__BRA__2__KET____Q__ /* verilator tag TransRecTarget=wr_ptr_reg__BRA__2__KET__ */;
  logic [0:0] s_axis_tlast__BRA__0__KET____Q__ /* verilator tag TransRecTarget=s_axis_tlast__BRA__0__KET__ */;

  always @(posedge clk) begin
    drop_frame_reg__BRA__0__KET____Q__ <= drop_frame_reg[0];
    if (drop_frame_reg[0] != drop_frame_reg__BRA__0__KET____Q__) $display("%%UPDATE: [%0t] drop_frame_reg[0] updated to %h", $time , drop_frame_reg[0]) /*verilator tag debug_display_1*/; 
    drop_frame_next__BRA__0__KET____Q__ <= drop_frame_next[0];
    if (drop_frame_next[0] != drop_frame_next__BRA__0__KET____Q__) $display("%%UPDATE: [%0t] drop_frame_next[0] updated to %h", $time , drop_frame_next[0]) /*verilator tag debug_display_1*/; 
    full_cur__BRA__0__KET____Q__ <= full_cur[0];
    if (full_cur[0] != full_cur__BRA__0__KET____Q__) $display("%%UPDATE: [%0t] full_cur[0] updated to %h", $time , full_cur[0]) /*verilator tag debug_display_1*/; 
    full_wr__BRA__0__KET____Q__ <= full_wr[0];
    if (full_wr[0] != full_wr__BRA__0__KET____Q__) $display("%%UPDATE: [%0t] full_wr[0] updated to %h", $time , full_wr[0]) /*verilator tag debug_display_1*/; 
    rst__BRA__0__KET____Q__ <= rst[0];
    if (rst[0] != rst__BRA__0__KET____Q__) $display("%%UPDATE: [%0t] rst[0] updated to %h", $time , rst[0]) /*verilator tag debug_display_1*/; 
    s_axis_tvalid__BRA__0__KET____Q__ <= s_axis_tvalid[0];
    if (s_axis_tvalid[0] != s_axis_tvalid__BRA__0__KET____Q__) $display("%%UPDATE: [%0t] s_axis_tvalid[0] updated to %h", $time , s_axis_tvalid[0]) /*verilator tag debug_display_1*/; 
    wr_ptr_cur_reg__BRA__2__KET____Q__ <= wr_ptr_cur_reg[2];
    if (wr_ptr_cur_reg[2] != wr_ptr_cur_reg__BRA__2__KET____Q__) $display("%%UPDATE: [%0t] wr_ptr_cur_reg[2] updated to %h", $time , wr_ptr_cur_reg[2]) /*verilator tag debug_display_1*/; 
    rd_ptr_reg__BRA__2__KET____Q__ <= rd_ptr_reg[2];
    if (rd_ptr_reg[2] != rd_ptr_reg__BRA__2__KET____Q__) $display("%%UPDATE: [%0t] rd_ptr_reg[2] updated to %h", $time , rd_ptr_reg[2]) /*verilator tag debug_display_1*/; 
    wr_ptr_reg__BRA__2__KET____Q__ <= wr_ptr_reg[2];
    if (wr_ptr_reg[2] != wr_ptr_reg__BRA__2__KET____Q__) $display("%%UPDATE: [%0t] wr_ptr_reg[2] updated to %h", $time , wr_ptr_reg[2]) /*verilator tag debug_display_1*/; 
    s_axis_tlast__BRA__0__KET____Q__ <= s_axis_tlast[0];
    if (s_axis_tlast[0] != s_axis_tlast__BRA__0__KET____Q__) $display("%%UPDATE: [%0t] s_axis_tlast[0] updated to %h", $time , s_axis_tlast[0]) /*verilator tag debug_display_1*/; 
  end

endmodule
