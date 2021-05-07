import ccip_if_pkg::*;
`include "vendor_defines.vh"

typedef enum logic [1:0] {
    READ_NORMAL,
    READ_BATCH
} p1_status_type;

module vai_audit_tx #(parameter NUM_SUB_AFUS=8)
(
    input   wire                    clk,
    input   wire                    reset,
    output  t_if_ccip_Tx            up_TxPort       [NUM_SUB_AFUS-1:0],
    input   t_if_ccip_Tx            afu_TxPort      [NUM_SUB_AFUS-1:0],
    input   logic [63:0]            offset_array    [NUM_SUB_AFUS-1:0]
);

    localparam LNUM_SUB_AFUS = $clog2(NUM_SUB_AFUS);
    localparam VMID_WIDTH = LNUM_SUB_AFUS;

    /* reset fanout */
    logic reset_q;
    logic reset_qq [NUM_SUB_AFUS-1:0];
    logic reset_qqq [NUM_SUB_AFUS-1:0];
    always_ff @(posedge clk)
    begin
        reset_q <= reset;
        for (int i=0; i<NUM_SUB_AFUS; i++)
        begin
            reset_qq[i] <= reset_q;
            reset_qqq[i] <= reset_qq[i];
        end
    end

    generate
        genvar n;
        for (n=0; n<NUM_SUB_AFUS; n++)
        begin: afu_tx_stages

            /* stage T0 */
            t_if_ccip_Tx T0_Tx;
            assign T0_Tx = afu_TxPort[n];

            /* stage T1 */
            t_if_ccip_c0_Tx T1_c0;
            t_if_ccip_c1_Tx T1_c1;
            t_if_ccip_c2_Tx T1_c2;

            logic [63:0] T1_offset_mem;
            logic [31:0] T1_offset_mmio;

            always_ff @(posedge clk)
            begin
                if (reset_qqq[n])
                begin
                    T1_c0.valid <= 0;
                    T1_c1.valid <= 0;
                    T1_c2.mmioRdValid <= 0;
                    T1_offset_mem <= 0;
                    T1_offset_mmio <= 0;
                end
                else
                begin
                    T1_c0 <= T0_Tx.c0;
                    T1_c1 <= T0_Tx.c1;
                    T1_c2 <= T0_Tx.c2;
                    T1_offset_mem <= offset_array[n];
                    T1_offset_mmio <= ((n+1) << 6);
                end
            end

            /* stage T2 */
            t_if_ccip_c0_Tx T2_c0;
            t_if_ccip_c1_Tx T2_c1;
            t_if_ccip_c2_Tx T2_c2;

            always_ff @(posedge clk)
            begin
                if (reset_qqq[n])
                begin
                    T2_c0.valid <= 0;
                    T2_c1.valid <= 0;
                    T2_c2.mmioRdValid <= 0;
                end
                else
                begin
                    /* handle c0 */
                    T2_c0.valid         <=  T1_c0.valid;
                    T2_c0.hdr.vc_sel    <=  T1_c0.hdr.vc_sel;
                    T2_c0.hdr.rsvd1     <=  T1_c0.hdr.rsvd1;
                    T2_c0.hdr.cl_len    <=  T1_c0.hdr.cl_len;
                    T2_c0.hdr.req_type  <=  T1_c0.hdr.req_type;
                    T2_c0.hdr.rsvd0     <=  T1_c0.hdr.rsvd0;
                    T2_c0.hdr.address   <=  T1_c0.hdr.address + t_ccip_clAddr'(T1_offset_mem);
                    T2_c0.hdr.mdata[15:16-LNUM_SUB_AFUS]    <= n;
                    T2_c0.hdr.mdata[15-LNUM_SUB_AFUS:0]     <=  T1_c0.hdr.mdata[15-LNUM_SUB_AFUS:0];

                    /* handle c1 */
                    T2_c1.valid         <=  T1_c1.valid;
                    T2_c1.data          <=  T1_c1.data;
                    T2_c1.hdr.rsvd2     <=  T1_c1.hdr.rsvd2;
                    T2_c1.hdr.vc_sel    <=  T1_c1.hdr.vc_sel;
                    T2_c1.hdr.sop       <=  T1_c1.hdr.sop;
                    T2_c1.hdr.rsvd1     <=  T1_c1.hdr.rsvd1;
                    T2_c1.hdr.cl_len    <=  T1_c1.hdr.cl_len;
                    T2_c1.hdr.req_type  <=  T1_c1.hdr.req_type;
                    T2_c1.hdr.address   <=  (T1_c1.hdr.req_type == eREQ_WRFENCE) ? 
                                                0 : (T1_c1.hdr.address + t_ccip_clAddr'(T1_offset_mem));
                    T2_c1.hdr.mdata[15:16-LNUM_SUB_AFUS]    <=  n;
                    T2_c1.hdr.mdata[15-LNUM_SUB_AFUS:0]     <=  T1_c1.hdr.mdata[15-LNUM_SUB_AFUS:0];

                    /* handle c2 */
                    T2_c2.mmioRdValid   <=  T1_c2.mmioRdValid;
                    T2_c2.data          <=  T1_c2.data;
                    T2_c2.hdr.tid       <=  T1_c2.hdr.tid;
                end
            end

            always_comb
            begin
                up_TxPort[n].c0 = T2_c0;
                up_TxPort[n].c1 = T2_c1;
                up_TxPort[n].c2 = T2_c2;
            end

        end
    endgenerate

endmodule
