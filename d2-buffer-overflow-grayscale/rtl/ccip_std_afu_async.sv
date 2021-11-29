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

// Include MPF data types, including the CCI interface pacakge.
`include "cci_mpf_if.vh"

import ccip_if_pkg::*;
import grayscale_pkg::*;
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

  localparam MPF_DFH_MMIO_ADDR = 'h400;

  logic clk;
  logic reset;

  logic [511:0] data_tx;
  logic         valid_tx;
  logic [511:0] data_rx;
  logic         valid_rx;

  t_hc_control  hc_control;
  t_hc_address  hc_dsm_base;
  t_hc_buffer   hc_buffer[HC_BUFFER_SIZE];

  t_if_ccip_Tx  ccip_tx;
  t_if_ccip_Rx  ccip_rx;

  // combinational logic
  assign clk   = pClk;
  assign reset = pck_cp2af_softReset;

  always_comb begin
    ccip_rx.c0 = afu.c0Rx;
    ccip_rx.c1 = afu.c1Rx;

    ccip_rx.c0TxAlmFull = afu.c0TxAlmFull;
    ccip_rx.c1TxAlmFull = afu.c1TxAlmFull;

    afu.c0Tx = cci_mpf_cvtC0TxFromBase(ccip_tx.c0);
    afu.c1Tx = cci_mpf_cvtC1TxFromBase(ccip_tx.c1);

    if (cci_mpf_c0TxIsReadReq(afu.c0Tx)) begin
      afu.c0Tx.hdr.ext.addrIsVirtual       = 1'b1;
      afu.c0Tx.hdr.ext.mapVAtoPhysChannel  = 1'b1;
      afu.c0Tx.hdr.ext.checkLoadStoreOrder = 1'b1;
    end

    if (cci_mpf_c1TxIsWriteReq(afu.c1Tx)) begin
      afu.c1Tx.hdr.ext.addrIsVirtual       = 1'b1;
      afu.c1Tx.hdr.ext.mapVAtoPhysChannel  = 1'b1;
      afu.c1Tx.hdr.ext.checkLoadStoreOrder = 1'b1;
    end

    afu.c2Tx.mmioRdValid = 1'b0;
  end

  // cci_mpf

  cci_mpf_if fiu(.clk(clk));
  cci_mpf_if afu(.clk(clk));
  cci_mpf_if afu_csrs(.clk(clk));

  ccip_wires_to_mpf
  #(
    // All inputs and outputs in PR region (AFU) must be registered!
    .REGISTER_INPUTS(1),
    .REGISTER_OUTPUTS(1)
  )
  map_ifc
  (
    .pClk                (clk),
    .pClkDiv2            (pClkDiv2),
    .pClkDiv4            (pClkDiv4),
    .uClk_usr            (uClk_usr),
    .uClk_usrDiv2        (uClk_usrDiv2),
    .pck_cp2af_softReset (reset),
    .pck_cp2af_pwrState  (pck_cp2af_pwrState),
    .pck_cp2af_error     (pck_cp2af_error),
    .pck_cp2af_sRx       (pck_cp2af_sRx),
    .pck_af2cp_sTx       (pck_af2cp_sTx),
    .fiu                 (fiu)
  );

  cci_mpf
  #(
    .SORT_READ_RESPONSES(1),
    .PRESERVE_WRITE_MDATA(1),
    .ENABLE_VC_MAP(0),
    //.ENABLE_VTP(0),
    .ENABLE_DYNAMIC_VC_MAPPING(1),
    .ENFORCE_WR_ORDER(0),
    .ENABLE_PARTIAL_WRITES(0),
    .DFH_MMIO_BASE_ADDR(MPF_DFH_MMIO_ADDR)
  )
  mpf
  (
    .clk(clk),
    .fiu(afu_csrs),
    .afu,
    .c0NotEmpty(),
    .c1NotEmpty()
  );

  grayscale_csr uu_grayscale_csr
  (
    .clk          (clk),
    .reset        (reset),
    .hc_control   (hc_control),
    .hc_dsm_base  (hc_dsm_base),
    .hc_buffer    (hc_buffer),
    .fiu          (fiu),
    .afu          (afu_csrs)
  );

  grayscale_requestor uu_grayscale_requestor
  (
    .clk          (clk),
    .reset        (reset),
    .hc_control   (hc_control),
    .hc_dsm_base  (hc_dsm_base),
    .hc_buffer    (hc_buffer),
    .data_in      (data_rx),
    .valid_in     (valid_rx),
    .ccip_rx      (ccip_rx),
    .ccip_c0_tx   (ccip_tx.c0),
    .ccip_c1_tx   (ccip_tx.c1),
    .data_out     (data_tx),
    .valid_out    (valid_tx)
  );

  grayscale uu_grayscale
  (
    .clk       (clk),
    .reset     (reset),
    .data_in   (data_tx),
    .valid_in  (valid_tx),
    .data_out  (data_rx),
    .valid_out (valid_rx)
  );

endmodule

