module axis_fifo_wrapper #
(
  parameter ASSERT_ON = 1'b1
)
(
  input logic [0:0] clk,
  input logic [0:0] rst,
  input logic [7:0] s_axis_tdata,
  input logic [0:0] s_axis_tvalid,
  output logic [0:0] s_axis_tready,
  input logic [0:0] s_axis_tlast,
  input logic [0:0] s_axis_tuser,
  output logic [7:0] m_axis_tdata,
  output logic [0:0] m_axis_tvalid,
  input logic [0:0] m_axis_tready,
  output logic [0:0] m_axis_tlast,
  output logic [0:0] m_axis_tuser,
  output logic [0:0] status_overflow,
  output logic [0:0] status_bad_frame,
  output logic [0:0] status_good_frame
);

  logic [63:0] TASKPASS_cycle_counter ;
  logic [5:0] axis_fifo_inst__DOT__wr_ptr_reg ;
  logic [5:0] axis_fifo_inst__DOT__wr_ptr_next ;
  logic [5:0] axis_fifo_inst__DOT__wr_ptr_cur_reg ;
  logic [5:0] axis_fifo_inst__DOT__wr_ptr_cur_next ;
  logic [5:0] axis_fifo_inst__DOT__wr_addr_reg ;
  logic [5:0] axis_fifo_inst__DOT__rd_ptr_reg ;
  logic [5:0] axis_fifo_inst__DOT__rd_ptr_next ;
  logic [5:0] axis_fifo_inst__DOT__rd_addr_reg ;
  logic [9:0] axis_fifo_inst__DOT__mem [31:0] ;
  logic [9:0] axis_fifo_inst__DOT__mem_read_data_reg ;
  logic [0:0] axis_fifo_inst__DOT__mem_read_data_valid_reg ;
  logic [0:0] axis_fifo_inst__DOT__mem_read_data_valid_next ;
  logic [9:0] axis_fifo_inst__DOT__s_axis ;
  logic [9:0] axis_fifo_inst__DOT__m_axis_reg ;
  logic [0:0] axis_fifo_inst__DOT__m_axis_tvalid_reg ;
  logic [0:0] axis_fifo_inst__DOT__m_axis_tvalid_next ;
  logic [0:0] axis_fifo_inst__DOT__full ;
  logic [0:0] axis_fifo_inst__DOT__empty ;
  logic [0:0] axis_fifo_inst__DOT__full_cur ;
  logic [0:0] axis_fifo_inst__DOT__write ;
  logic [0:0] axis_fifo_inst__DOT__read ;
  logic [0:0] axis_fifo_inst__DOT__store_output ;
  logic [0:0] axis_fifo_inst__DOT__drop_frame_reg ;
  logic [0:0] axis_fifo_inst__DOT__drop_frame_next ;
  logic [0:0] axis_fifo_inst__DOT__overflow_reg ;
  logic [0:0] axis_fifo_inst__DOT__overflow_next ;
  logic [0:0] axis_fifo_inst__DOT__bad_frame_reg ;
  logic [0:0] axis_fifo_inst__DOT__bad_frame_next ;
  logic [0:0] axis_fifo_inst__DOT__good_frame_reg ;
  logic [0:0] axis_fifo_inst__DOT__good_frame_next ;
  assign axis_fifo_inst__DOT__full = (axis_fifo_inst__DOT__wr_ptr_reg[5] != axis_fifo_inst__DOT__rd_ptr_reg[5]) & (axis_fifo_inst__DOT__wr_ptr_reg[4:0] == axis_fifo_inst__DOT__rd_ptr_reg[4:0]);
  assign axis_fifo_inst__DOT__empty = axis_fifo_inst__DOT__wr_ptr_reg == axis_fifo_inst__DOT__rd_ptr_reg;
  assign axis_fifo_inst__DOT__full_cur = (axis_fifo_inst__DOT__wr_ptr_reg[5] != axis_fifo_inst__DOT__wr_ptr_cur_reg[5]) & (axis_fifo_inst__DOT__wr_ptr_reg[4:0] == axis_fifo_inst__DOT__wr_ptr_cur_reg[4:0]);
  assign s_axis_tready = ~axis_fifo_inst__DOT__full;
  assign axis_fifo_inst__DOT__s_axis[7:0] = s_axis_tdata;
  assign axis_fifo_inst__DOT__s_axis[8] = s_axis_tlast;
  assign axis_fifo_inst__DOT__s_axis[9] = s_axis_tuser;
  assign m_axis_tvalid = axis_fifo_inst__DOT__m_axis_tvalid_reg;
  assign m_axis_tdata = axis_fifo_inst__DOT__m_axis_reg[7:0];
  assign m_axis_tlast = axis_fifo_inst__DOT__m_axis_reg[8];
  assign m_axis_tuser = axis_fifo_inst__DOT__m_axis_reg[9];
  assign status_overflow = axis_fifo_inst__DOT__overflow_reg;
  assign status_bad_frame = axis_fifo_inst__DOT__bad_frame_reg;
  assign status_good_frame = axis_fifo_inst__DOT__good_frame_reg;

  always_comb begin
    axis_fifo_inst__DOT__write = 1'h0;
    axis_fifo_inst__DOT__drop_frame_next = 1'h0;
    axis_fifo_inst__DOT__overflow_next = 1'h0;
    axis_fifo_inst__DOT__bad_frame_next = 1'h0;
    axis_fifo_inst__DOT__good_frame_next = 1'h0;
    axis_fifo_inst__DOT__wr_ptr_next = axis_fifo_inst__DOT__wr_ptr_reg;
    axis_fifo_inst__DOT__wr_ptr_cur_next = axis_fifo_inst__DOT__wr_ptr_cur_reg;
    if (s_axis_tvalid) begin
      if (~axis_fifo_inst__DOT__full) begin
        if (axis_fifo_inst__DOT__full | axis_fifo_inst__DOT__full_cur | axis_fifo_inst__DOT__drop_frame_reg) begin
          axis_fifo_inst__DOT__drop_frame_next = 1'h1;
          if (s_axis_tlast) begin
            axis_fifo_inst__DOT__wr_ptr_cur_next = axis_fifo_inst__DOT__wr_ptr_reg;
            axis_fifo_inst__DOT__drop_frame_next = 1'h0;
            axis_fifo_inst__DOT__overflow_next = 1'h1;
          end 
        end else begin
          axis_fifo_inst__DOT__write = 1'h1;
          axis_fifo_inst__DOT__wr_ptr_cur_next = 6'h1 + axis_fifo_inst__DOT__wr_ptr_cur_reg;
          if (s_axis_tlast) begin
            axis_fifo_inst__DOT__wr_ptr_next = 6'h1 + axis_fifo_inst__DOT__wr_ptr_cur_reg;
            axis_fifo_inst__DOT__good_frame_next = 1'h1;
          end 
        end
      end 
    end 
  end

  always_comb begin
    axis_fifo_inst__DOT__read = 1'h0;
    axis_fifo_inst__DOT__rd_ptr_next = axis_fifo_inst__DOT__rd_ptr_reg;
    axis_fifo_inst__DOT__mem_read_data_valid_next = axis_fifo_inst__DOT__mem_read_data_valid_reg;
    if (axis_fifo_inst__DOT__store_output | ~axis_fifo_inst__DOT__mem_read_data_valid_reg) begin
      if (axis_fifo_inst__DOT__empty) begin
        axis_fifo_inst__DOT__mem_read_data_valid_next = 1'h0;
      end else begin
        axis_fifo_inst__DOT__read = 1'h1;
        axis_fifo_inst__DOT__mem_read_data_valid_next = 1'h1;
        axis_fifo_inst__DOT__rd_ptr_next = 6'h1 + axis_fifo_inst__DOT__rd_ptr_reg;
      end
    end 
  end

  always_comb begin
    axis_fifo_inst__DOT__store_output = 1'h0;
    axis_fifo_inst__DOT__m_axis_tvalid_next = axis_fifo_inst__DOT__m_axis_tvalid_reg;
    if (m_axis_tready | ~m_axis_tvalid) begin
      axis_fifo_inst__DOT__store_output = 1'h1;
      axis_fifo_inst__DOT__m_axis_tvalid_next = axis_fifo_inst__DOT__mem_read_data_valid_reg;
    end 
  end

  initial begin
    axis_fifo_inst__DOT__wr_ptr_reg = 6'h0;
    axis_fifo_inst__DOT__wr_ptr_cur_reg = 6'h0;
    axis_fifo_inst__DOT__wr_addr_reg = 6'h0;
    axis_fifo_inst__DOT__rd_ptr_reg = 6'h0;
    axis_fifo_inst__DOT__rd_addr_reg = 6'h0;
    axis_fifo_inst__DOT__mem_read_data_valid_reg = 1'h0;
    axis_fifo_inst__DOT__m_axis_tvalid_reg = 1'h0;
    axis_fifo_inst__DOT__drop_frame_reg = 1'h0;
    axis_fifo_inst__DOT__overflow_reg = 1'h0;
    axis_fifo_inst__DOT__bad_frame_reg = 1'h0;
    axis_fifo_inst__DOT__good_frame_reg = 1'h0;
  end

  always @(posedge clk) begin
    if (~rst) begin
      if (({ 27'h0, axis_fifo_inst__DOT__wr_ptr_cur_next[4:0] } == 32'sh1 + { 27'h0, axis_fifo_inst__DOT__wr_ptr_cur_reg[4:0] }) & (axis_fifo_inst__DOT__wr_ptr_cur_next[4:0] == axis_fifo_inst__DOT__rd_ptr_next[4:0])) begin
        $display("[%0t] %%Error: axis_fifo.v:180: Assertion failed in axis_fifo_wrapper.axis_fifo_inst: buffer overflow", $time ) ;
        $stop ;
      end 
    end 
  end

  always @(posedge clk) begin
    if (rst) begin
      axis_fifo_inst__DOT__wr_ptr_reg <= 6'h0;
      axis_fifo_inst__DOT__wr_ptr_cur_reg <= 6'h0;
      axis_fifo_inst__DOT__drop_frame_reg <= 1'h0;
      axis_fifo_inst__DOT__overflow_reg <= 1'h0;
      axis_fifo_inst__DOT__bad_frame_reg <= 1'h0;
      axis_fifo_inst__DOT__good_frame_reg <= 1'h0;
    end else begin
      axis_fifo_inst__DOT__wr_ptr_reg <= axis_fifo_inst__DOT__wr_ptr_next;
      axis_fifo_inst__DOT__wr_ptr_cur_reg <= axis_fifo_inst__DOT__wr_ptr_cur_next;
      axis_fifo_inst__DOT__drop_frame_reg <= axis_fifo_inst__DOT__drop_frame_next;
      axis_fifo_inst__DOT__overflow_reg <= axis_fifo_inst__DOT__overflow_next;
      axis_fifo_inst__DOT__bad_frame_reg <= axis_fifo_inst__DOT__bad_frame_next;
      axis_fifo_inst__DOT__good_frame_reg <= axis_fifo_inst__DOT__good_frame_next;
    end
    axis_fifo_inst__DOT__wr_addr_reg <= axis_fifo_inst__DOT__wr_ptr_cur_next;
    if (axis_fifo_inst__DOT__write) begin
      axis_fifo_inst__DOT__mem[axis_fifo_inst__DOT__wr_addr_reg[4:0]] <= axis_fifo_inst__DOT__s_axis;
    end 
  end

  always @(posedge clk) begin
    if (rst) begin
      axis_fifo_inst__DOT__rd_ptr_reg <= 6'h0;
      axis_fifo_inst__DOT__mem_read_data_valid_reg <= 1'h0;
    end else begin
      axis_fifo_inst__DOT__rd_ptr_reg <= axis_fifo_inst__DOT__rd_ptr_next;
      axis_fifo_inst__DOT__mem_read_data_valid_reg <= axis_fifo_inst__DOT__mem_read_data_valid_next;
    end
    axis_fifo_inst__DOT__rd_addr_reg <= axis_fifo_inst__DOT__rd_ptr_next;
    if (axis_fifo_inst__DOT__read) begin
      axis_fifo_inst__DOT__mem_read_data_reg <= axis_fifo_inst__DOT__mem[axis_fifo_inst__DOT__rd_addr_reg[4:0]];
    end 
  end

  always @(posedge clk) begin
    axis_fifo_inst__DOT__m_axis_tvalid_reg <= ~rst & axis_fifo_inst__DOT__m_axis_tvalid_next;
    if (axis_fifo_inst__DOT__store_output) begin
      axis_fifo_inst__DOT__m_axis_reg <= axis_fifo_inst__DOT__mem_read_data_reg;
    end 
  end
  logic m_axis_tdata__BRA__7__03A0__KET____AV__ ;
  logic m_axis_tdata__BRA__7__03A0__KET____AI__ ;
  logic m_axis_tdata__BRA__7__03A0__KET____ASSIGN__ ;
  logic m_axis_tdata__BRA__7__03A0__KET____VALID__ ;
  logic axis_fifo_inst__DOT__m_axis_reg__BRA__7__03A0__KET____AV__ ;
  logic axis_fifo_inst__DOT__m_axis_reg__BRA__7__03A0__KET____AI__ ;
  logic axis_fifo_inst__DOT__m_axis_reg__BRA__7__03A0__KET____ASSIGN__ ;
  logic axis_fifo_inst__DOT__m_axis_reg__BRA__7__03A0__KET____VALID__ ;
  logic axis_fifo_inst__DOT__m_axis_reg__BRA__7__03A0__KET____AV_Q__ ;
  logic axis_fifo_inst__DOT__m_axis_reg__BRA__7__03A0__KET____AI_Q__ ;
  logic axis_fifo_inst__DOT__m_axis_reg__BRA__7__03A0__KET____ASSIGN_Q__ ;
  logic axis_fifo_inst__DOT__m_axis_reg__BRA__7__03A0__KET____VALID_Q__ ;
  logic axis_fifo_inst__DOT__mem_read_data_reg__BRA__7__03A0__KET____AV__ ;
  logic axis_fifo_inst__DOT__mem_read_data_reg__BRA__7__03A0__KET____AI__ ;
  logic axis_fifo_inst__DOT__mem_read_data_reg__BRA__7__03A0__KET____ASSIGN__ ;
  logic axis_fifo_inst__DOT__mem_read_data_reg__BRA__7__03A0__KET____VALID__ ;
  logic axis_fifo_inst__DOT__mem_read_data_reg__BRA__7__03A0__KET____AV_Q__ ;
  logic axis_fifo_inst__DOT__mem_read_data_reg__BRA__7__03A0__KET____AI_Q__ ;
  logic axis_fifo_inst__DOT__mem_read_data_reg__BRA__7__03A0__KET____ASSIGN_Q__ ;
  logic axis_fifo_inst__DOT__mem_read_data_reg__BRA__7__03A0__KET____VALID_Q__ ;
  logic axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____AV__ [31:0] ;
  logic axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____AI__ [31:0] ;
  logic axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____ASSIGN__ [31:0] ;
  logic axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____VALID__ [31:0] ;
  logic axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____AV_Q__ [31:0] ;
  logic axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____AI_Q__ [31:0] ;
  logic axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____ASSIGN_Q__ [31:0] ;
  logic axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____VALID_Q__ [31:0] ;
  logic axis_fifo_inst__DOT__s_axis__BRA__7__03A0__KET____AV__ ;
  logic axis_fifo_inst__DOT__s_axis__BRA__7__03A0__KET____AI__ ;
  logic axis_fifo_inst__DOT__s_axis__BRA__7__03A0__KET____ASSIGN__ ;
  logic axis_fifo_inst__DOT__s_axis__BRA__7__03A0__KET____VALID__ ;
  logic axis_fifo_inst__DOT__m_axis_reg__BRA__7__03A0__KET____PROP__ ;
  logic axis_fifo_inst__DOT__m_axis_reg__BRA__7__03A0__KET____PROP_Q__ ;
  logic axis_fifo_inst__DOT__m_axis_reg__BRA__7__03A0__KET____GOOD__ ;
  logic axis_fifo_inst__DOT__m_axis_reg__BRA__7__03A0__KET____GOOD_Q__ ;
  logic axis_fifo_inst__DOT__mem_read_data_reg__BRA__7__03A0__KET____PROP__ ;
  logic axis_fifo_inst__DOT__mem_read_data_reg__BRA__7__03A0__KET____PROP_Q__ ;
  logic axis_fifo_inst__DOT__mem_read_data_reg__BRA__7__03A0__KET____GOOD__ ;
  logic axis_fifo_inst__DOT__mem_read_data_reg__BRA__7__03A0__KET____GOOD_Q__ ;
  logic axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____PROP__ [31:0] ;
  logic axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____PROP_Q__ [31:0] ;
  logic axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____GOOD__ [31:0] ;
  logic axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____GOOD_Q__ [31:0] ;
  logic [4:0] array_pointer_delay_0 ;
  logic s_axis_tdata__VALID__ ;
  assign m_axis_tdata__BRA__7__03A0__KET____AV__ = axis_fifo_inst__DOT__m_axis_reg__BRA__7__03A0__KET____VALID__;
  assign m_axis_tdata__BRA__7__03A0__KET____AI__ = m_axis_tdata__BRA__7__03A0__KET____ASSIGN__ & ~m_axis_tdata__BRA__7__03A0__KET____AV__;
  assign m_axis_tdata__BRA__7__03A0__KET____ASSIGN__ = 1'b1;
  assign m_axis_tdata__BRA__7__03A0__KET____VALID__ = m_axis_tdata__BRA__7__03A0__KET____AV__;
  assign axis_fifo_inst__DOT__m_axis_reg__BRA__7__03A0__KET____AV__ = axis_fifo_inst__DOT__store_output & axis_fifo_inst__DOT__mem_read_data_reg__BRA__7__03A0__KET____VALID__;
  assign axis_fifo_inst__DOT__m_axis_reg__BRA__7__03A0__KET____AI__ = axis_fifo_inst__DOT__m_axis_reg__BRA__7__03A0__KET____ASSIGN__ & ~axis_fifo_inst__DOT__m_axis_reg__BRA__7__03A0__KET____AV__;
  assign axis_fifo_inst__DOT__m_axis_reg__BRA__7__03A0__KET____ASSIGN__ = axis_fifo_inst__DOT__store_output;
  assign axis_fifo_inst__DOT__m_axis_reg__BRA__7__03A0__KET____VALID__ = axis_fifo_inst__DOT__m_axis_reg__BRA__7__03A0__KET____AV_Q__ | ~axis_fifo_inst__DOT__m_axis_reg__BRA__7__03A0__KET____ASSIGN_Q__ & axis_fifo_inst__DOT__m_axis_reg__BRA__7__03A0__KET____VALID_Q__;
  assign axis_fifo_inst__DOT__mem_read_data_reg__BRA__7__03A0__KET____AV__ = axis_fifo_inst__DOT__read & axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____VALID__[axis_fifo_inst__DOT__rd_addr_reg[4:0]];
  assign axis_fifo_inst__DOT__mem_read_data_reg__BRA__7__03A0__KET____AI__ = axis_fifo_inst__DOT__mem_read_data_reg__BRA__7__03A0__KET____ASSIGN__ & ~axis_fifo_inst__DOT__mem_read_data_reg__BRA__7__03A0__KET____AV__;
  assign axis_fifo_inst__DOT__mem_read_data_reg__BRA__7__03A0__KET____ASSIGN__ = axis_fifo_inst__DOT__read;
  assign axis_fifo_inst__DOT__mem_read_data_reg__BRA__7__03A0__KET____VALID__ = axis_fifo_inst__DOT__mem_read_data_reg__BRA__7__03A0__KET____AV_Q__ | ~axis_fifo_inst__DOT__mem_read_data_reg__BRA__7__03A0__KET____ASSIGN_Q__ & axis_fifo_inst__DOT__mem_read_data_reg__BRA__7__03A0__KET____VALID_Q__;
  assign axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____AV__[5'h0] = (5'h0 == axis_fifo_inst__DOT__wr_addr_reg[32'h4:32'h0]) & (axis_fifo_inst__DOT__write & axis_fifo_inst__DOT__s_axis__BRA__7__03A0__KET____VALID__);
  assign axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____AI__[5'h0] = axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____ASSIGN__[5'h0] & ~axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____AV__[5'h0];
  assign axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____ASSIGN__[5'h0] = axis_fifo_inst__DOT__write & (5'h0 == axis_fifo_inst__DOT__wr_addr_reg[32'h4:32'h0]);
  assign axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____VALID__[5'h0] = axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____AV_Q__[5'h0] | ~axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____ASSIGN_Q__[5'h0] & axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____VALID_Q__[5'h0];
  assign axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____AV__[5'h1] = (5'h1 == axis_fifo_inst__DOT__wr_addr_reg[32'h4:32'h0]) & (axis_fifo_inst__DOT__write & axis_fifo_inst__DOT__s_axis__BRA__7__03A0__KET____VALID__);
  assign axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____AI__[5'h1] = axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____ASSIGN__[5'h1] & ~axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____AV__[5'h1];
  assign axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____ASSIGN__[5'h1] = axis_fifo_inst__DOT__write & (5'h1 == axis_fifo_inst__DOT__wr_addr_reg[32'h4:32'h0]);
  assign axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____VALID__[5'h1] = axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____AV_Q__[5'h1] | ~axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____ASSIGN_Q__[5'h1] & axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____VALID_Q__[5'h1];
  assign axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____AV__[5'h2] = (5'h2 == axis_fifo_inst__DOT__wr_addr_reg[32'h4:32'h0]) & (axis_fifo_inst__DOT__write & axis_fifo_inst__DOT__s_axis__BRA__7__03A0__KET____VALID__);
  assign axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____AI__[5'h2] = axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____ASSIGN__[5'h2] & ~axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____AV__[5'h2];
  assign axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____ASSIGN__[5'h2] = axis_fifo_inst__DOT__write & (5'h2 == axis_fifo_inst__DOT__wr_addr_reg[32'h4:32'h0]);
  assign axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____VALID__[5'h2] = axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____AV_Q__[5'h2] | ~axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____ASSIGN_Q__[5'h2] & axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____VALID_Q__[5'h2];
  assign axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____AV__[5'h3] = (5'h3 == axis_fifo_inst__DOT__wr_addr_reg[32'h4:32'h0]) & (axis_fifo_inst__DOT__write & axis_fifo_inst__DOT__s_axis__BRA__7__03A0__KET____VALID__);
  assign axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____AI__[5'h3] = axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____ASSIGN__[5'h3] & ~axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____AV__[5'h3];
  assign axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____ASSIGN__[5'h3] = axis_fifo_inst__DOT__write & (5'h3 == axis_fifo_inst__DOT__wr_addr_reg[32'h4:32'h0]);
  assign axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____VALID__[5'h3] = axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____AV_Q__[5'h3] | ~axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____ASSIGN_Q__[5'h3] & axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____VALID_Q__[5'h3];
  assign axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____AV__[5'h4] = (5'h4 == axis_fifo_inst__DOT__wr_addr_reg[32'h4:32'h0]) & (axis_fifo_inst__DOT__write & axis_fifo_inst__DOT__s_axis__BRA__7__03A0__KET____VALID__);
  assign axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____AI__[5'h4] = axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____ASSIGN__[5'h4] & ~axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____AV__[5'h4];
  assign axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____ASSIGN__[5'h4] = axis_fifo_inst__DOT__write & (5'h4 == axis_fifo_inst__DOT__wr_addr_reg[32'h4:32'h0]);
  assign axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____VALID__[5'h4] = axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____AV_Q__[5'h4] | ~axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____ASSIGN_Q__[5'h4] & axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____VALID_Q__[5'h4];
  assign axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____AV__[5'h5] = (5'h5 == axis_fifo_inst__DOT__wr_addr_reg[32'h4:32'h0]) & (axis_fifo_inst__DOT__write & axis_fifo_inst__DOT__s_axis__BRA__7__03A0__KET____VALID__);
  assign axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____AI__[5'h5] = axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____ASSIGN__[5'h5] & ~axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____AV__[5'h5];
  assign axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____ASSIGN__[5'h5] = axis_fifo_inst__DOT__write & (5'h5 == axis_fifo_inst__DOT__wr_addr_reg[32'h4:32'h0]);
  assign axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____VALID__[5'h5] = axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____AV_Q__[5'h5] | ~axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____ASSIGN_Q__[5'h5] & axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____VALID_Q__[5'h5];
  assign axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____AV__[5'h6] = (5'h6 == axis_fifo_inst__DOT__wr_addr_reg[32'h4:32'h0]) & (axis_fifo_inst__DOT__write & axis_fifo_inst__DOT__s_axis__BRA__7__03A0__KET____VALID__);
  assign axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____AI__[5'h6] = axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____ASSIGN__[5'h6] & ~axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____AV__[5'h6];
  assign axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____ASSIGN__[5'h6] = axis_fifo_inst__DOT__write & (5'h6 == axis_fifo_inst__DOT__wr_addr_reg[32'h4:32'h0]);
  assign axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____VALID__[5'h6] = axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____AV_Q__[5'h6] | ~axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____ASSIGN_Q__[5'h6] & axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____VALID_Q__[5'h6];
  assign axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____AV__[5'h7] = (5'h7 == axis_fifo_inst__DOT__wr_addr_reg[32'h4:32'h0]) & (axis_fifo_inst__DOT__write & axis_fifo_inst__DOT__s_axis__BRA__7__03A0__KET____VALID__);
  assign axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____AI__[5'h7] = axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____ASSIGN__[5'h7] & ~axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____AV__[5'h7];
  assign axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____ASSIGN__[5'h7] = axis_fifo_inst__DOT__write & (5'h7 == axis_fifo_inst__DOT__wr_addr_reg[32'h4:32'h0]);
  assign axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____VALID__[5'h7] = axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____AV_Q__[5'h7] | ~axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____ASSIGN_Q__[5'h7] & axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____VALID_Q__[5'h7];
  assign axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____AV__[5'h8] = (5'h8 == axis_fifo_inst__DOT__wr_addr_reg[32'h4:32'h0]) & (axis_fifo_inst__DOT__write & axis_fifo_inst__DOT__s_axis__BRA__7__03A0__KET____VALID__);
  assign axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____AI__[5'h8] = axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____ASSIGN__[5'h8] & ~axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____AV__[5'h8];
  assign axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____ASSIGN__[5'h8] = axis_fifo_inst__DOT__write & (5'h8 == axis_fifo_inst__DOT__wr_addr_reg[32'h4:32'h0]);
  assign axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____VALID__[5'h8] = axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____AV_Q__[5'h8] | ~axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____ASSIGN_Q__[5'h8] & axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____VALID_Q__[5'h8];
  assign axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____AV__[5'h9] = (5'h9 == axis_fifo_inst__DOT__wr_addr_reg[32'h4:32'h0]) & (axis_fifo_inst__DOT__write & axis_fifo_inst__DOT__s_axis__BRA__7__03A0__KET____VALID__);
  assign axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____AI__[5'h9] = axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____ASSIGN__[5'h9] & ~axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____AV__[5'h9];
  assign axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____ASSIGN__[5'h9] = axis_fifo_inst__DOT__write & (5'h9 == axis_fifo_inst__DOT__wr_addr_reg[32'h4:32'h0]);
  assign axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____VALID__[5'h9] = axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____AV_Q__[5'h9] | ~axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____ASSIGN_Q__[5'h9] & axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____VALID_Q__[5'h9];
  assign axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____AV__[5'ha] = (5'ha == axis_fifo_inst__DOT__wr_addr_reg[32'h4:32'h0]) & (axis_fifo_inst__DOT__write & axis_fifo_inst__DOT__s_axis__BRA__7__03A0__KET____VALID__);
  assign axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____AI__[5'ha] = axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____ASSIGN__[5'ha] & ~axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____AV__[5'ha];
  assign axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____ASSIGN__[5'ha] = axis_fifo_inst__DOT__write & (5'ha == axis_fifo_inst__DOT__wr_addr_reg[32'h4:32'h0]);
  assign axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____VALID__[5'ha] = axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____AV_Q__[5'ha] | ~axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____ASSIGN_Q__[5'ha] & axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____VALID_Q__[5'ha];
  assign axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____AV__[5'hb] = (5'hb == axis_fifo_inst__DOT__wr_addr_reg[32'h4:32'h0]) & (axis_fifo_inst__DOT__write & axis_fifo_inst__DOT__s_axis__BRA__7__03A0__KET____VALID__);
  assign axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____AI__[5'hb] = axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____ASSIGN__[5'hb] & ~axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____AV__[5'hb];
  assign axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____ASSIGN__[5'hb] = axis_fifo_inst__DOT__write & (5'hb == axis_fifo_inst__DOT__wr_addr_reg[32'h4:32'h0]);
  assign axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____VALID__[5'hb] = axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____AV_Q__[5'hb] | ~axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____ASSIGN_Q__[5'hb] & axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____VALID_Q__[5'hb];
  assign axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____AV__[5'hc] = (5'hc == axis_fifo_inst__DOT__wr_addr_reg[32'h4:32'h0]) & (axis_fifo_inst__DOT__write & axis_fifo_inst__DOT__s_axis__BRA__7__03A0__KET____VALID__);
  assign axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____AI__[5'hc] = axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____ASSIGN__[5'hc] & ~axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____AV__[5'hc];
  assign axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____ASSIGN__[5'hc] = axis_fifo_inst__DOT__write & (5'hc == axis_fifo_inst__DOT__wr_addr_reg[32'h4:32'h0]);
  assign axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____VALID__[5'hc] = axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____AV_Q__[5'hc] | ~axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____ASSIGN_Q__[5'hc] & axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____VALID_Q__[5'hc];
  assign axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____AV__[5'hd] = (5'hd == axis_fifo_inst__DOT__wr_addr_reg[32'h4:32'h0]) & (axis_fifo_inst__DOT__write & axis_fifo_inst__DOT__s_axis__BRA__7__03A0__KET____VALID__);
  assign axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____AI__[5'hd] = axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____ASSIGN__[5'hd] & ~axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____AV__[5'hd];
  assign axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____ASSIGN__[5'hd] = axis_fifo_inst__DOT__write & (5'hd == axis_fifo_inst__DOT__wr_addr_reg[32'h4:32'h0]);
  assign axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____VALID__[5'hd] = axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____AV_Q__[5'hd] | ~axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____ASSIGN_Q__[5'hd] & axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____VALID_Q__[5'hd];
  assign axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____AV__[5'he] = (5'he == axis_fifo_inst__DOT__wr_addr_reg[32'h4:32'h0]) & (axis_fifo_inst__DOT__write & axis_fifo_inst__DOT__s_axis__BRA__7__03A0__KET____VALID__);
  assign axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____AI__[5'he] = axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____ASSIGN__[5'he] & ~axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____AV__[5'he];
  assign axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____ASSIGN__[5'he] = axis_fifo_inst__DOT__write & (5'he == axis_fifo_inst__DOT__wr_addr_reg[32'h4:32'h0]);
  assign axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____VALID__[5'he] = axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____AV_Q__[5'he] | ~axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____ASSIGN_Q__[5'he] & axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____VALID_Q__[5'he];
  assign axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____AV__[5'hf] = (5'hf == axis_fifo_inst__DOT__wr_addr_reg[32'h4:32'h0]) & (axis_fifo_inst__DOT__write & axis_fifo_inst__DOT__s_axis__BRA__7__03A0__KET____VALID__);
  assign axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____AI__[5'hf] = axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____ASSIGN__[5'hf] & ~axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____AV__[5'hf];
  assign axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____ASSIGN__[5'hf] = axis_fifo_inst__DOT__write & (5'hf == axis_fifo_inst__DOT__wr_addr_reg[32'h4:32'h0]);
  assign axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____VALID__[5'hf] = axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____AV_Q__[5'hf] | ~axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____ASSIGN_Q__[5'hf] & axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____VALID_Q__[5'hf];
  assign axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____AV__[5'h10] = (5'h10 == axis_fifo_inst__DOT__wr_addr_reg[32'h4:32'h0]) & (axis_fifo_inst__DOT__write & axis_fifo_inst__DOT__s_axis__BRA__7__03A0__KET____VALID__);
  assign axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____AI__[5'h10] = axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____ASSIGN__[5'h10] & ~axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____AV__[5'h10];
  assign axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____ASSIGN__[5'h10] = axis_fifo_inst__DOT__write & (5'h10 == axis_fifo_inst__DOT__wr_addr_reg[32'h4:32'h0]);
  assign axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____VALID__[5'h10] = axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____AV_Q__[5'h10] | ~axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____ASSIGN_Q__[5'h10] & axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____VALID_Q__[5'h10];
  assign axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____AV__[5'h11] = (5'h11 == axis_fifo_inst__DOT__wr_addr_reg[32'h4:32'h0]) & (axis_fifo_inst__DOT__write & axis_fifo_inst__DOT__s_axis__BRA__7__03A0__KET____VALID__);
  assign axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____AI__[5'h11] = axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____ASSIGN__[5'h11] & ~axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____AV__[5'h11];
  assign axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____ASSIGN__[5'h11] = axis_fifo_inst__DOT__write & (5'h11 == axis_fifo_inst__DOT__wr_addr_reg[32'h4:32'h0]);
  assign axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____VALID__[5'h11] = axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____AV_Q__[5'h11] | ~axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____ASSIGN_Q__[5'h11] & axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____VALID_Q__[5'h11];
  assign axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____AV__[5'h12] = (5'h12 == axis_fifo_inst__DOT__wr_addr_reg[32'h4:32'h0]) & (axis_fifo_inst__DOT__write & axis_fifo_inst__DOT__s_axis__BRA__7__03A0__KET____VALID__);
  assign axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____AI__[5'h12] = axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____ASSIGN__[5'h12] & ~axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____AV__[5'h12];
  assign axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____ASSIGN__[5'h12] = axis_fifo_inst__DOT__write & (5'h12 == axis_fifo_inst__DOT__wr_addr_reg[32'h4:32'h0]);
  assign axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____VALID__[5'h12] = axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____AV_Q__[5'h12] | ~axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____ASSIGN_Q__[5'h12] & axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____VALID_Q__[5'h12];
  assign axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____AV__[5'h13] = (5'h13 == axis_fifo_inst__DOT__wr_addr_reg[32'h4:32'h0]) & (axis_fifo_inst__DOT__write & axis_fifo_inst__DOT__s_axis__BRA__7__03A0__KET____VALID__);
  assign axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____AI__[5'h13] = axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____ASSIGN__[5'h13] & ~axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____AV__[5'h13];
  assign axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____ASSIGN__[5'h13] = axis_fifo_inst__DOT__write & (5'h13 == axis_fifo_inst__DOT__wr_addr_reg[32'h4:32'h0]);
  assign axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____VALID__[5'h13] = axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____AV_Q__[5'h13] | ~axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____ASSIGN_Q__[5'h13] & axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____VALID_Q__[5'h13];
  assign axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____AV__[5'h14] = (5'h14 == axis_fifo_inst__DOT__wr_addr_reg[32'h4:32'h0]) & (axis_fifo_inst__DOT__write & axis_fifo_inst__DOT__s_axis__BRA__7__03A0__KET____VALID__);
  assign axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____AI__[5'h14] = axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____ASSIGN__[5'h14] & ~axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____AV__[5'h14];
  assign axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____ASSIGN__[5'h14] = axis_fifo_inst__DOT__write & (5'h14 == axis_fifo_inst__DOT__wr_addr_reg[32'h4:32'h0]);
  assign axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____VALID__[5'h14] = axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____AV_Q__[5'h14] | ~axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____ASSIGN_Q__[5'h14] & axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____VALID_Q__[5'h14];
  assign axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____AV__[5'h15] = (5'h15 == axis_fifo_inst__DOT__wr_addr_reg[32'h4:32'h0]) & (axis_fifo_inst__DOT__write & axis_fifo_inst__DOT__s_axis__BRA__7__03A0__KET____VALID__);
  assign axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____AI__[5'h15] = axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____ASSIGN__[5'h15] & ~axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____AV__[5'h15];
  assign axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____ASSIGN__[5'h15] = axis_fifo_inst__DOT__write & (5'h15 == axis_fifo_inst__DOT__wr_addr_reg[32'h4:32'h0]);
  assign axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____VALID__[5'h15] = axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____AV_Q__[5'h15] | ~axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____ASSIGN_Q__[5'h15] & axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____VALID_Q__[5'h15];
  assign axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____AV__[5'h16] = (5'h16 == axis_fifo_inst__DOT__wr_addr_reg[32'h4:32'h0]) & (axis_fifo_inst__DOT__write & axis_fifo_inst__DOT__s_axis__BRA__7__03A0__KET____VALID__);
  assign axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____AI__[5'h16] = axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____ASSIGN__[5'h16] & ~axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____AV__[5'h16];
  assign axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____ASSIGN__[5'h16] = axis_fifo_inst__DOT__write & (5'h16 == axis_fifo_inst__DOT__wr_addr_reg[32'h4:32'h0]);
  assign axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____VALID__[5'h16] = axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____AV_Q__[5'h16] | ~axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____ASSIGN_Q__[5'h16] & axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____VALID_Q__[5'h16];
  assign axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____AV__[5'h17] = (5'h17 == axis_fifo_inst__DOT__wr_addr_reg[32'h4:32'h0]) & (axis_fifo_inst__DOT__write & axis_fifo_inst__DOT__s_axis__BRA__7__03A0__KET____VALID__);
  assign axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____AI__[5'h17] = axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____ASSIGN__[5'h17] & ~axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____AV__[5'h17];
  assign axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____ASSIGN__[5'h17] = axis_fifo_inst__DOT__write & (5'h17 == axis_fifo_inst__DOT__wr_addr_reg[32'h4:32'h0]);
  assign axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____VALID__[5'h17] = axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____AV_Q__[5'h17] | ~axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____ASSIGN_Q__[5'h17] & axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____VALID_Q__[5'h17];
  assign axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____AV__[5'h18] = (5'h18 == axis_fifo_inst__DOT__wr_addr_reg[32'h4:32'h0]) & (axis_fifo_inst__DOT__write & axis_fifo_inst__DOT__s_axis__BRA__7__03A0__KET____VALID__);
  assign axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____AI__[5'h18] = axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____ASSIGN__[5'h18] & ~axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____AV__[5'h18];
  assign axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____ASSIGN__[5'h18] = axis_fifo_inst__DOT__write & (5'h18 == axis_fifo_inst__DOT__wr_addr_reg[32'h4:32'h0]);
  assign axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____VALID__[5'h18] = axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____AV_Q__[5'h18] | ~axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____ASSIGN_Q__[5'h18] & axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____VALID_Q__[5'h18];
  assign axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____AV__[5'h19] = (5'h19 == axis_fifo_inst__DOT__wr_addr_reg[32'h4:32'h0]) & (axis_fifo_inst__DOT__write & axis_fifo_inst__DOT__s_axis__BRA__7__03A0__KET____VALID__);
  assign axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____AI__[5'h19] = axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____ASSIGN__[5'h19] & ~axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____AV__[5'h19];
  assign axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____ASSIGN__[5'h19] = axis_fifo_inst__DOT__write & (5'h19 == axis_fifo_inst__DOT__wr_addr_reg[32'h4:32'h0]);
  assign axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____VALID__[5'h19] = axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____AV_Q__[5'h19] | ~axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____ASSIGN_Q__[5'h19] & axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____VALID_Q__[5'h19];
  assign axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____AV__[5'h1a] = (5'h1a == axis_fifo_inst__DOT__wr_addr_reg[32'h4:32'h0]) & (axis_fifo_inst__DOT__write & axis_fifo_inst__DOT__s_axis__BRA__7__03A0__KET____VALID__);
  assign axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____AI__[5'h1a] = axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____ASSIGN__[5'h1a] & ~axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____AV__[5'h1a];
  assign axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____ASSIGN__[5'h1a] = axis_fifo_inst__DOT__write & (5'h1a == axis_fifo_inst__DOT__wr_addr_reg[32'h4:32'h0]);
  assign axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____VALID__[5'h1a] = axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____AV_Q__[5'h1a] | ~axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____ASSIGN_Q__[5'h1a] & axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____VALID_Q__[5'h1a];
  assign axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____AV__[5'h1b] = (5'h1b == axis_fifo_inst__DOT__wr_addr_reg[32'h4:32'h0]) & (axis_fifo_inst__DOT__write & axis_fifo_inst__DOT__s_axis__BRA__7__03A0__KET____VALID__);
  assign axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____AI__[5'h1b] = axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____ASSIGN__[5'h1b] & ~axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____AV__[5'h1b];
  assign axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____ASSIGN__[5'h1b] = axis_fifo_inst__DOT__write & (5'h1b == axis_fifo_inst__DOT__wr_addr_reg[32'h4:32'h0]);
  assign axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____VALID__[5'h1b] = axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____AV_Q__[5'h1b] | ~axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____ASSIGN_Q__[5'h1b] & axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____VALID_Q__[5'h1b];
  assign axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____AV__[5'h1c] = (5'h1c == axis_fifo_inst__DOT__wr_addr_reg[32'h4:32'h0]) & (axis_fifo_inst__DOT__write & axis_fifo_inst__DOT__s_axis__BRA__7__03A0__KET____VALID__);
  assign axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____AI__[5'h1c] = axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____ASSIGN__[5'h1c] & ~axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____AV__[5'h1c];
  assign axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____ASSIGN__[5'h1c] = axis_fifo_inst__DOT__write & (5'h1c == axis_fifo_inst__DOT__wr_addr_reg[32'h4:32'h0]);
  assign axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____VALID__[5'h1c] = axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____AV_Q__[5'h1c] | ~axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____ASSIGN_Q__[5'h1c] & axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____VALID_Q__[5'h1c];
  assign axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____AV__[5'h1d] = (5'h1d == axis_fifo_inst__DOT__wr_addr_reg[32'h4:32'h0]) & (axis_fifo_inst__DOT__write & axis_fifo_inst__DOT__s_axis__BRA__7__03A0__KET____VALID__);
  assign axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____AI__[5'h1d] = axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____ASSIGN__[5'h1d] & ~axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____AV__[5'h1d];
  assign axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____ASSIGN__[5'h1d] = axis_fifo_inst__DOT__write & (5'h1d == axis_fifo_inst__DOT__wr_addr_reg[32'h4:32'h0]);
  assign axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____VALID__[5'h1d] = axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____AV_Q__[5'h1d] | ~axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____ASSIGN_Q__[5'h1d] & axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____VALID_Q__[5'h1d];
  assign axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____AV__[5'h1e] = (5'h1e == axis_fifo_inst__DOT__wr_addr_reg[32'h4:32'h0]) & (axis_fifo_inst__DOT__write & axis_fifo_inst__DOT__s_axis__BRA__7__03A0__KET____VALID__);
  assign axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____AI__[5'h1e] = axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____ASSIGN__[5'h1e] & ~axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____AV__[5'h1e];
  assign axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____ASSIGN__[5'h1e] = axis_fifo_inst__DOT__write & (5'h1e == axis_fifo_inst__DOT__wr_addr_reg[32'h4:32'h0]);
  assign axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____VALID__[5'h1e] = axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____AV_Q__[5'h1e] | ~axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____ASSIGN_Q__[5'h1e] & axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____VALID_Q__[5'h1e];
  assign axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____AV__[5'h1f] = (5'h1f == axis_fifo_inst__DOT__wr_addr_reg[32'h4:32'h0]) & (axis_fifo_inst__DOT__write & axis_fifo_inst__DOT__s_axis__BRA__7__03A0__KET____VALID__);
  assign axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____AI__[5'h1f] = axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____ASSIGN__[5'h1f] & ~axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____AV__[5'h1f];
  assign axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____ASSIGN__[5'h1f] = axis_fifo_inst__DOT__write & (5'h1f == axis_fifo_inst__DOT__wr_addr_reg[32'h4:32'h0]);
  assign axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____VALID__[5'h1f] = axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____AV_Q__[5'h1f] | ~axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____ASSIGN_Q__[5'h1f] & axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____VALID_Q__[5'h1f];
  assign axis_fifo_inst__DOT__s_axis__BRA__7__03A0__KET____AV__ = s_axis_tdata__VALID__;
  assign axis_fifo_inst__DOT__s_axis__BRA__7__03A0__KET____AI__ = axis_fifo_inst__DOT__s_axis__BRA__7__03A0__KET____ASSIGN__ & ~axis_fifo_inst__DOT__s_axis__BRA__7__03A0__KET____AV__;
  assign axis_fifo_inst__DOT__s_axis__BRA__7__03A0__KET____ASSIGN__ = 1'b1;
  assign axis_fifo_inst__DOT__s_axis__BRA__7__03A0__KET____VALID__ = axis_fifo_inst__DOT__s_axis__BRA__7__03A0__KET____AV__;
  assign axis_fifo_inst__DOT__m_axis_reg__BRA__7__03A0__KET____PROP__ = 1'b1;
  assign axis_fifo_inst__DOT__m_axis_reg__BRA__7__03A0__KET____GOOD__ = (rst | axis_fifo_inst__DOT__m_axis_reg__BRA__7__03A0__KET____AI_Q__) ? (1'b1) : (
                                                                        (axis_fifo_inst__DOT__m_axis_reg__BRA__7__03A0__KET____AV_Q__) ? (1'b0) : (axis_fifo_inst__DOT__m_axis_reg__BRA__7__03A0__KET____GOOD_Q__ | axis_fifo_inst__DOT__m_axis_reg__BRA__7__03A0__KET____PROP_Q__));
  assign axis_fifo_inst__DOT__mem_read_data_reg__BRA__7__03A0__KET____PROP__ = axis_fifo_inst__DOT__store_output;
  assign axis_fifo_inst__DOT__mem_read_data_reg__BRA__7__03A0__KET____GOOD__ = (rst | axis_fifo_inst__DOT__mem_read_data_reg__BRA__7__03A0__KET____AI_Q__) ? (1'b1) : (
                                                                               (axis_fifo_inst__DOT__mem_read_data_reg__BRA__7__03A0__KET____AV_Q__) ? (1'b0) : (axis_fifo_inst__DOT__mem_read_data_reg__BRA__7__03A0__KET____GOOD_Q__ | axis_fifo_inst__DOT__mem_read_data_reg__BRA__7__03A0__KET____PROP_Q__));
  assign axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____PROP__[5'h0] = (5'h0 == axis_fifo_inst__DOT__rd_addr_reg[4:0]) & axis_fifo_inst__DOT__read;
  assign axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____GOOD__[5'h0] = (rst | axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____AI_Q__[5'h0]) ? (1'b1) : (
                                                                       (axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____AV_Q__[5'h0]) ? (1'b0) : (axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____GOOD_Q__[5'h0] | axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____PROP_Q__[5'h0]));
  assign axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____PROP__[5'h1] = (5'h1 == axis_fifo_inst__DOT__rd_addr_reg[4:0]) & axis_fifo_inst__DOT__read;
  assign axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____GOOD__[5'h1] = (rst | axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____AI_Q__[5'h1]) ? (1'b1) : (
                                                                       (axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____AV_Q__[5'h1]) ? (1'b0) : (axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____GOOD_Q__[5'h1] | axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____PROP_Q__[5'h1]));
  assign axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____PROP__[5'h2] = (5'h2 == axis_fifo_inst__DOT__rd_addr_reg[4:0]) & axis_fifo_inst__DOT__read;
  assign axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____GOOD__[5'h2] = (rst | axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____AI_Q__[5'h2]) ? (1'b1) : (
                                                                       (axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____AV_Q__[5'h2]) ? (1'b0) : (axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____GOOD_Q__[5'h2] | axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____PROP_Q__[5'h2]));
  assign axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____PROP__[5'h3] = (5'h3 == axis_fifo_inst__DOT__rd_addr_reg[4:0]) & axis_fifo_inst__DOT__read;
  assign axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____GOOD__[5'h3] = (rst | axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____AI_Q__[5'h3]) ? (1'b1) : (
                                                                       (axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____AV_Q__[5'h3]) ? (1'b0) : (axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____GOOD_Q__[5'h3] | axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____PROP_Q__[5'h3]));
  assign axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____PROP__[5'h4] = (5'h4 == axis_fifo_inst__DOT__rd_addr_reg[4:0]) & axis_fifo_inst__DOT__read;
  assign axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____GOOD__[5'h4] = (rst | axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____AI_Q__[5'h4]) ? (1'b1) : (
                                                                       (axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____AV_Q__[5'h4]) ? (1'b0) : (axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____GOOD_Q__[5'h4] | axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____PROP_Q__[5'h4]));
  assign axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____PROP__[5'h5] = (5'h5 == axis_fifo_inst__DOT__rd_addr_reg[4:0]) & axis_fifo_inst__DOT__read;
  assign axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____GOOD__[5'h5] = (rst | axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____AI_Q__[5'h5]) ? (1'b1) : (
                                                                       (axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____AV_Q__[5'h5]) ? (1'b0) : (axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____GOOD_Q__[5'h5] | axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____PROP_Q__[5'h5]));
  assign axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____PROP__[5'h6] = (5'h6 == axis_fifo_inst__DOT__rd_addr_reg[4:0]) & axis_fifo_inst__DOT__read;
  assign axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____GOOD__[5'h6] = (rst | axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____AI_Q__[5'h6]) ? (1'b1) : (
                                                                       (axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____AV_Q__[5'h6]) ? (1'b0) : (axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____GOOD_Q__[5'h6] | axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____PROP_Q__[5'h6]));
  assign axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____PROP__[5'h7] = (5'h7 == axis_fifo_inst__DOT__rd_addr_reg[4:0]) & axis_fifo_inst__DOT__read;
  assign axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____GOOD__[5'h7] = (rst | axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____AI_Q__[5'h7]) ? (1'b1) : (
                                                                       (axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____AV_Q__[5'h7]) ? (1'b0) : (axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____GOOD_Q__[5'h7] | axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____PROP_Q__[5'h7]));
  assign axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____PROP__[5'h8] = (5'h8 == axis_fifo_inst__DOT__rd_addr_reg[4:0]) & axis_fifo_inst__DOT__read;
  assign axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____GOOD__[5'h8] = (rst | axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____AI_Q__[5'h8]) ? (1'b1) : (
                                                                       (axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____AV_Q__[5'h8]) ? (1'b0) : (axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____GOOD_Q__[5'h8] | axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____PROP_Q__[5'h8]));
  assign axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____PROP__[5'h9] = (5'h9 == axis_fifo_inst__DOT__rd_addr_reg[4:0]) & axis_fifo_inst__DOT__read;
  assign axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____GOOD__[5'h9] = (rst | axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____AI_Q__[5'h9]) ? (1'b1) : (
                                                                       (axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____AV_Q__[5'h9]) ? (1'b0) : (axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____GOOD_Q__[5'h9] | axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____PROP_Q__[5'h9]));
  assign axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____PROP__[5'ha] = (5'ha == axis_fifo_inst__DOT__rd_addr_reg[4:0]) & axis_fifo_inst__DOT__read;
  assign axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____GOOD__[5'ha] = (rst | axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____AI_Q__[5'ha]) ? (1'b1) : (
                                                                       (axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____AV_Q__[5'ha]) ? (1'b0) : (axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____GOOD_Q__[5'ha] | axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____PROP_Q__[5'ha]));
  assign axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____PROP__[5'hb] = (5'hb == axis_fifo_inst__DOT__rd_addr_reg[4:0]) & axis_fifo_inst__DOT__read;
  assign axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____GOOD__[5'hb] = (rst | axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____AI_Q__[5'hb]) ? (1'b1) : (
                                                                       (axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____AV_Q__[5'hb]) ? (1'b0) : (axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____GOOD_Q__[5'hb] | axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____PROP_Q__[5'hb]));
  assign axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____PROP__[5'hc] = (5'hc == axis_fifo_inst__DOT__rd_addr_reg[4:0]) & axis_fifo_inst__DOT__read;
  assign axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____GOOD__[5'hc] = (rst | axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____AI_Q__[5'hc]) ? (1'b1) : (
                                                                       (axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____AV_Q__[5'hc]) ? (1'b0) : (axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____GOOD_Q__[5'hc] | axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____PROP_Q__[5'hc]));
  assign axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____PROP__[5'hd] = (5'hd == axis_fifo_inst__DOT__rd_addr_reg[4:0]) & axis_fifo_inst__DOT__read;
  assign axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____GOOD__[5'hd] = (rst | axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____AI_Q__[5'hd]) ? (1'b1) : (
                                                                       (axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____AV_Q__[5'hd]) ? (1'b0) : (axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____GOOD_Q__[5'hd] | axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____PROP_Q__[5'hd]));
  assign axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____PROP__[5'he] = (5'he == axis_fifo_inst__DOT__rd_addr_reg[4:0]) & axis_fifo_inst__DOT__read;
  assign axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____GOOD__[5'he] = (rst | axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____AI_Q__[5'he]) ? (1'b1) : (
                                                                       (axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____AV_Q__[5'he]) ? (1'b0) : (axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____GOOD_Q__[5'he] | axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____PROP_Q__[5'he]));
  assign axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____PROP__[5'hf] = (5'hf == axis_fifo_inst__DOT__rd_addr_reg[4:0]) & axis_fifo_inst__DOT__read;
  assign axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____GOOD__[5'hf] = (rst | axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____AI_Q__[5'hf]) ? (1'b1) : (
                                                                       (axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____AV_Q__[5'hf]) ? (1'b0) : (axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____GOOD_Q__[5'hf] | axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____PROP_Q__[5'hf]));
  assign axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____PROP__[5'h10] = (5'h10 == axis_fifo_inst__DOT__rd_addr_reg[4:0]) & axis_fifo_inst__DOT__read;
  assign axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____GOOD__[5'h10] = (rst | axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____AI_Q__[5'h10]) ? (1'b1) : (
                                                                        (axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____AV_Q__[5'h10]) ? (1'b0) : (axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____GOOD_Q__[5'h10] | axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____PROP_Q__[5'h10]));
  assign axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____PROP__[5'h11] = (5'h11 == axis_fifo_inst__DOT__rd_addr_reg[4:0]) & axis_fifo_inst__DOT__read;
  assign axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____GOOD__[5'h11] = (rst | axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____AI_Q__[5'h11]) ? (1'b1) : (
                                                                        (axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____AV_Q__[5'h11]) ? (1'b0) : (axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____GOOD_Q__[5'h11] | axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____PROP_Q__[5'h11]));
  assign axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____PROP__[5'h12] = (5'h12 == axis_fifo_inst__DOT__rd_addr_reg[4:0]) & axis_fifo_inst__DOT__read;
  assign axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____GOOD__[5'h12] = (rst | axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____AI_Q__[5'h12]) ? (1'b1) : (
                                                                        (axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____AV_Q__[5'h12]) ? (1'b0) : (axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____GOOD_Q__[5'h12] | axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____PROP_Q__[5'h12]));
  assign axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____PROP__[5'h13] = (5'h13 == axis_fifo_inst__DOT__rd_addr_reg[4:0]) & axis_fifo_inst__DOT__read;
  assign axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____GOOD__[5'h13] = (rst | axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____AI_Q__[5'h13]) ? (1'b1) : (
                                                                        (axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____AV_Q__[5'h13]) ? (1'b0) : (axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____GOOD_Q__[5'h13] | axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____PROP_Q__[5'h13]));
  assign axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____PROP__[5'h14] = (5'h14 == axis_fifo_inst__DOT__rd_addr_reg[4:0]) & axis_fifo_inst__DOT__read;
  assign axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____GOOD__[5'h14] = (rst | axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____AI_Q__[5'h14]) ? (1'b1) : (
                                                                        (axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____AV_Q__[5'h14]) ? (1'b0) : (axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____GOOD_Q__[5'h14] | axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____PROP_Q__[5'h14]));
  assign axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____PROP__[5'h15] = (5'h15 == axis_fifo_inst__DOT__rd_addr_reg[4:0]) & axis_fifo_inst__DOT__read;
  assign axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____GOOD__[5'h15] = (rst | axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____AI_Q__[5'h15]) ? (1'b1) : (
                                                                        (axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____AV_Q__[5'h15]) ? (1'b0) : (axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____GOOD_Q__[5'h15] | axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____PROP_Q__[5'h15]));
  assign axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____PROP__[5'h16] = (5'h16 == axis_fifo_inst__DOT__rd_addr_reg[4:0]) & axis_fifo_inst__DOT__read;
  assign axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____GOOD__[5'h16] = (rst | axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____AI_Q__[5'h16]) ? (1'b1) : (
                                                                        (axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____AV_Q__[5'h16]) ? (1'b0) : (axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____GOOD_Q__[5'h16] | axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____PROP_Q__[5'h16]));
  assign axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____PROP__[5'h17] = (5'h17 == axis_fifo_inst__DOT__rd_addr_reg[4:0]) & axis_fifo_inst__DOT__read;
  assign axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____GOOD__[5'h17] = (rst | axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____AI_Q__[5'h17]) ? (1'b1) : (
                                                                        (axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____AV_Q__[5'h17]) ? (1'b0) : (axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____GOOD_Q__[5'h17] | axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____PROP_Q__[5'h17]));
  assign axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____PROP__[5'h18] = (5'h18 == axis_fifo_inst__DOT__rd_addr_reg[4:0]) & axis_fifo_inst__DOT__read;
  assign axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____GOOD__[5'h18] = (rst | axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____AI_Q__[5'h18]) ? (1'b1) : (
                                                                        (axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____AV_Q__[5'h18]) ? (1'b0) : (axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____GOOD_Q__[5'h18] | axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____PROP_Q__[5'h18]));
  assign axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____PROP__[5'h19] = (5'h19 == axis_fifo_inst__DOT__rd_addr_reg[4:0]) & axis_fifo_inst__DOT__read;
  assign axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____GOOD__[5'h19] = (rst | axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____AI_Q__[5'h19]) ? (1'b1) : (
                                                                        (axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____AV_Q__[5'h19]) ? (1'b0) : (axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____GOOD_Q__[5'h19] | axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____PROP_Q__[5'h19]));
  assign axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____PROP__[5'h1a] = (5'h1a == axis_fifo_inst__DOT__rd_addr_reg[4:0]) & axis_fifo_inst__DOT__read;
  assign axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____GOOD__[5'h1a] = (rst | axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____AI_Q__[5'h1a]) ? (1'b1) : (
                                                                        (axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____AV_Q__[5'h1a]) ? (1'b0) : (axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____GOOD_Q__[5'h1a] | axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____PROP_Q__[5'h1a]));
  assign axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____PROP__[5'h1b] = (5'h1b == axis_fifo_inst__DOT__rd_addr_reg[4:0]) & axis_fifo_inst__DOT__read;
  assign axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____GOOD__[5'h1b] = (rst | axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____AI_Q__[5'h1b]) ? (1'b1) : (
                                                                        (axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____AV_Q__[5'h1b]) ? (1'b0) : (axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____GOOD_Q__[5'h1b] | axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____PROP_Q__[5'h1b]));
  assign axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____PROP__[5'h1c] = (5'h1c == axis_fifo_inst__DOT__rd_addr_reg[4:0]) & axis_fifo_inst__DOT__read;
  assign axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____GOOD__[5'h1c] = (rst | axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____AI_Q__[5'h1c]) ? (1'b1) : (
                                                                        (axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____AV_Q__[5'h1c]) ? (1'b0) : (axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____GOOD_Q__[5'h1c] | axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____PROP_Q__[5'h1c]));
  assign axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____PROP__[5'h1d] = (5'h1d == axis_fifo_inst__DOT__rd_addr_reg[4:0]) & axis_fifo_inst__DOT__read;
  assign axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____GOOD__[5'h1d] = (rst | axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____AI_Q__[5'h1d]) ? (1'b1) : (
                                                                        (axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____AV_Q__[5'h1d]) ? (1'b0) : (axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____GOOD_Q__[5'h1d] | axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____PROP_Q__[5'h1d]));
  assign axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____PROP__[5'h1e] = (5'h1e == axis_fifo_inst__DOT__rd_addr_reg[4:0]) & axis_fifo_inst__DOT__read;
  assign axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____GOOD__[5'h1e] = (rst | axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____AI_Q__[5'h1e]) ? (1'b1) : (
                                                                        (axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____AV_Q__[5'h1e]) ? (1'b0) : (axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____GOOD_Q__[5'h1e] | axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____PROP_Q__[5'h1e]));
  assign axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____PROP__[5'h1f] = (5'h1f == axis_fifo_inst__DOT__rd_addr_reg[4:0]) & axis_fifo_inst__DOT__read;
  assign axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____GOOD__[5'h1f] = (rst | axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____AI_Q__[5'h1f]) ? (1'b1) : (
                                                                        (axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____AV_Q__[5'h1f]) ? (1'b0) : (axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____GOOD_Q__[5'h1f] | axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____PROP_Q__[5'h1f]));
  assign s_axis_tdata__VALID__ = s_axis_tvalid;

  always @(posedge clk) begin
    axis_fifo_inst__DOT__m_axis_reg__BRA__7__03A0__KET____AV_Q__ <= axis_fifo_inst__DOT__m_axis_reg__BRA__7__03A0__KET____AV__;
    axis_fifo_inst__DOT__m_axis_reg__BRA__7__03A0__KET____AI_Q__ <= axis_fifo_inst__DOT__m_axis_reg__BRA__7__03A0__KET____AI__;
    axis_fifo_inst__DOT__m_axis_reg__BRA__7__03A0__KET____ASSIGN_Q__ <= axis_fifo_inst__DOT__m_axis_reg__BRA__7__03A0__KET____ASSIGN__;
    axis_fifo_inst__DOT__m_axis_reg__BRA__7__03A0__KET____VALID_Q__ <= axis_fifo_inst__DOT__m_axis_reg__BRA__7__03A0__KET____VALID__;
    axis_fifo_inst__DOT__mem_read_data_reg__BRA__7__03A0__KET____AV_Q__ <= axis_fifo_inst__DOT__mem_read_data_reg__BRA__7__03A0__KET____AV__;
    axis_fifo_inst__DOT__mem_read_data_reg__BRA__7__03A0__KET____AI_Q__ <= axis_fifo_inst__DOT__mem_read_data_reg__BRA__7__03A0__KET____AI__;
    axis_fifo_inst__DOT__mem_read_data_reg__BRA__7__03A0__KET____ASSIGN_Q__ <= axis_fifo_inst__DOT__mem_read_data_reg__BRA__7__03A0__KET____ASSIGN__;
    axis_fifo_inst__DOT__mem_read_data_reg__BRA__7__03A0__KET____VALID_Q__ <= axis_fifo_inst__DOT__mem_read_data_reg__BRA__7__03A0__KET____VALID__;
    axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____AV_Q__[5'h0] <= axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____AV__[5'h0];
    axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____AI_Q__[5'h0] <= axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____AI__[5'h0];
    axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____ASSIGN_Q__[5'h0] <= axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____ASSIGN__[5'h0];
    axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____VALID_Q__[5'h0] <= axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____VALID__[5'h0];
    axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____AV_Q__[5'h1] <= axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____AV__[5'h1];
    axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____AI_Q__[5'h1] <= axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____AI__[5'h1];
    axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____ASSIGN_Q__[5'h1] <= axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____ASSIGN__[5'h1];
    axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____VALID_Q__[5'h1] <= axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____VALID__[5'h1];
    axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____AV_Q__[5'h2] <= axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____AV__[5'h2];
    axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____AI_Q__[5'h2] <= axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____AI__[5'h2];
    axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____ASSIGN_Q__[5'h2] <= axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____ASSIGN__[5'h2];
    axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____VALID_Q__[5'h2] <= axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____VALID__[5'h2];
    axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____AV_Q__[5'h3] <= axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____AV__[5'h3];
    axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____AI_Q__[5'h3] <= axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____AI__[5'h3];
    axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____ASSIGN_Q__[5'h3] <= axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____ASSIGN__[5'h3];
    axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____VALID_Q__[5'h3] <= axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____VALID__[5'h3];
    axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____AV_Q__[5'h4] <= axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____AV__[5'h4];
    axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____AI_Q__[5'h4] <= axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____AI__[5'h4];
    axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____ASSIGN_Q__[5'h4] <= axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____ASSIGN__[5'h4];
    axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____VALID_Q__[5'h4] <= axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____VALID__[5'h4];
    axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____AV_Q__[5'h5] <= axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____AV__[5'h5];
    axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____AI_Q__[5'h5] <= axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____AI__[5'h5];
    axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____ASSIGN_Q__[5'h5] <= axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____ASSIGN__[5'h5];
    axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____VALID_Q__[5'h5] <= axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____VALID__[5'h5];
    axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____AV_Q__[5'h6] <= axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____AV__[5'h6];
    axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____AI_Q__[5'h6] <= axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____AI__[5'h6];
    axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____ASSIGN_Q__[5'h6] <= axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____ASSIGN__[5'h6];
    axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____VALID_Q__[5'h6] <= axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____VALID__[5'h6];
    axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____AV_Q__[5'h7] <= axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____AV__[5'h7];
    axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____AI_Q__[5'h7] <= axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____AI__[5'h7];
    axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____ASSIGN_Q__[5'h7] <= axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____ASSIGN__[5'h7];
    axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____VALID_Q__[5'h7] <= axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____VALID__[5'h7];
    axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____AV_Q__[5'h8] <= axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____AV__[5'h8];
    axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____AI_Q__[5'h8] <= axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____AI__[5'h8];
    axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____ASSIGN_Q__[5'h8] <= axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____ASSIGN__[5'h8];
    axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____VALID_Q__[5'h8] <= axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____VALID__[5'h8];
    axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____AV_Q__[5'h9] <= axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____AV__[5'h9];
    axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____AI_Q__[5'h9] <= axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____AI__[5'h9];
    axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____ASSIGN_Q__[5'h9] <= axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____ASSIGN__[5'h9];
    axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____VALID_Q__[5'h9] <= axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____VALID__[5'h9];
    axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____AV_Q__[5'ha] <= axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____AV__[5'ha];
    axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____AI_Q__[5'ha] <= axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____AI__[5'ha];
    axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____ASSIGN_Q__[5'ha] <= axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____ASSIGN__[5'ha];
    axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____VALID_Q__[5'ha] <= axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____VALID__[5'ha];
    axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____AV_Q__[5'hb] <= axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____AV__[5'hb];
    axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____AI_Q__[5'hb] <= axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____AI__[5'hb];
    axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____ASSIGN_Q__[5'hb] <= axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____ASSIGN__[5'hb];
    axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____VALID_Q__[5'hb] <= axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____VALID__[5'hb];
    axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____AV_Q__[5'hc] <= axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____AV__[5'hc];
    axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____AI_Q__[5'hc] <= axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____AI__[5'hc];
    axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____ASSIGN_Q__[5'hc] <= axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____ASSIGN__[5'hc];
    axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____VALID_Q__[5'hc] <= axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____VALID__[5'hc];
    axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____AV_Q__[5'hd] <= axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____AV__[5'hd];
    axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____AI_Q__[5'hd] <= axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____AI__[5'hd];
    axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____ASSIGN_Q__[5'hd] <= axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____ASSIGN__[5'hd];
    axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____VALID_Q__[5'hd] <= axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____VALID__[5'hd];
    axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____AV_Q__[5'he] <= axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____AV__[5'he];
    axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____AI_Q__[5'he] <= axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____AI__[5'he];
    axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____ASSIGN_Q__[5'he] <= axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____ASSIGN__[5'he];
    axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____VALID_Q__[5'he] <= axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____VALID__[5'he];
    axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____AV_Q__[5'hf] <= axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____AV__[5'hf];
    axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____AI_Q__[5'hf] <= axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____AI__[5'hf];
    axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____ASSIGN_Q__[5'hf] <= axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____ASSIGN__[5'hf];
    axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____VALID_Q__[5'hf] <= axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____VALID__[5'hf];
    axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____AV_Q__[5'h10] <= axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____AV__[5'h10];
    axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____AI_Q__[5'h10] <= axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____AI__[5'h10];
    axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____ASSIGN_Q__[5'h10] <= axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____ASSIGN__[5'h10];
    axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____VALID_Q__[5'h10] <= axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____VALID__[5'h10];
    axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____AV_Q__[5'h11] <= axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____AV__[5'h11];
    axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____AI_Q__[5'h11] <= axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____AI__[5'h11];
    axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____ASSIGN_Q__[5'h11] <= axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____ASSIGN__[5'h11];
    axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____VALID_Q__[5'h11] <= axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____VALID__[5'h11];
    axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____AV_Q__[5'h12] <= axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____AV__[5'h12];
    axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____AI_Q__[5'h12] <= axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____AI__[5'h12];
    axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____ASSIGN_Q__[5'h12] <= axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____ASSIGN__[5'h12];
    axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____VALID_Q__[5'h12] <= axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____VALID__[5'h12];
    axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____AV_Q__[5'h13] <= axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____AV__[5'h13];
    axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____AI_Q__[5'h13] <= axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____AI__[5'h13];
    axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____ASSIGN_Q__[5'h13] <= axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____ASSIGN__[5'h13];
    axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____VALID_Q__[5'h13] <= axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____VALID__[5'h13];
    axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____AV_Q__[5'h14] <= axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____AV__[5'h14];
    axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____AI_Q__[5'h14] <= axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____AI__[5'h14];
    axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____ASSIGN_Q__[5'h14] <= axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____ASSIGN__[5'h14];
    axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____VALID_Q__[5'h14] <= axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____VALID__[5'h14];
    axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____AV_Q__[5'h15] <= axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____AV__[5'h15];
    axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____AI_Q__[5'h15] <= axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____AI__[5'h15];
    axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____ASSIGN_Q__[5'h15] <= axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____ASSIGN__[5'h15];
    axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____VALID_Q__[5'h15] <= axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____VALID__[5'h15];
    axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____AV_Q__[5'h16] <= axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____AV__[5'h16];
    axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____AI_Q__[5'h16] <= axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____AI__[5'h16];
    axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____ASSIGN_Q__[5'h16] <= axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____ASSIGN__[5'h16];
    axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____VALID_Q__[5'h16] <= axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____VALID__[5'h16];
    axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____AV_Q__[5'h17] <= axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____AV__[5'h17];
    axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____AI_Q__[5'h17] <= axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____AI__[5'h17];
    axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____ASSIGN_Q__[5'h17] <= axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____ASSIGN__[5'h17];
    axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____VALID_Q__[5'h17] <= axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____VALID__[5'h17];
    axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____AV_Q__[5'h18] <= axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____AV__[5'h18];
    axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____AI_Q__[5'h18] <= axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____AI__[5'h18];
    axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____ASSIGN_Q__[5'h18] <= axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____ASSIGN__[5'h18];
    axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____VALID_Q__[5'h18] <= axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____VALID__[5'h18];
    axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____AV_Q__[5'h19] <= axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____AV__[5'h19];
    axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____AI_Q__[5'h19] <= axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____AI__[5'h19];
    axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____ASSIGN_Q__[5'h19] <= axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____ASSIGN__[5'h19];
    axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____VALID_Q__[5'h19] <= axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____VALID__[5'h19];
    axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____AV_Q__[5'h1a] <= axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____AV__[5'h1a];
    axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____AI_Q__[5'h1a] <= axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____AI__[5'h1a];
    axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____ASSIGN_Q__[5'h1a] <= axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____ASSIGN__[5'h1a];
    axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____VALID_Q__[5'h1a] <= axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____VALID__[5'h1a];
    axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____AV_Q__[5'h1b] <= axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____AV__[5'h1b];
    axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____AI_Q__[5'h1b] <= axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____AI__[5'h1b];
    axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____ASSIGN_Q__[5'h1b] <= axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____ASSIGN__[5'h1b];
    axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____VALID_Q__[5'h1b] <= axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____VALID__[5'h1b];
    axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____AV_Q__[5'h1c] <= axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____AV__[5'h1c];
    axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____AI_Q__[5'h1c] <= axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____AI__[5'h1c];
    axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____ASSIGN_Q__[5'h1c] <= axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____ASSIGN__[5'h1c];
    axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____VALID_Q__[5'h1c] <= axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____VALID__[5'h1c];
    axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____AV_Q__[5'h1d] <= axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____AV__[5'h1d];
    axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____AI_Q__[5'h1d] <= axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____AI__[5'h1d];
    axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____ASSIGN_Q__[5'h1d] <= axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____ASSIGN__[5'h1d];
    axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____VALID_Q__[5'h1d] <= axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____VALID__[5'h1d];
    axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____AV_Q__[5'h1e] <= axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____AV__[5'h1e];
    axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____AI_Q__[5'h1e] <= axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____AI__[5'h1e];
    axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____ASSIGN_Q__[5'h1e] <= axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____ASSIGN__[5'h1e];
    axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____VALID_Q__[5'h1e] <= axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____VALID__[5'h1e];
    axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____AV_Q__[5'h1f] <= axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____AV__[5'h1f];
    axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____AI_Q__[5'h1f] <= axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____AI__[5'h1f];
    axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____ASSIGN_Q__[5'h1f] <= axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____ASSIGN__[5'h1f];
    axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____VALID_Q__[5'h1f] <= axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____VALID__[5'h1f];
    axis_fifo_inst__DOT__m_axis_reg__BRA__7__03A0__KET____PROP_Q__ <= axis_fifo_inst__DOT__m_axis_reg__BRA__7__03A0__KET____PROP__;
    axis_fifo_inst__DOT__m_axis_reg__BRA__7__03A0__KET____GOOD_Q__ <= axis_fifo_inst__DOT__m_axis_reg__BRA__7__03A0__KET____GOOD__;
    axis_fifo_inst__DOT__mem_read_data_reg__BRA__7__03A0__KET____PROP_Q__ <= axis_fifo_inst__DOT__mem_read_data_reg__BRA__7__03A0__KET____PROP__;
    axis_fifo_inst__DOT__mem_read_data_reg__BRA__7__03A0__KET____GOOD_Q__ <= axis_fifo_inst__DOT__mem_read_data_reg__BRA__7__03A0__KET____GOOD__;
    if (~(axis_fifo_inst__DOT__mem_read_data_reg__BRA__7__03A0__KET____GOOD_Q__ | axis_fifo_inst__DOT__mem_read_data_reg__BRA__7__03A0__KET____PROP_Q__) & axis_fifo_inst__DOT__mem_read_data_reg__BRA__7__03A0__KET____ASSIGN_Q__) $display("[%0t] %%loss: axis_fifo_wrapper.axis_fifo_inst__DOT__mem_read_data_reg 'd7 'd0 None None", $time ) /*debug_display_flowguard*/; 
    axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____PROP_Q__[5'h0] <= axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____PROP__[5'h0];
    axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____GOOD_Q__[5'h0] <= axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____GOOD__[5'h0];
    axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____PROP_Q__[5'h1] <= axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____PROP__[5'h1];
    axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____GOOD_Q__[5'h1] <= axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____GOOD__[5'h1];
    axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____PROP_Q__[5'h2] <= axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____PROP__[5'h2];
    axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____GOOD_Q__[5'h2] <= axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____GOOD__[5'h2];
    axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____PROP_Q__[5'h3] <= axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____PROP__[5'h3];
    axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____GOOD_Q__[5'h3] <= axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____GOOD__[5'h3];
    axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____PROP_Q__[5'h4] <= axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____PROP__[5'h4];
    axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____GOOD_Q__[5'h4] <= axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____GOOD__[5'h4];
    axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____PROP_Q__[5'h5] <= axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____PROP__[5'h5];
    axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____GOOD_Q__[5'h5] <= axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____GOOD__[5'h5];
    axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____PROP_Q__[5'h6] <= axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____PROP__[5'h6];
    axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____GOOD_Q__[5'h6] <= axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____GOOD__[5'h6];
    axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____PROP_Q__[5'h7] <= axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____PROP__[5'h7];
    axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____GOOD_Q__[5'h7] <= axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____GOOD__[5'h7];
    axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____PROP_Q__[5'h8] <= axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____PROP__[5'h8];
    axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____GOOD_Q__[5'h8] <= axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____GOOD__[5'h8];
    axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____PROP_Q__[5'h9] <= axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____PROP__[5'h9];
    axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____GOOD_Q__[5'h9] <= axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____GOOD__[5'h9];
    axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____PROP_Q__[5'ha] <= axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____PROP__[5'ha];
    axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____GOOD_Q__[5'ha] <= axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____GOOD__[5'ha];
    axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____PROP_Q__[5'hb] <= axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____PROP__[5'hb];
    axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____GOOD_Q__[5'hb] <= axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____GOOD__[5'hb];
    axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____PROP_Q__[5'hc] <= axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____PROP__[5'hc];
    axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____GOOD_Q__[5'hc] <= axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____GOOD__[5'hc];
    axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____PROP_Q__[5'hd] <= axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____PROP__[5'hd];
    axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____GOOD_Q__[5'hd] <= axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____GOOD__[5'hd];
    axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____PROP_Q__[5'he] <= axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____PROP__[5'he];
    axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____GOOD_Q__[5'he] <= axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____GOOD__[5'he];
    axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____PROP_Q__[5'hf] <= axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____PROP__[5'hf];
    axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____GOOD_Q__[5'hf] <= axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____GOOD__[5'hf];
    axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____PROP_Q__[5'h10] <= axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____PROP__[5'h10];
    axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____GOOD_Q__[5'h10] <= axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____GOOD__[5'h10];
    axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____PROP_Q__[5'h11] <= axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____PROP__[5'h11];
    axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____GOOD_Q__[5'h11] <= axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____GOOD__[5'h11];
    axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____PROP_Q__[5'h12] <= axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____PROP__[5'h12];
    axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____GOOD_Q__[5'h12] <= axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____GOOD__[5'h12];
    axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____PROP_Q__[5'h13] <= axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____PROP__[5'h13];
    axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____GOOD_Q__[5'h13] <= axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____GOOD__[5'h13];
    axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____PROP_Q__[5'h14] <= axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____PROP__[5'h14];
    axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____GOOD_Q__[5'h14] <= axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____GOOD__[5'h14];
    axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____PROP_Q__[5'h15] <= axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____PROP__[5'h15];
    axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____GOOD_Q__[5'h15] <= axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____GOOD__[5'h15];
    axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____PROP_Q__[5'h16] <= axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____PROP__[5'h16];
    axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____GOOD_Q__[5'h16] <= axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____GOOD__[5'h16];
    axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____PROP_Q__[5'h17] <= axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____PROP__[5'h17];
    axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____GOOD_Q__[5'h17] <= axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____GOOD__[5'h17];
    axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____PROP_Q__[5'h18] <= axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____PROP__[5'h18];
    axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____GOOD_Q__[5'h18] <= axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____GOOD__[5'h18];
    axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____PROP_Q__[5'h19] <= axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____PROP__[5'h19];
    axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____GOOD_Q__[5'h19] <= axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____GOOD__[5'h19];
    axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____PROP_Q__[5'h1a] <= axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____PROP__[5'h1a];
    axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____GOOD_Q__[5'h1a] <= axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____GOOD__[5'h1a];
    axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____PROP_Q__[5'h1b] <= axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____PROP__[5'h1b];
    axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____GOOD_Q__[5'h1b] <= axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____GOOD__[5'h1b];
    axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____PROP_Q__[5'h1c] <= axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____PROP__[5'h1c];
    axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____GOOD_Q__[5'h1c] <= axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____GOOD__[5'h1c];
    axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____PROP_Q__[5'h1d] <= axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____PROP__[5'h1d];
    axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____GOOD_Q__[5'h1d] <= axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____GOOD__[5'h1d];
    axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____PROP_Q__[5'h1e] <= axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____PROP__[5'h1e];
    axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____GOOD_Q__[5'h1e] <= axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____GOOD__[5'h1e];
    axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____PROP_Q__[5'h1f] <= axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____PROP__[5'h1f];
    axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____GOOD_Q__[5'h1f] <= axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____GOOD__[5'h1f];
    array_pointer_delay_0 <= axis_fifo_inst__DOT__wr_addr_reg[32'h4:32'h0];
    if (~(axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____GOOD_Q__[array_pointer_delay_0] | axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____PROP_Q__[array_pointer_delay_0]) & axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____ASSIGN_Q__[array_pointer_delay_0]) $display("[%0t] %%loss: axis_fifo_wrapper.axis_fifo_inst__DOT__mem 'd7 'd0 axis_fifo_wrapper.array_pointer_delay_0 PartSelect ptr=h%h", $time , array_pointer_delay_0) /*debug_display_flowguard*/; 
  end

  always @(posedge clk) begin
    if (rst) TASKPASS_cycle_counter <= 64'h0; 
    else TASKPASS_cycle_counter <= (TASKPASS_cycle_counter + 64'h1);
  end
  wire display_cond_0 ;
  assign display_cond_0 = (axis_fifo_inst__DOT__mem_read_data_reg__BRA__7__03A0__KET____ASSIGN_Q__ && !axis_fifo_inst__DOT__mem_read_data_reg__BRA__7__03A0__KET____GOOD_Q__ && !axis_fifo_inst__DOT__mem_read_data_reg__BRA__7__03A0__KET____PROP_Q__);
  wire display_cond_1 ;
  assign display_cond_1 = (axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____ASSIGN_Q__[array_pointer_delay_0] && !axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____GOOD_Q__[array_pointer_delay_0] && !axis_fifo_inst__DOT__mem__BRA__7__03A0__KET____PROP_Q__[array_pointer_delay_0]);

  ila_0
  ila_inst_0
  (
    .clk(clk),
    .probe0({ display_cond_0, display_cond_1, TASKPASS_cycle_counter, array_pointer_delay_0 }),
    .probe1(display_cond_0 || display_cond_1)
  );


endmodule
