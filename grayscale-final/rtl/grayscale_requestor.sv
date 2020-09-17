// grayscale_requestor.sv

import ccip_if_pkg::*;
import grayscale_pkg::*;

module grayscale_requestor
(
  input  logic           clk,
  input  logic           reset,
  input  logic [31:0]    hc_control,
  input  t_hc_address    hc_dsm_base,
  input  t_hc_buffer     hc_buffer[HC_BUFFER_SIZE],
  input  logic [511:0]   data_in,
  input  logic           valid_in,
  input  t_if_ccip_Rx    ccip_rx,
  output t_if_ccip_c0_Tx ccip_c0_tx,
  output t_if_ccip_c1_Tx ccip_c1_tx,
  output logic [511:0]   data_out,
  output logic           valid_out
);

  t_block enq_data;
  t_block deq_data;

  logic enq_en;
  logic not_full;
  logic deq_en;
  logic not_empty;

  logic [7:0] counter;
  logic [7:0] dec_counter;

  grayscale_fifo uu_grayscale_fifo
  (
    .clk         (clk),
    .reset       (reset),
    .enq_data    (enq_data),
    .enq_en      (enq_en),
    .not_full    (not_full),
    .deq_data    (deq_data),
    .deq_en      (deq_en),
    .not_empty   (not_empty),
    .counter     (counter),
    .dec_counter (dec_counter)
  );

  logic not_full_q;
  always_ff@(posedge clk) begin
    if (reset) begin
      not_full_q <= 0;
    end
    else begin
      not_full_q <= not_full;
      if (~not_full_q && enq_en) begin
        $display("fifo overflow");
        $finish;
      end
    end
  end

  //
  // read state FSM
  //

  logic [31:0] cnt_request;

  t_ccip_clAddr rd_offset;

  t_rd_state rd_state;
  t_rd_state rd_next_state;

  t_ccip_c0_ReqMemHdr rd_hdr;

  always_ff@(posedge clk or posedge reset) begin
    if (reset) begin
      cnt_request <= '0;
    end
    else begin
      logic [31:0] request;
      logic [31:0] response;

      if ((rd_state == S_RD_FETCH) &&
        (cnt_request < 'd33) &&
        !ccip_rx.c0TxAlmFull) begin

        request = 32'h1;
      end
      else begin
        request = 32'h0;
      end

      if ((ccip_rx.c0.rspValid) &&
        (ccip_rx.c0.hdr.resp_type == eRSP_RDLINE)) begin
        response = 32'h1;
      end
      else begin
        response = 32'h0;
      end

      cnt_request <= cnt_request + request - response;
    end
  end

  always_ff@(posedge clk or posedge reset) begin
    if (reset) begin
      ccip_c0_tx.valid    <= 1'b0;
      rd_offset           <= '0;

      rd_hdr = t_ccip_c0_ReqMemHdr'(0);
    end
    else begin
      case (rd_state)
      S_RD_IDLE:
        begin
          ccip_c0_tx.valid <= 1'b0;
        end

      S_RD_FETCH:
        begin
          if (cnt_request > 'd32) begin
            ccip_c0_tx.valid <= 1'b0;
          end
          else if (!ccip_rx.c0TxAlmFull) begin
            rd_hdr.cl_len  = eCL_LEN_1;
            rd_hdr.address = hc_buffer[1].address + rd_offset;

            ccip_c0_tx.valid    <= 1'b1;
            ccip_c0_tx.hdr      <= rd_hdr;
            rd_offset           <= t_ccip_clAddr'(rd_offset + 1);
          end
          else begin
            ccip_c0_tx.valid <= 1'b0;
          end
        end

      S_RD_FINISH:
        begin
          ccip_c0_tx.valid <= 1'b0;
        end
      endcase
    end
  end

  always_ff@(posedge clk or posedge reset) begin
    if (reset) begin
      rd_state <= S_RD_IDLE;
    end
    else begin
      rd_state <= rd_next_state;
    end
  end

  always_comb begin
    rd_next_state = rd_state;

    case (rd_state)
    S_RD_IDLE:
      begin
        if (hc_control == HC_CONTROL_START) begin
          rd_next_state = S_RD_FETCH;
        end
      end

    S_RD_FETCH:
      begin
        if (!ccip_rx.c0TxAlmFull && ((rd_offset + 1) == hc_buffer[1].size)) begin
          rd_next_state = S_RD_FINISH;
        end
      end
    endcase
  end

  // Receive data (read responses).
  always_ff @(posedge clk or posedge reset) begin
    if (reset) begin
      data_out  <= '0;
      valid_out <= 1'b0;
    end
    else begin
      if ((ccip_rx.c0.rspValid) &&
        (ccip_rx.c0.hdr.resp_type == eRSP_RDLINE)) begin

        data_out  <= ccip_rx.c0.data;
        valid_out <= 1'b1;
      end
      else begin
        valid_out <= 1'b0;
      end
    end
  end

  //
  // write state FSM
  //

  t_wr_state wr_state;
  t_wr_state wr_next_state;

  t_ccip_clAddr wr_offset;
  t_ccip_clAddr wr_rsp_cnt;

  t_ccip_c1_ReqMemHdr wr_hdr;

  always_ff @(posedge clk or posedge reset) begin
    if (reset) begin
      enq_en   <= 1'b0;
      enq_data <= '0;
    end
    else begin
      if (valid_in) begin
        enq_en   <= 1'b1;
        enq_data <= data_in;
      end
      else begin
        enq_en <= 1'b0;
      end
    end
  end

  // Receive data (write responses).
  always_ff @(posedge clk or posedge reset) begin
    if (reset) begin
      wr_rsp_cnt <= '0;
    end
    else begin
      if ((ccip_rx.c1.rspValid) &&
        (ccip_rx.c1.hdr.resp_type == eRSP_WRLINE)) begin

        wr_rsp_cnt <= t_ccip_clAddr'(wr_rsp_cnt + 1);
      end
    end
  end

  always_ff @(posedge clk) begin
    if (reset) begin
      deq_en     <= '0;
      wr_offset  <= '0;

      wr_hdr = t_ccip_c1_ReqMemHdr'(0);
      ccip_c1_tx.hdr   <= wr_hdr;
      ccip_c1_tx.valid <= 1'b0;
    end
    else begin
      case (wr_state)
      S_WR_IDLE:
        begin
          ccip_c1_tx.valid <= 1'b0;
        end

      S_WR_DATA:
        begin
          if (deq_en && (counter == 1)) begin
            deq_en <= 1'b0;

            ccip_c1_tx.valid <= 1'b0;
          end
          else if (!ccip_rx.c1TxAlmFull && not_empty) begin
            wr_hdr.address = hc_buffer[0].address + wr_offset;
            wr_hdr.sop = 1'b1;

            deq_en <= 1'b1;

            ccip_c1_tx.hdr   <= wr_hdr;
            ccip_c1_tx.valid <= 1'b1;
            wr_offset        <= t_ccip_clAddr'(wr_offset + 1);
          end
          else begin
            deq_en <= 1'b0;

            ccip_c1_tx.valid <= 1'b0;
          end
        end

      S_WR_FINISH_1:
        begin
          if (!ccip_rx.c1TxAlmFull && (wr_rsp_cnt == hc_buffer[0].size)) begin
            wr_hdr.address = hc_dsm_base;
            wr_hdr.sop = 1'b1;

            ccip_c1_tx.hdr   <= wr_hdr;
            ccip_c1_tx.valid <= 1'b1;
          end
          else begin
            ccip_c1_tx.valid <= 1'b0;
          end
        end

      S_WR_FINISH_2:
        begin
          ccip_c1_tx.valid <= 1'b0;
        end

      endcase
    end
  end

  always_comb begin
    case (wr_state)
      S_WR_DATA: ccip_c1_tx.data = t_ccip_clData'(deq_data);
      default  : ccip_c1_tx.data = t_ccip_clData'('h1);
    endcase
  end

  always_ff@(posedge clk or posedge reset) begin
    if (reset) begin
      wr_state <= S_WR_IDLE;
    end
    else begin
      wr_state <= wr_next_state;
    end
  end

  always_comb begin
    wr_next_state = wr_state;

    case (wr_state)
      S_WR_IDLE:
        begin
          if (hc_control == HC_CONTROL_START) begin
            wr_next_state = S_WR_DATA;
          end
        end

      S_WR_DATA:
        begin
          if (wr_offset == hc_buffer[0].size) begin
            wr_next_state = S_WR_FINISH_1;
          end
        end

      S_WR_FINISH_1:
        begin
          if (!ccip_rx.c1TxAlmFull && (wr_rsp_cnt == hc_buffer[0].size)) begin
            wr_next_state = S_WR_FINISH_2;
          end
        end
    endcase
  end

endmodule : grayscale_requestor

