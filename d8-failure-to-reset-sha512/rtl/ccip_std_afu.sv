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

import ccip_if_pkg::*;
import sha512_pkg::*;

module ccip_std_afu
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

  //
  // Run the entire design at the standard CCI-P frequency (400 MHz).
  //
  logic clk;
  assign clk = pClk;

  logic reset;
  assign reset = pck_cp2af_softReset;

  // =========================================================================
  //
  //   Register requests.
  //
  // =========================================================================

  //
  // The incoming pck_cp2af_sRx and outgoing pck_af2cp_sTx must both be
  // registered.  Here we register pck_cp2af_sRx and assign it to ccip_rx.
  // We also assign pck_af2cp_sTx to ccip_tx here but don't register it.
  // The code below never uses combinational logic to write ccip_tx.
  //

  t_if_ccip_Rx ccip_rx;
  always_ff @(posedge clk)
  begin
      ccip_rx <= pck_cp2af_sRx;
  end

  t_if_ccip_Tx ccip_tx;
  assign pck_af2cp_sTx = ccip_tx;

  // =========================================================================
  //
  //   Instances.
  //
  // =========================================================================
  logic [511:0] block;
  logic         block_valid;
  logic [511:0] digest;
  logic         digest_valid;

  t_hc_control  hc_control;
  t_ccip_clAddr hc_dsm_base;
  t_hc_buffer   hc_buffer[HC_BUFFER_SIZE];

  sha512_csr uu_sha512_csr
  (
    .clk             (clk),
    .reset           (reset),
    .rx_mmio_channel (ccip_rx.c0),
    .tx_mmio_channel (ccip_tx.c2),
    .hc_control      (hc_control),
    .hc_dsm_base     (hc_dsm_base),
    .hc_buffer       (hc_buffer)
  );

  sha512_requestor uu_sha512_requestor
  (
    .clk          (clk),
    .reset        (reset),
    .hc_control   (hc_control),
    .hc_dsm_base  (hc_dsm_base),
    .hc_buffer    (hc_buffer),
    .digest       (digest),
    .digest_valid (digest_valid),
    .ccip_rx      (ccip_rx),
    .ccip_c0_tx   (ccip_tx.c0),
    .ccip_c1_tx   (ccip_tx.c1),
    .block        (block),
    .block_valid  (block_valid)
  );

  sha512 uu_sha512
  (
    .clk          (clk),
    .reset        (reset),
    .block        (block),
    .block_valid  (block_valid),
    .digest       (digest),
    .digest_valid (digest_valid)
  );

endmodule : ccip_std_afu

