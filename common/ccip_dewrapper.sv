import ccip_if_pkg::*;

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

	t_if_ccip_Rx sRx;
	t_if_ccip_Tx sTx;

	assign sRx = pck_cp2af_sRx;
	assign pck_af2cp_sTx = sTx;

	ccip_std_afu_wrapper wrapped_afu(
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
