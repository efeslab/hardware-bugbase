import ccip_if_pkg::*;

module ccip_std_afu
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
   
   /* verilator lint_off PINMISSING */
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
   
   ccip_std_afu_sssp_async afu_async (
		      .pClk( afu_clk ) ,
		      .pck_cp2af_softReset( reset_pass ) ,
		      .pck_cp2af_sRx( afu_rx ) ,
		      .pck_af2cp_sTx( afu_tx ) 
		      );
   /* verilator lint_on PINMISSING */

endmodule // ccip_std_afu
