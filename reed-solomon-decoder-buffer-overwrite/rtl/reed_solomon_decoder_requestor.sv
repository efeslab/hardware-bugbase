// reed_solomon_decoder_requestor.sv

import ccip_if_pkg::*;
import reed_solomon_decoder_pkg::*;

module reed_solomon_decoder_requestor
#(
  parameter REED_SOLOMON_DECODER_FIFO_DEPTH = 512
)
(
  input  logic           clk,
  input  logic           reset,
  input  logic [31:0]    hc_control,
  input  t_hc_address    hc_dsm_base,
  input  t_hc_buffer     hc_buffer[HC_BUFFER_SIZE],
  input  logic [7:0]     data_in,
  input  logic           valid_in,
  input  t_if_ccip_Rx    ccip_rx,
  output t_if_ccip_c0_Tx ccip_c0_tx,
  output t_if_ccip_c1_Tx ccip_c1_tx,
  output logic [7:0]     data_out,
  output logic           valid_out
);

  t_block     enq_data;
  logic [7:0] deq_data;

  logic enq_en;
  logic not_full;
  logic deq_en;
  logic not_empty;

  logic [$clog2(REED_SOLOMON_DECODER_FIFO_DEPTH):0] counter;
  logic [$clog2(REED_SOLOMON_DECODER_FIFO_DEPTH):0] dec_counter;

  reed_solomon_decoder_fifo
  #(
    REED_SOLOMON_DECODER_FIFO_DEPTH
  )
  uu_reed_solomon_decoder_fifo
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

  //
  // send data to reed_solomon_decoder
  //
  t_rd_state rd_state;

  logic [3:0] wait_module = 4'h0;

  assign data_out = deq_data;

  always_ff@(posedge clk or posedge reset) begin
    if (reset) begin
      deq_en      <= '0;
      valid_out   <= '0;
      wait_module <= '0;
    end
    else begin
      if (((counter > 0) && (wait_module == '0)) ||
        ((rd_state == S_RD_FINISH) && (wait_module == '0))) begin
        deq_en      <= 1'b1;
        valid_out   <= 1'b1;
        wait_module <= 4'h7;
      end
      else begin
        deq_en      <= 1'b0;
        valid_out   <= 1'b0;
        wait_module <= (wait_module != '0) ? wait_module - 4'h1 : '0;
      end
    end
  end

  //
  // read state FSM
  //

  logic [$clog2(REED_SOLOMON_DECODER_FIFO_DEPTH):0] cnt_request;

  t_rd_state rd_next_state;

  t_ccip_c0_ReqMemHdr rd_hdr;

  t_ccip_clAddr rd_offset;

  always_ff@(posedge clk or posedge reset) begin
    if (reset) begin
      cnt_request <= '0;
    end
    else begin
      logic [$clog2(REED_SOLOMON_DECODER_FIFO_DEPTH):0] request;
      logic [$clog2(REED_SOLOMON_DECODER_FIFO_DEPTH):0] response;

      if ((rd_state == S_RD_FETCH) &&
        (cnt_request + counter + 128 < REED_SOLOMON_DECODER_FIFO_DEPTH) &&
        !ccip_rx.c0TxAlmFull) begin

        request = 32'd64;
      end
      else begin
        request = '0;
      end

      if ((ccip_rx.c0.rspValid) &&
        (ccip_rx.c0.hdr.resp_type == eRSP_RDLINE)) begin
        response = 32'd64;
      end
      else begin
        response = '0;
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
          if (cnt_request + counter + 128 >= REED_SOLOMON_DECODER_FIFO_DEPTH) begin
            ccip_c0_tx.valid <= 1'b0;
          end
          else if (!ccip_rx.c0TxAlmFull) begin
            rd_hdr.cl_len  = eCL_LEN_1;
            rd_hdr.address = hc_buffer[1].address + rd_offset;

            ccip_c0_tx.valid <= 1'b1;
            ccip_c0_tx.hdr   <= rd_hdr;
            rd_offset        <= t_ccip_clAddr'(rd_offset + 1);
          end
          else begin
            ccip_c0_tx.valid <= 1'b0;
          end
        end

      S_RD_WAIT:
        begin
          ccip_c0_tx.valid <= 1'b0;
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
        if (cnt_request + counter + 64 >= REED_SOLOMON_DECODER_FIFO_DEPTH) begin
          rd_next_state = S_RD_WAIT;
        end
        else if (!ccip_rx.c0TxAlmFull && (rd_offset == hc_buffer[1].size)) begin
          rd_next_state = S_RD_FINISH;
        end
      end

    S_RD_WAIT:
      begin
        if (cnt_request < REED_SOLOMON_DECODER_FIFO_DEPTH) begin
          rd_next_state = S_RD_FETCH;
        end
      end

    endcase
  end

  // Receive data (read responses).
  always_ff @(posedge clk or posedge reset) begin
    if (reset) begin
      enq_en   <= '0;
      enq_data <= '0;
    end
    else begin
      if ((ccip_rx.c0.rspValid) &&
        (ccip_rx.c0.hdr.resp_type == eRSP_RDLINE)) begin

        enq_en   <= 1'b1;
        enq_data <= ccip_rx.c0.data;
      end
      else begin
        enq_en <= 1'b0;
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

  logic [7:0] data[64];
  logic [5:0] wr_ptr;

  always_ff @(posedge clk or posedge reset) begin
    if (reset) begin
      for (int i = 0; i < 64; i++) begin
        data[i] <= '0;
      end

      wr_ptr <= '0;
    end
    else begin
      if (valid_in) begin
        data[63 - wr_ptr] <= data_in;
        wr_ptr            <= wr_ptr + 1;
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
      wr_offset  <= '0;

      wr_hdr = t_ccip_c1_ReqMemHdr'(0);
      ccip_c1_tx.hdr   <= wr_hdr;
      ccip_c1_tx.valid <= 1'b0;
      ccip_c1_tx.data  <= t_ccip_clData'('0);
    end
    else begin
      case (wr_state)
      S_WR_IDLE:
        begin
          ccip_c1_tx.valid <= 1'b0;
        end

      S_WR_WAIT:
        begin
          ccip_c1_tx.valid <= 1'b0;
        end

      S_WR_DATA:
        begin
          if (!ccip_rx.c1TxAlmFull) begin
            wr_hdr.address = hc_buffer[0].address + wr_offset;
            wr_hdr.sop = 1'b1;

            ccip_c1_tx.hdr   <= wr_hdr;
            ccip_c1_tx.valid <= 1'b1;

            // ccip_c1_tx.data  <= t_ccip_clData'(data);
            // change to the following for verilator
            for (int i = 0; i < 64; i++) begin
                ccip_c1_tx.data[i*8+7-:8] <= data[i];
            end

            wr_offset        <= t_ccip_clAddr'(wr_offset + 1);
          end
          else begin
            ccip_c1_tx.valid <= 1'b0;
            /* How to add this assertion? */
            if (wr_ptr == 6'h0 && valid_in) begin
              $error("requestor: write combining buffer overwrite"); /* verilator tag debug_display */
            end
          end
        end

      S_WR_FINISH_1:
        begin
          if (!ccip_rx.c1TxAlmFull && (wr_rsp_cnt == hc_buffer[0].size)) begin
            wr_hdr.address = hc_dsm_base;
            wr_hdr.sop = 1'b1;

            ccip_c1_tx.hdr   <= wr_hdr;
            ccip_c1_tx.valid <= 1'b1;
            ccip_c1_tx.data  <= t_ccip_clData'('h1);
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
            wr_next_state = S_WR_WAIT;
          end
        end

      S_WR_WAIT:
        begin
          if (valid_in && (wr_ptr == '1)) begin
            wr_next_state = S_WR_DATA;
          end
          else if (wr_offset == hc_buffer[0].size) begin
            wr_next_state = S_WR_FINISH_1;
          end
        end

      S_WR_DATA:
        begin
          if (!ccip_rx.c1TxAlmFull) begin
            wr_next_state = S_WR_WAIT;
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

endmodule : reed_solomon_decoder_requestor

