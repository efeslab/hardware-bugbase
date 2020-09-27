import ccip_if_pkg::*;
`include "vendor_defines.vh"
module vai_mux #(NUM_SUB_AFUS=9)
(
    input   wire                    pClk,
    input   wire                    pClkDiv2,
    /* upstream ports */
    input   wire                    SoftReset,                          // upstream reset
    input   wire                    up_Error,
    input   wire [1:0]              up_PwrState,
    input   t_if_ccip_Rx            up_RxPort,                          // upstream Rx response port
    output  t_if_ccip_Tx            up_TxPort,                          // upstream Tx request port
    /* downstream ports */
    output  logic                   afu_SoftReset [NUM_SUB_AFUS-1:0],
    output  logic [1:0]             afu_PwrState  [NUM_SUB_AFUS-1:0],
    output  logic                   afu_Error     [NUM_SUB_AFUS-1:0],
    output  t_if_ccip_Rx            afu_RxPort    [NUM_SUB_AFUS-1:0],        // downstream Rx response AFU
    input   t_if_ccip_Tx            afu_TxPort    [NUM_SUB_AFUS-1:0]         // downstream Tx request  AFU

);

    /* fanout SoftReset */
    logic reset;
    always_ff @(posedge pClk)
    begin
        reset <= SoftReset;
    end

    /* forward Rx Port */

    t_if_ccip_Tx up_TxPort_T0;
    t_if_ccip_Rx mgr2mux_RxPort;
    t_if_ccip_Tx mux2mgr_TxPort;
    t_if_ccip_Rx mux2adt_RxPort[NUM_SUB_AFUS-1:0];
    t_if_ccip_Tx adt2mux_TxPort[NUM_SUB_AFUS-1:0];

    logic [63:0] offset_array [NUM_SUB_AFUS-1:0];
    logic [63:0] offset_array_T1 [NUM_SUB_AFUS-1:0];
    logic [63:0] afu_vai_reset;

    // rx audit
    vai_audit_rx2 #(
        .NUM_SUB_AFUS(NUM_SUB_AFUS)
    )
    inst_vai_audit_rx(
        .clk(pClk),
        .reset(reset),
        .up_RxPort(mux2adt_RxPort),
        .afu_RxPort(afu_RxPort)
        );

    // tx audit
    vai_audit_tx #(
        .NUM_SUB_AFUS(NUM_SUB_AFUS)
    )
    inst_vai_audit_tx(
        .clk(pClk),
        .reset(reset),
        .up_TxPort(adt2mux_TxPort),
        .afu_TxPort(afu_TxPort),
        .offset_array(offset_array_T1)
        );

    // mgr
    vai_mgr #(
        .NUM_SUB_AFUS(NUM_SUB_AFUS)
    )
    inst_vai_mgr(
        .pClk(pClk),
        .pClkDiv2(pClkDiv2),
        .pClkDiv4(),
        .uClk_usr(),
        .uClk_usrDiv2(),
        .pck_cp2af_softReset(reset),
        .pck_cp2af_pwrState(up_PwrState),
        .pck_cp2af_error(up_Error),
        .pck_cp2af_sRx(up_RxPort),
        .pck_af2cp_sTx(up_TxPort_T0),
		.afu_RxPort(mgr2mux_RxPort),
		.afu_TxPort(mux2mgr_TxPort), 
        .offset_array(offset_array),
        .sub_afu_reset(afu_vai_reset)
        );

    always_ff @(posedge pClk)
    begin
        for (int i=0; i<NUM_SUB_AFUS; i++)
        begin
            offset_array_T1[i] <= offset_array[i];
        end
    end


    logic adt2afu_SoftReset [NUM_SUB_AFUS-1:0];
    logic afu_SoftReset_T0 [NUM_SUB_AFUS-1:0];

    always_ff @(posedge pClk)
    begin
        for (int i=0; i<NUM_SUB_AFUS; i++)
        begin
            afu_SoftReset[i] <= afu_SoftReset_T0[i];
            afu_SoftReset_T0[i] <= afu_vai_reset[i] | adt2afu_SoftReset[i];
        end
    end

    generate
        if (NUM_SUB_AFUS == 9)
        begin
            nested_mux_9 inst_ccip_mux_nested(
                .pClk(pClk),
                .pClkDiv2(pClkDiv2),
                .SoftReset(reset),
                .up_Error(up_Error),
                .up_PwrState(up_PwrState),
                .up_RxPort(mgr2mux_RxPort), /* we only use this to count packets */
                .up_TxPort(mux2mgr_TxPort),
                .afu_SoftReset(adt2afu_SoftReset),
                .afu_PwrState(afu_PwrState),
                .afu_Error(afu_Error),
                .afu_RxPort(mux2adt_RxPort),
                .afu_TxPort(adt2mux_TxPort)
                );
        end
        else if (NUM_SUB_AFUS == 8)
        begin
            nested_mux_8 inst_ccip_mux_nested(
                .pClk(pClk),
                .pClkDiv2(pClkDiv2),
                .SoftReset(reset),
                .up_Error(up_Error),
                .up_PwrState(up_PwrState),
                .up_RxPort(mgr2mux_RxPort), /* we only use this to count packets */
                .up_TxPort(mux2mgr_TxPort),
                .afu_SoftReset(adt2afu_SoftReset),
                .afu_PwrState(afu_PwrState),
                .afu_Error(afu_Error),
                .afu_RxPort(mux2adt_RxPort),
                .afu_TxPort(adt2mux_TxPort)
                );
        end
        else
        begin
            ccip_mux_legacy #(
                .NUM_SUB_AFUS(NUM_SUB_AFUS),
                .NUM_PIPE_STAGES(1)
            )
            inst_ccip_mux(
                .pClk(pClk),
                .pClkDiv2(pClkDiv2),
                .SoftReset(reset),
                .up_Error(up_Error),
                .up_PwrState(up_PwrState),
                .up_RxPort(mgr2mux_RxPort), /* we only use this to count packets */
                .up_TxPort(mux2mgr_TxPort),
                .afu_SoftReset(adt2afu_SoftReset),
                .afu_PwrState(afu_PwrState),
                .afu_Error(afu_Error),
                .afu_RxPort(mux2adt_RxPort),
                .afu_TxPort(adt2mux_TxPort)
                );
        end
    endgenerate

    always_ff @(posedge pClk)
    begin
        if (SoftReset)
        begin
            up_TxPort.c0.valid <= 0;
            up_TxPort.c1.valid <= 0;
            up_TxPort.c2.mmioRdValid <= 0;
        end
        else
        begin
            up_TxPort <= up_TxPort_T0;
        end
    end

endmodule
