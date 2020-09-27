`include "platform_if.vh"

module vai_mgr_afu # (parameter NUM_SUB_AFUS=8)
(
    // CCI-P Clocks and Resets
    input           logic             pClk,              // 400MHz - CCI-P clock domain. Primary interface clock
    input           logic             pClkDiv2,          // 200MHz - CCI-P clock domain.
    input           logic             pClkDiv4,          // 100MHz - CCI-P clock domain.
    input           logic             uClk_usr,          // User clock domain. Refer to clock programming guide  ** Currently provides fixed 300MHz clock **
    input           logic             uClk_usrDiv2,      // User clock domain. Half the programmed frequency  ** Currently provides fixed 150MHz clock **
    input           logic             pck_cp2af_softReset,      // CCI-P ACTIVE HIGH Soft Reset
    input           logic [1:0]       pck_cp2af_pwrState,       // CCI-P AFU Power State
    input           logic             pck_cp2af_error,          // CCI-P Protocol Error Detected

    // Interface structures
    input           t_if_ccip_Rx      pck_cp2af_sRx,        // CCI-P Rx Port
    output          t_if_ccip_Tx      pck_af2cp_sTx,        // CCI-P Tx Port

    output  logic [63:0]            offset_array    [NUM_SUB_AFUS-1:0],
    output  logic [63:0]            sub_afu_reset
);

    localparam LNUM_SUB_AFUS = $clog2(NUM_SUB_AFUS);
    localparam VMID_WIDTH = LNUM_SUB_AFUS;


    logic clk;
    logic reset;
    assign clk = pClk;

    always_ff @(posedge clk)
    begin
        reset <= pck_cp2af_softReset;
    end

    /* T0: connect to ccip */
    t_if_ccip_Rx T0_Rx;
    assign T0_Rx = pck_cp2af_sRx;


    /* T1: register */
    t_ccip_clData T1_mmio_data;
    t_ccip_c0_ReqMmioHdr T1_mmio_req_hdr;
    logic T1_is_mmio_read;
    logic T1_is_mmio_write;

    always_ff @(posedge clk)
    begin
        if (reset)
        begin
            T1_mmio_data <= 0;
            T1_mmio_req_hdr <= 0;
            T1_is_mmio_read <= 0;
            T1_is_mmio_write <= 0;
        end
        else
        begin
            T1_mmio_data <= T0_Rx.c0.data;
            T1_mmio_req_hdr <= T0_Rx.c0.hdr;
            T1_is_mmio_read <= T0_Rx.c0.mmioRdValid;
            T1_is_mmio_write <= T0_Rx.c0.mmioWrValid;
        end
    end


    /* T2: decode */
    logic [LNUM_SUB_AFUS-1:0] T2_vmid;
    logic [63:0] T2_data;
    t_ccip_tid T2_tid;
    logic T2_is_offset;
    logic T2_is_reset;
    logic T2_is_dfh;
    logic T2_is_id_lo;
    logic T2_is_id_hi;
    logic T2_is_nafus;
    logic T2_is_read;
    logic T2_is_write;

    always_ff @(posedge clk)
    begin
        if (reset)
        begin
            T2_vmid <= 0;
            T2_data <= 0;
            T2_tid <= 0;
            T2_is_offset <= 0;
            T2_is_reset <= 0;
            T2_is_read <= 0;
            T2_is_write <= 0;
            T2_is_dfh <= 0;
            T2_is_id_lo <= 0;
            T2_is_id_hi <= 0;
            T2_is_nafus <= 0;
        end
        else
        begin
            T2_vmid <= (T1_mmio_req_hdr.address[7:1] - 6);
            T2_data[63:0] <= T1_mmio_data;
            T2_tid <= T1_mmio_req_hdr.tid;
            /* 0 <= vmid < NUM_SUB_AFUS */
            T2_is_offset <= (T1_mmio_req_hdr.address[7:1] >= 6 
                            && T1_mmio_req_hdr.address[7:1] < NUM_SUB_AFUS+6);

            T2_is_dfh <= (T1_mmio_req_hdr.address == 0);
            T2_is_id_lo <= (T1_mmio_req_hdr.address == 2);
            T2_is_id_hi <= (T1_mmio_req_hdr.address == 4);
            T2_is_reset <= (T1_mmio_req_hdr.address == 6);
            T2_is_nafus <= (T1_mmio_req_hdr.address == 8);

            T2_is_read <= T1_is_mmio_read;
            T2_is_write <= T1_is_mmio_write;
        end
    end

    /* T3: assign value */
    logic [2:0] user_clk_array [NUM_SUB_AFUS-1:0];
    t_if_ccip_c2_Tx T3_Tx_c2;

    logic [127:0] mgr_id;
    assign mgr_id = 128'hd1d383aaca4c4c60a0a013a421139e69;

    always_ff @(posedge clk)
    begin
        if (reset)
        begin
            for (int i=0; i<NUM_SUB_AFUS; i++)
            begin
                offset_array[i] <= 0;
                user_clk_array[i] <= 0;
            end

            T3_Tx_c2 <= 0;
            sub_afu_reset <= 0;
        end
        else
        begin
            if (T2_is_write)
            begin
                if (T2_is_offset)
                begin
                    offset_array[T2_vmid] <= T2_data;
                end

                if (T2_is_reset)
                begin
                    sub_afu_reset <= T2_data;
                end
            end

            if (T2_is_read)
            begin
                T3_Tx_c2.hdr.tid <= T2_tid;
                T3_Tx_c2.mmioRdValid <= 1;

                if (T2_is_offset)
                begin
                    T3_Tx_c2.data <= offset_array[T2_vmid];
                end
                else if (T2_is_reset)
                begin
                    T3_Tx_c2.data <= sub_afu_reset;
                end
                else if (T2_is_nafus)
                begin
                    T3_Tx_c2.data <= NUM_SUB_AFUS;
                end
                else if (T2_is_dfh)
                begin
                    T3_Tx_c2.data <= t_ccip_mmioData'(0);
                    T3_Tx_c2.data[63:60] <= 4'h1;
                    T3_Tx_c2.data[40] <= 1'b1;
                end
                else if (T2_is_id_lo)
                begin
                    T3_Tx_c2.data <= mgr_id[63:0];
                end
                else if (T2_is_id_hi)
                begin
                    T3_Tx_c2.data <= mgr_id[127:64];
                end
                else
                begin
                    T3_Tx_c2.data <= 64'hffffffffffffffff;
                end
            end
            else
            begin
                T3_Tx_c2 <= 0;
            end
        end
    end

    /* T4: output */
    /* we do not support read and write from mgr_afu */

    always_ff @(posedge clk)
    begin
        if (reset)
        begin
            pck_af2cp_sTx <= 0;
        end
        else
        begin
            pck_af2cp_sTx.c1 <= 0;
            pck_af2cp_sTx.c1 <= 0;
            pck_af2cp_sTx.c2 <= T3_Tx_c2;
        end
    end


endmodule
