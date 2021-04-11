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
    ccip_std_afu ccip_std_afu(
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

    logic [31:0] almfull_c0tx_valid_cnt, almfull_c1tx_valid_cnt;
    always_ff @(posedge pClk) begin
        if (pck_cp2af_softReset) begin
            almfull_c0tx_valid_cnt <= 0;
            almfull_c1tx_valid_cnt <= 0;
        end
        else begin
            if (c0TxAlmFull) begin
                if (c0Tx_valid) begin
                    almfull_c0tx_valid_cnt <= almfull_c0tx_valid_cnt + 1;
                end
                if (almfull_c0tx_valid_cnt > 8) begin
                    $error("more than 8 packets sent out during c0TxAlmFull") /*verilator tag debug_display*/;
                end
            end
            else begin
                almfull_c0tx_valid_cnt <= 0;
            end

            if (c1TxAlmFull) begin
                if (c1Tx_valid) begin
                    almfull_c1tx_valid_cnt <= almfull_c1tx_valid_cnt + 1;
                end
                if (almfull_c1tx_valid_cnt > 8) begin
                    $error("more than 8 packets sent out during c1TxAlmFull") /*verilator tag debug_display*/;
                end
            end
            else begin
                almfull_c1tx_valid_cnt <= 0;
            end
        end
    end

endmodule

