import ccip_if_pkg::*;

module ccip_std_afu_async
(
  // CCI-P Clocks and Resets
  input  logic         pClk,               // 400MHz - CCI-P clock domain. Primary interface clock
  input  logic         pClkDiv2,           // 200MHz - CCI-P clock domain.
  input  logic         pClkDiv4,           // 100MHz - CCI-P clock domain.
  input  logic         uClk_usr,           // User clock domain. Refer to clock programming guide  ** Currently provides fixed 300MHz clock **
  input  logic         uClk_usrDiv2,       // User clock domain. Half the programmed frequency  ** Currently provides fixed 150MHz clock **
  input  logic         pck_cp2af_softReset,// CCI-P ACTIVE HIGH Soft Reset
  input  logic [1:0]   pck_cp2af_pwrState, // CCI-P AFU Power State
  input  logic         pck_cp2af_error,    // CCI-P Protocol Error Detected

  // Interface structures
  input  t_if_ccip_Rx  pck_cp2af_sRx,      // CCI-P Rx Port
  output t_if_ccip_Tx  pck_af2cp_sTx       // CCI-P Tx Port
);

	t_if_ccip_Rx sRx;
	t_if_ccip_Tx sTx;

	assign sRx = pck_cp2af_sRx;
	assign pck_af2cp_sTx = sTx;

	ccip_std_afu_wrapper_slow wrapped_afu(
		.pClk(pClk),
		.pClkDiv2(pClkDiv2),
		.pClkDiv4(pClkDiv4),
		.pck_cp2af_softReset(pck_cp2af_softReset),
		.c0TxAlmFull(sRx.c0TxAlmFull),
		.c1TxAlmFull(sRx.c1TxAlmFull),
		.c0Rx_hdr(sRx.c0.hdr),
		.c0Rx_data(sRx.c0.data),
		.c0Rx_rspValid(sRx.c0.rspValid),
		.c0Rx_mmioRdValid(sRx.c0.mmioRdValid),
		.c0Rx_mmioWrValid(sRx.c0.mmioWrValid),
		.c1Rx_hdr(sRx.c1.hdr),
		.c1Rx_rspValid(sRx.c1.rspValid),
		.c0Tx_hdr(sTx.c0.hdr),
		.c0Tx_valid(sTx.c0.valid),
		.c1Tx_hdr(sTx.c1.hdr),
		.c1Tx_data(sTx.c1.data),
		.c1Tx_valid(sTx.c1.valid),
		.c2Tx_hdr(sTx.c2.hdr),
		.c2Tx_mmioRdValid(sTx.c2.mmioRdValid),
		.c2Tx_data(sTx.c2.data)
	);

endmodule

module ccip_std_afu_async_connect
(
  // CCI-P Clocks and Resets
  input           logic             pClk,       
  input           logic             pClkDiv2,   
  input           logic             pClkDiv4,   
  input           logic             uClk_usr,   
  input           logic             uClk_usrDiv2,
  input           logic             pck_cp2af_softReset,
  input           logic [1:0]       pck_cp2af_pwrState, 
  input           logic             pck_cp2af_error,    
  // Interface structures
  input           t_if_ccip_Rx      pck_cp2af_sRx,      
  output          t_if_ccip_Tx      pck_af2cp_sTx       
);

   logic 	  reset_pass;   
   logic 	  afu_clk;   

   t_if_ccip_Tx afu_tx;
   t_if_ccip_Rx afu_rx;
   
   assign afu_clk = pClkDiv2 ;
   
   ccip_async_shim ccip_async_shim (
				    .bb_softreset    (pck_cp2af_softReset),
				    .bb_clk          (pClk),
				    .bb_tx           (pck_af2cp_sTx),
				    .bb_rx           (pck_cp2af_sRx),
				    .afu_softreset   (reset_pass),
				    .afu_clk         (afu_clk),
				    .afu_tx          (afu_tx),
				    .afu_rx          (afu_rx)
				    );
   

   ccip_std_afu_async afu_async (
		      .pClk( afu_clk ) ,
		      .pck_cp2af_softReset( reset_pass ) ,
		      .pck_cp2af_sRx( afu_rx ) ,
		      .pck_af2cp_sTx( afu_tx ) 
		      );

endmodule
// (C) 2001-2016 Altera Corporation. All rights reserved.
// Your use of Altera Corporation's design tools, logic functions and other 
// software and tools, and its AMPP partner logic functions, and any output 
// files any of the foregoing (including device programming or simulation 
// files), and any associated documentation or information are expressly subject 
// to the terms and conditions of the Altera Program License Subscription 
// Agreement, Altera MegaCore Function License Agreement, or other applicable 
// license agreement, including, without limitation, that your use is for the 
// sole purpose of programming logic devices manufactured by Altera and sold by 
// Altera or its authorized distributors.  Please refer to the applicable 
// agreement for further details.


//
// Taken from a Qsys-generated instance of a DCFIFO.
//


// synopsys translate_off
`timescale 1 ps / 1 ps
// synopsys translate_on

module ccip_afifo_channel
  #(
    parameter DATA_WIDTH = 32,
    parameter DEPTH_RADIX = 9
    )
   (
    aclr,
    data,
    rdclk,
    rdreq,
    wrclk,
    wrreq,
    q,
    rdempty,
    rdfull,
    rdusedw,
    wrempty,
    wrfull,
    wrusedw);

   input    aclr;
   input [DATA_WIDTH-1:0] data;
   input 		  rdclk;
   input 		  rdreq;
   input 		  wrclk;
   input 		  wrreq;
   output [DATA_WIDTH-1:0] q;
   output 		   rdempty;
   output 		   rdfull;
   output [DEPTH_RADIX-1:0] rdusedw;
   output 		    wrempty;
   output 		    wrfull;
   output [DEPTH_RADIX-1:0] wrusedw;
`ifndef ALTERA_RESERVED_QIS
   // synopsys translate_off
`endif
   tri0 		    aclr;
`ifndef ALTERA_RESERVED_QIS
   // synopsys translate_on
`endif
   
   wire [DATA_WIDTH-1:0]    sub_wire0;
   wire 		    sub_wire1;
   wire 		    sub_wire2;
   wire [DEPTH_RADIX-1:0]   sub_wire3;
   wire 		    sub_wire4;
   wire 		    sub_wire5;
   wire [DEPTH_RADIX-1:0]   sub_wire6;
   wire [DATA_WIDTH-1:0]    q = sub_wire0[DATA_WIDTH-1:0];
   wire 		    rdempty = sub_wire1;
   wire 		    rdfull = sub_wire2;
   wire [DEPTH_RADIX-1:0]   rdusedw = sub_wire3[DEPTH_RADIX-1:0];
   wire 		    wrempty = sub_wire4;
   wire 		    wrfull = sub_wire5;
   wire [DEPTH_RADIX-1:0]   wrusedw = sub_wire6[DEPTH_RADIX-1:0];

   dcfifo  dcfifo_component (
			     .aclr (aclr),
			     .data (data),
			     .rdclk (rdclk),
			     .rdreq (rdreq),
			     .wrclk (wrclk),
			     .wrreq (wrreq),
			     .q (sub_wire0),
			     .rdempty (sub_wire1),
			     .rdfull (sub_wire2),
			     .rdusedw (sub_wire3),
			     .wrempty (sub_wire4),
			     .wrfull (sub_wire5),
			     .wrusedw (sub_wire6),
			     .eccstatus ());
   defparam
     dcfifo_component.add_usedw_msb_bit  = "ON",
     dcfifo_component.enable_ecc  = "FALSE",
     dcfifo_component.lpm_hint  = "DISABLE_DCFIFO_EMBEDDED_TIMING_CONSTRAINT=TRUE",
     dcfifo_component.lpm_numwords  = 2**DEPTH_RADIX,
     dcfifo_component.lpm_showahead  = "OFF",
     dcfifo_component.lpm_type  = "dcfifo",
     dcfifo_component.lpm_width  = DATA_WIDTH,
     dcfifo_component.lpm_widthu  = DEPTH_RADIX,
     dcfifo_component.overflow_checking  = "ON",
     dcfifo_component.rdsync_delaypipe  = 5,
     dcfifo_component.read_aclr_synch  = "ON",
     dcfifo_component.underflow_checking  = "ON",
     dcfifo_component.use_eab  = "ON",
     dcfifo_component.write_aclr_synch  = "ON",
     dcfifo_component.wrsync_delaypipe  = 5;


endmodule
//
// Copyright (c) 2017, Intel Corporation
// All rights reserved.
//
// Redistribution and use in source and binary forms, with or without
// modification, are permitted provided that the following conditions are met:
//
// Redistributions of source code must retain the above copyright notice, this
// list of conditions and the following disclaimer.
//
// Redistributions in binary form must reproduce the above copyright notice,
// this list of conditions and the following disclaimer in the documentation
// and/or other materials provided with the distribution.
//
// Neither the name of the Intel Corporation nor the names of its contributors
// may be used to endorse or promote products derived from this software
// without specific prior written permission.
//
// THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
// AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
// IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
// ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE
// LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
// CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
// SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
// INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
// CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
// ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
// POSSIBILITY OF SUCH DAMAGE.

//
// Track pending response counts on CCI-P channels.  These counts may be
// used for handing out request credits when responses are buffered.
//

import ccip_if_pkg::*;

module ccip_async_c0_active_cnt
  #(
    parameter C0RX_DEPTH_RADIX = 10
    )
   (
    input logic clk,
    input logic reset,

    input t_if_ccip_c0_Tx c0Tx,
    input t_if_ccip_c0_Rx c0Rx,

    output logic [C0RX_DEPTH_RADIX-1 : 0] cnt
    );

    typedef logic [C0RX_DEPTH_RADIX-1 : 0] t_active_cnt;

    logic [2:0] active_incr;
    logic active_decr;

    always_comb
    begin
        // Multi-beat read requests cause the activity counter to incremement
        // by the number of lines requested.
        if (c0Tx.valid)
        begin
            active_incr = 3'b1 + 3'(c0Tx.hdr.cl_len);
        end
        else
        begin
            active_incr = 3'b0;
        end

        // Only one line comes back at a time
        active_decr = c0Rx.rspValid && (c0Rx.hdr.resp_type == eRSP_RDLINE);
    end

    always_ff @(posedge clk)
    begin
        if (reset)
        begin
            cnt <= t_active_cnt'(0);
        end
        else
        begin
            cnt <= cnt + t_active_cnt'(active_incr) - t_active_cnt'(active_decr);
        end
    end

endmodule // ccip_async_c0_active_cnt


module ccip_async_c1_active_cnt
  #(
    parameter C1RX_DEPTH_RADIX = 10
    )
   (
    input logic clk,
    input logic reset,

    input t_if_ccip_c1_Tx c1Tx,
    input t_if_ccip_c1_Rx c1Rx,

    output logic [C1RX_DEPTH_RADIX-1 : 0] cnt
    );

    typedef logic [C1RX_DEPTH_RADIX-1 : 0] t_active_cnt;

    logic active_incr;
    logic [2:0] active_decr;

    always_comb
    begin
        // New request?
        active_incr = c1Tx.valid;

        if (c1Rx.rspValid)
        begin
            if ((c1Rx.hdr.resp_type == eRSP_WRLINE) && c1Rx.hdr.format)
            begin
                // Packed response for multiple lines
                active_decr = 3'b1 + 3'(c1Rx.hdr.cl_num);
            end
            else
            begin
                // Response for a single request
                active_decr = 3'b1;
            end
        end
        else
        begin
            active_decr = 3'b0;
        end
    end

    always_ff @(posedge clk)
    begin
        if (reset)
        begin
            cnt <= t_active_cnt'(0);
        end
        else
        begin
            cnt <= cnt + t_active_cnt'(active_incr) - t_active_cnt'(active_decr);
        end
    end

endmodule // ccip_async_c1_active_cnt
/* ****************************************************************************
 * Copyright(c) 2011-2016, Intel Corporation
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 *
 * * Redistributions of source code must retain the above copyright notice,
 * this list of conditions and the following disclaimer.
 * * Redistributions in binary form must reproduce the above copyright notice,
 * this list of conditions and the following disclaimer in the documentation
 * and/or other materials provided with the distribution.
 * * Neither the name of Intel Corporation nor the names of its contributors
 * may be used to endorse or promote products derived from this software
 * without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
 * AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
 * ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE
 * LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
 * CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
 * SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
 * INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
 * CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
 * ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
 * POSSIBILITY OF SUCH DAMAGE.
 */

/*
 * Module: ccip_async_shim
 *         CCI-P async shim to connect slower/faster AFUs to 400 Mhz Blue bitstream
 *
 * Owner      : Rahul R Sharma
 *              rahul.r.sharma@intel.com
 *              Intel Corporation
 *
 * Documentation: See Related Application Note
 *
 */

import ccip_if_pkg::*;

module ccip_async_shim
  #(
    parameter DEBUG_ENABLE          = 0,
    parameter ENABLE_EXTRA_PIPELINE = 1,
    parameter C0TX_DEPTH_RADIX      = 8,
    parameter C1TX_DEPTH_RADIX      = 8,
    parameter C2TX_DEPTH_RADIX      = 8,
    parameter C0RX_DEPTH_RADIX      = 10,
    parameter C1RX_DEPTH_RADIX      = 10
    )
   (
    // ---------------------------------- //
    // Blue Bitstream Interface
    // ---------------------------------- //
    input logic        bb_softreset,
    input logic        bb_clk,
    output             t_if_ccip_Tx bb_tx,
    input              t_if_ccip_Rx bb_rx,
    // ---------------------------------- //
    // Green Bitstream interface
    // ---------------------------------- //
    output logic       afu_softreset,
    input logic        afu_clk,
    input              t_if_ccip_Tx afu_tx,
    output             t_if_ccip_Rx afu_rx,
    // ---------------------------------- //
    // Error vector
    // ---------------------------------- //
    output logic [4:0] async_shim_error
    );

   localparam C0TX_TOTAL_WIDTH = 1 + $bits(t_ccip_c0_ReqMemHdr) ;
   localparam C1TX_TOTAL_WIDTH = 1 + $bits(t_ccip_c1_ReqMemHdr) + CCIP_CLDATA_WIDTH;
   localparam C2TX_TOTAL_WIDTH = 1 + $bits(t_ccip_c2_RspMmioHdr) + CCIP_MMIODATA_WIDTH;
   localparam C0RX_TOTAL_WIDTH = 3 + $bits(t_ccip_c0_RspMemHdr) + CCIP_CLDATA_WIDTH;
   localparam C1RX_TOTAL_WIDTH = 1 + $bits(t_ccip_c1_RspMemHdr);


   /*
    * Reset synchronizer
    */
   (* preserve *) logic               softreset_T1;
   (* preserve *) logic               softreset_T2;
   (* preserve *) logic               afu_softreset_T1;

   always @(posedge afu_clk) begin
      softreset_T1 <= bb_softreset;
      softreset_T2 <= softreset_T1;
      afu_softreset_T1 <= softreset_T2;
      afu_softreset <= afu_softreset_T1;
   end

   t_if_ccip_Rx bb_rx_q;
   t_if_ccip_Rx afu_rx_q;

   t_if_ccip_Tx bb_tx_q;
   t_if_ccip_Tx afu_tx_q;

   always @(posedge afu_clk) begin
      afu_rx   <= afu_rx_q;
      afu_tx_q <= afu_tx;
   end

   always @(posedge bb_clk) begin
      bb_rx_q <= bb_rx;
      bb_tx   <= bb_tx_q;
   end


   /*
    * C0Tx Channel
    */
   logic [C0TX_DEPTH_RADIX-1:0] c0tx_cnt;
   logic [C0TX_TOTAL_WIDTH-1:0] c0tx_dout;
   logic                        c0tx_rdreq;
   logic                        c0tx_rdempty;
   logic                        c0tx_rdempty_q;
   logic                        c0tx_valid;
   logic                        c0tx_fifo_wrfull;

   ccip_afifo_channel
     #(
       .DATA_WIDTH  (C0TX_TOTAL_WIDTH),
       .DEPTH_RADIX (C0TX_DEPTH_RADIX)
       )
   c0tx_afifo
     (
      .data    ( {afu_tx_q.c0.hdr, afu_tx_q.c0.valid} ),
      .wrreq   ( afu_tx_q.c0.valid ),
      .rdreq   ( c0tx_rdreq ),
      .wrclk   ( afu_clk ),
      .rdclk   ( bb_clk ),
      .aclr    ( softreset_T1 ),
      .q       ( c0tx_dout ),
      .rdusedw ( ),
      .wrusedw ( c0tx_cnt ),
      .rdfull  ( ),
      .rdempty ( c0tx_rdempty ),
      .wrfull  ( c0tx_fifo_wrfull ),
      .wrempty ( )
      );

   // Track round-trip request -> response credits to avoid filling the
   // response pipeline.
   logic [C0RX_DEPTH_RADIX-1:0] c0req_cnt;
   ccip_async_c0_active_cnt
     #(
       .C0RX_DEPTH_RADIX (C0RX_DEPTH_RADIX)
       )
   c0req_credit_counter
     (
      .clk   ( afu_clk ),
      .reset ( afu_softreset_T1 ),
      .c0Tx  ( afu_tx_q.c0 ),
      .c0Rx  ( afu_rx_q.c0 ),
      .cnt   ( c0req_cnt )
      );

   always @(posedge bb_clk) begin
      c0tx_valid <= c0tx_rdreq & ~c0tx_rdempty;
   end

   // Extra pipeline register to ease timing pressure -- disable as needed
   generate
      if (ENABLE_EXTRA_PIPELINE == 1) begin
         always @(posedge bb_clk) begin
            c0tx_rdempty_q <= c0tx_rdempty;
         end
      end
      else begin
         always @(*) begin
            c0tx_rdempty_q <= c0tx_rdempty;
         end
      end
   endgenerate


   always @(posedge bb_clk) begin
      c0tx_rdreq <= ~bb_rx_q.c0TxAlmFull & ~c0tx_rdempty_q;
   end

   always @(posedge bb_clk) begin
      if (c0tx_valid) begin
         {bb_tx_q.c0.hdr, bb_tx_q.c0.valid} <= c0tx_dout;
      end
      else begin
         {bb_tx_q.c0.hdr, bb_tx_q.c0.valid} <= 0;
      end
   end

   // Maximum number of line requests outstanding is the size of the buffer
   // minus the number of requests that may arrive after asserting almost full.
   // Multiply the threshold by 8 instead of 4 (the maximum line request
   // size) in order to leave room for MMIO requests and some delay in
   // the AFU responding to almost full.
   localparam C0_REQ_CREDIT_LIMIT = (2 ** C0RX_DEPTH_RADIX) -
                                    CCIP_TX_ALMOST_FULL_THRESHOLD * 8;
   generate
       if (C0_REQ_CREDIT_LIMIT <= 0) begin
           //
           // Error: C0RX_DEPTH_RADIX is too small, given the number of
           //        requests that may be in flight after almost full is
           //        asserted!
           //
           // Force a compile-time failure...
           PARAMETER_ERROR dummy();
           always $display("C0RX_DEPTH_RADIX is too small");
       end
   endgenerate

   always @(posedge afu_clk) begin
      afu_rx_q.c0TxAlmFull <= c0tx_cnt[C0TX_DEPTH_RADIX-1] ||
                              (c0req_cnt > C0RX_DEPTH_RADIX'(C0_REQ_CREDIT_LIMIT));
   end


   /*
    * C1Tx Channel
    */
   logic [C1TX_DEPTH_RADIX-1:0] c1tx_cnt;
   logic [C1TX_TOTAL_WIDTH-1:0] c1tx_dout;
   logic                        c1tx_rdreq;
   logic                        c1tx_rdempty;
   logic                        c1tx_rdempty_q;
   logic                        c1tx_valid;
   logic                        c1tx_fifo_wrfull;

   ccip_afifo_channel
     #(
       .DATA_WIDTH  (C1TX_TOTAL_WIDTH),
       .DEPTH_RADIX (C1TX_DEPTH_RADIX)
       )
   c1tx_afifo
     (
      .data    ( {afu_tx_q.c1.hdr, afu_tx_q.c1.data, afu_tx_q.c1.valid} ),
      .wrreq   ( afu_tx_q.c1.valid ),
      .rdreq   ( c1tx_rdreq ),
      .wrclk   ( afu_clk ),
      .rdclk   ( bb_clk ),
      .aclr    ( softreset_T1 ),
      .q       ( c1tx_dout ),
      .rdusedw ( ),
      .wrusedw ( c1tx_cnt ),
      .rdfull  ( ),
      .rdempty ( c1tx_rdempty ),
      .wrfull  ( c1tx_fifo_wrfull ),
      .wrempty ( )
      );

   // Track round-trip request -> response credits to avoid filling the
   // response pipeline.
   logic [C1RX_DEPTH_RADIX-1:0] c1req_cnt;
   ccip_async_c1_active_cnt
     #(
       .C1RX_DEPTH_RADIX (C1RX_DEPTH_RADIX)
       )
   c1req_credit_counter
     (
      .clk   ( afu_clk ),
      .reset ( afu_softreset_T1 ),
      .c1Tx  ( afu_tx_q.c1 ),
      .c1Rx  ( afu_rx_q.c1 ),
      .cnt   ( c1req_cnt )
      );

   always @(posedge bb_clk) begin
      c1tx_valid <= c1tx_rdreq & ~c1tx_rdempty;
   end

   // Extra pipeline register to ease timing pressure -- disable as needed
   generate
      if (ENABLE_EXTRA_PIPELINE == 1) begin
         always @(posedge bb_clk) begin
            c1tx_rdempty_q <= c1tx_rdempty;
         end
      end
      else begin
         always @(*) begin
            c1tx_rdempty_q <= c1tx_rdempty;
         end
      end
   endgenerate

   always @(posedge bb_clk) begin
      c1tx_rdreq <= ~bb_rx_q.c1TxAlmFull & ~c1tx_rdempty_q;
   end

   always @(posedge bb_clk) begin
      if (c1tx_valid) begin
         {bb_tx_q.c1.hdr, bb_tx_q.c1.data, bb_tx_q.c1.valid} <= c1tx_dout;
      end
      else begin
         {bb_tx_q.c1.hdr, bb_tx_q.c1.data, bb_tx_q.c1.valid} <= 0;
      end
   end

   // Maximum number of line requests outstanding is the size of the buffer
   // minus the number of requests that may arrive after asserting almost full,
   // with some wiggle room added for message latency.
   localparam C1_REQ_CREDIT_LIMIT = (2 ** C1RX_DEPTH_RADIX) -
                                    CCIP_TX_ALMOST_FULL_THRESHOLD * 8;
   generate
       if (C1_REQ_CREDIT_LIMIT <= 0) begin
           //
           // Error: C1RX_DEPTH_RADIX is too small, given the number of
           //        requests that may be in flight after almost full is
           //        asserted!
           //
           // Force a compile-time failure...
           PARAMETER_ERROR dummy();
           always $display("C1RX_DEPTH_RADIX is too small");
       end
   endgenerate

   always @(posedge afu_clk) begin
      afu_rx_q.c1TxAlmFull <= c1tx_cnt[C1TX_DEPTH_RADIX-1] ||
                              (c1req_cnt > C1RX_DEPTH_RADIX'(C1_REQ_CREDIT_LIMIT));
   end


   /*
    * C2Tx Channel
    */
   logic [C2TX_TOTAL_WIDTH-1:0] c2tx_dout;
   logic                        c2tx_rdreq;
   logic                        c2tx_rdempty;
   logic                        c2tx_valid;
   logic                        c2tx_fifo_wrfull;

   ccip_afifo_channel
     #(
       .DATA_WIDTH  (C2TX_TOTAL_WIDTH),
       .DEPTH_RADIX (C2TX_DEPTH_RADIX)
       )
   c2tx_afifo
     (
      .data    ( {afu_tx_q.c2.hdr, afu_tx_q.c2.mmioRdValid, afu_tx_q.c2.data} ),
      .wrreq   ( afu_tx_q.c2.mmioRdValid ),
      .rdreq   ( c2tx_rdreq ),
      .wrclk   ( afu_clk ),
      .rdclk   ( bb_clk ),
      .aclr    ( softreset_T1 ),
      .q       ( c2tx_dout ),
      .rdusedw (),
      .wrusedw (),
      .rdfull  (),
      .rdempty ( c2tx_rdempty ),
      .wrfull  ( c2tx_fifo_wrfull ),
      .wrempty ()
      );

   always @(posedge bb_clk) begin
      c2tx_valid <= c2tx_rdreq & ~c2tx_rdempty;
   end

   always @(posedge bb_clk) begin
      c2tx_rdreq <= ~c2tx_rdempty;
   end

   always @(posedge bb_clk) begin
      if (c2tx_valid) begin
         {bb_tx_q.c2.hdr, bb_tx_q.c2.mmioRdValid, bb_tx_q.c2.data} <= c2tx_dout;
      end
      else begin
         {bb_tx_q.c2.hdr, bb_tx_q.c2.mmioRdValid, bb_tx_q.c2.data} <= 0;
      end
   end


   /*
    * C0Rx Channel
    */
   logic [C0RX_TOTAL_WIDTH-1:0] c0rx_dout;
   logic                        c0rx_valid;
   logic                        c0rx_rdreq;
   logic                        c0rx_rdempty;
   logic                        c0rx_fifo_wrfull;

   ccip_afifo_channel
     #(
       .DATA_WIDTH  (C0RX_TOTAL_WIDTH),
       .DEPTH_RADIX (C0RX_DEPTH_RADIX)
       )
   c0rx_afifo
     (
      .data    ( {bb_rx_q.c0.hdr, bb_rx_q.c0.data, bb_rx_q.c0.rspValid, bb_rx_q.c0.mmioRdValid, bb_rx_q.c0.mmioWrValid} ),
      .wrreq   ( bb_rx_q.c0.rspValid | bb_rx_q.c0.mmioRdValid |  bb_rx_q.c0.mmioWrValid ),
      .rdreq   ( c0rx_rdreq ),
      .wrclk   ( bb_clk ),
      .rdclk   ( afu_clk ),
      .aclr    ( softreset_T1 ),
      .q       ( c0rx_dout ),
      .rdusedw (),
      .wrusedw (),
      .rdfull  (),
      .rdempty ( c0rx_rdempty ),
      .wrfull  ( c0rx_fifo_wrfull ),
      .wrempty ()
      );

   always @(posedge afu_clk) begin
      c0rx_valid <= c0rx_rdreq & ~c0rx_rdempty;
   end

   always @(posedge afu_clk) begin
      c0rx_rdreq <= ~c0rx_rdempty;
   end

   always @(posedge afu_clk) begin
      if (c0rx_valid) begin
         {afu_rx_q.c0.hdr, afu_rx_q.c0.data, afu_rx_q.c0.rspValid, afu_rx_q.c0.mmioRdValid, afu_rx_q.c0.mmioWrValid} <= c0rx_dout;
      end
      else begin
         {afu_rx_q.c0.hdr, afu_rx_q.c0.data, afu_rx_q.c0.rspValid, afu_rx_q.c0.mmioRdValid, afu_rx_q.c0.mmioWrValid} <= 0;
      end
   end


   /*
    * C1Rx Channel
    */
   logic [C1RX_TOTAL_WIDTH-1:0] c1rx_dout;
   logic                        c1rx_valid;
   logic                        c1rx_rdreq;
   logic                        c1rx_rdempty;
   logic                        c1rx_fifo_wrfull;

   ccip_afifo_channel
     #(
       .DATA_WIDTH  (C1RX_TOTAL_WIDTH),
       .DEPTH_RADIX (C1RX_DEPTH_RADIX)
       )
   c1rx_afifo
     (
      .data    ( {bb_rx_q.c1.hdr, bb_rx_q.c1.rspValid} ),
      .wrreq   ( bb_rx_q.c1.rspValid ),
      .rdreq   ( c1rx_rdreq ),
      .wrclk   ( bb_clk ),
      .rdclk   ( afu_clk ),
      .aclr    ( softreset_T1 ),
      .q       ( c1rx_dout ),
      .rdusedw (),
      .wrusedw (),
      .rdfull  (),
      .rdempty ( c1rx_rdempty ),
      .wrfull  ( c1rx_fifo_wrfull ),
      .wrempty ()
      );


   always @(posedge afu_clk) begin
      c1rx_valid <= c1rx_rdreq & ~c1rx_rdempty;
   end

   always @(posedge afu_clk) begin
      c1rx_rdreq <= ~c1rx_rdempty;
   end

   always @(posedge afu_clk) begin
      if (c1rx_valid) begin
         {afu_rx_q.c1.hdr, afu_rx_q.c1.rspValid} <= c1rx_dout;
      end
      else begin
         {afu_rx_q.c1.hdr, afu_rx_q.c1.rspValid} <= 0;
      end
   end


   /*
    * Error vector (indicates write error)
    * --------------------------------------------------
    *   0 - C0Tx Write error
    *   1 - C1Tx Write error
    *   2 - C2Tx Write error
    *   3 - C0Rx Write error
    *   4 - C1Rx Write error
    */
   always @(posedge afu_clk) begin
      if (softreset_T1) begin
         async_shim_error <= 5'b0;
      end
      else begin
         async_shim_error[0] <= c0tx_fifo_wrfull && afu_tx_q.c0.valid;
         async_shim_error[1] <= c1tx_fifo_wrfull && afu_tx_q.c1.valid;
         async_shim_error[2] <= c2tx_fifo_wrfull && afu_tx_q.c2.mmioRdValid;
         async_shim_error[3] <= c0rx_fifo_wrfull && (bb_rx_q.c0.rspValid|bb_rx_q.c0.mmioRdValid|bb_rx_q.c0.mmioWrValid );
         async_shim_error[4] <= c1rx_fifo_wrfull && bb_rx_q.c1.rspValid;
      end
   end

   // synthesis translate_off
   always @(posedge afu_clk) begin
      if (async_shim_error[0])
        $warning("** ERROR ** C0Tx may have dropped transaction");
      if (async_shim_error[1])
        $warning("** ERROR ** C1Tx may have dropped transaction");
      if (async_shim_error[2])
        $warning("** ERROR ** C2Tx may have dropped transaction");
   end

   always @(posedge bb_clk) begin
      if (async_shim_error[3])
        $warning("** ERROR ** C0Rx may have dropped transaction");
      if (async_shim_error[4])
        $warning("** ERROR ** C1Rx may have dropped transaction");
   end
   // synthesis translate_on


   /*
    * Interface counts
    * - This block is enabled when DEBUG_ENABLE = 1, else disabled
    */
   generate
      if (DEBUG_ENABLE == 1) begin
         // Counts
         (* preserve *) logic [31:0] afu_c0tx_cnt;
         (* preserve *) logic [31:0] afu_c1tx_cnt;
         (* preserve *) logic [31:0] afu_c2tx_cnt;
         (* preserve *) logic [31:0] afu_c0rx_cnt;
         (* preserve *) logic [31:0] afu_c1rx_cnt;
         (* preserve *) logic [31:0] bb_c0tx_cnt;
         (* preserve *) logic [31:0] bb_c1tx_cnt;
         (* preserve *) logic [31:0] bb_c2tx_cnt;
         (* preserve *) logic [31:0] bb_c0rx_cnt;
         (* preserve *) logic [31:0] bb_c1rx_cnt;

         // afu_if counts
         always @(posedge afu_clk) begin
            if (afu_softreset_T1) begin
               afu_c0tx_cnt <= 0;
               afu_c1tx_cnt <= 0;
               afu_c2tx_cnt <= 0;
               afu_c0rx_cnt <= 0;
               afu_c1rx_cnt <= 0;
            end
            else begin
               if (afu_tx_q.c0.valid)
                 afu_c0tx_cnt <= afu_c0tx_cnt + 1;
               if (afu_tx_q.c1.valid)
                 afu_c1tx_cnt <= afu_c1tx_cnt + 1;
               if (afu_tx_q.c2.mmioRdValid)
                 afu_c2tx_cnt <= afu_c2tx_cnt + 1;
               if (afu_rx_q.c0.rspValid|afu_rx_q.c0.mmioRdValid|afu_rx_q.c0.mmioWrValid)
                 afu_c0rx_cnt <= afu_c0rx_cnt + 1;
               if (afu_rx_q.c1.rspValid)
                 afu_c1rx_cnt <= afu_c1rx_cnt + 1;
            end
         end

         // bb_if counts
         always @(posedge bb_clk) begin
            if (softreset_T1) begin
               bb_c0tx_cnt <= 0;
               bb_c1tx_cnt <= 0;
               bb_c2tx_cnt <= 0;
               bb_c0rx_cnt <= 0;
               bb_c1rx_cnt <= 0;
            end
            else begin
               if (bb_tx_q.c0.valid)
                 bb_c0tx_cnt <= bb_c0tx_cnt + 1;
               if (bb_tx_q.c1.valid)
                 bb_c1tx_cnt <= bb_c1tx_cnt + 1;
               if (bb_tx_q.c2.mmioRdValid)
                 bb_c2tx_cnt <= bb_c2tx_cnt + 1;
               if (bb_rx_q.c0.rspValid|bb_rx_q.c0.mmioRdValid|bb_rx_q.c0.mmioWrValid)
                 bb_c0rx_cnt <= bb_c0rx_cnt + 1;
               if (bb_rx_q.c1.rspValid)
                 bb_c1rx_cnt <= bb_c1rx_cnt + 1;
            end
         end

      end
   endgenerate


endmodule
// This module is a wrapper of ccip_std_afu which avoids the use of packed struct
// and makes our life easier in writing the software driver.

import ccip_if_pkg::*;

module ccip_std_afu_wrapper
(
    // CCI-P Clocks and Resets, we only need 400MHz
    input logic pClk,
    input logic pClkDiv2,
    input logic pClkDiv4,
    input logic pck_cp2af_softReset,

    // AlmFull
    input logic c0TxAlmFull,
    input logic c1TxAlmFull,

    // c0Rx
    input logic [CCIP_C0RX_HDR_WIDTH-1:0]   c0Rx_hdr,
    input logic [CCIP_CLDATA_WIDTH-1:0]     c0Rx_data,
    input logic                             c0Rx_rspValid,
    input logic                             c0Rx_mmioRdValid,
    input logic                             c0Rx_mmioWrValid,

    // c1Rx
    input logic [CCIP_C1RX_HDR_WIDTH-1:0]   c1Rx_hdr,
    input logic                             c1Rx_rspValid,

    // c0Tx
    output logic [CCIP_C0TX_HDR_WIDTH-1:0]  c0Tx_hdr,
    output logic                            c0Tx_valid,

    // c1Tx
    output logic [CCIP_C1TX_HDR_WIDTH-1:0]  c1Tx_hdr,
    output logic [CCIP_CLDATA_WIDTH-1:0]    c1Tx_data,
    output logic                            c1Tx_valid,

    // c2Tx
    output logic [CCIP_C2TX_HDR_WIDTH-1:0]  c2Tx_hdr,
    output logic                            c2Tx_mmioRdValid,
    output logic [CCIP_MMIODATA_WIDTH-1:0]  c2Tx_data
);

    t_if_ccip_Tx ccip_tx;
    t_if_ccip_Rx ccip_rx;

    /* verilator lint_off PINMISSING */
    ccip_std_afu_async_connect ccip_std_afu_async_connect(
        .pClk(pClk),
        .pClkDiv2(pClkDiv2),
        .pClkDiv4(pClkDiv4),
        .pck_cp2af_softReset(pck_cp2af_softReset),
        .pck_cp2af_sRx(ccip_rx),
        .pck_af2cp_sTx(ccip_tx));
    /* verilator lint_on PINMISSING */

    always_comb
    begin
        ccip_rx.c0TxAlmFull = c0TxAlmFull;
        ccip_rx.c1TxAlmFull = c1TxAlmFull;

        ccip_rx.c0.hdr = c0Rx_hdr;
        ccip_rx.c0.data = c0Rx_data;
        ccip_rx.c0.rspValid = c0Rx_rspValid;
        ccip_rx.c0.mmioRdValid = c0Rx_mmioRdValid;
        ccip_rx.c0.mmioWrValid = c0Rx_mmioWrValid;

        ccip_rx.c1.hdr = c1Rx_hdr;
        ccip_rx.c1.rspValid = c1Rx_rspValid;

        c0Tx_hdr = ccip_tx.c0.hdr;
        c0Tx_valid = ccip_tx.c0.valid;

        c1Tx_hdr = ccip_tx.c1.hdr;
        c1Tx_data = ccip_tx.c1.data;
        c1Tx_valid = ccip_tx.c1.valid;

        c2Tx_hdr = ccip_tx.c2.hdr;
        c2Tx_mmioRdValid = ccip_tx.c2.mmioRdValid;
        c2Tx_data = ccip_tx.c2.data;
    end
endmodule

