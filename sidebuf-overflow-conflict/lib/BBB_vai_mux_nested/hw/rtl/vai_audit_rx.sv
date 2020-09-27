import ccip_if_pkg::*;
`include "vendor_defines.vh"
module vai_audit_rx # (parameter NUM_SUB_AFUS=8, NUM_PIPE_STAGES=0)
(
    input   wire                    clk,
    input   wire                    reset,
    input   t_if_ccip_Rx            up_RxPort     [NUM_SUB_AFUS:0],                          // upstream Rx response port
    output  t_if_ccip_Rx            afu_RxPort    [NUM_SUB_AFUS-1:0],        // downstream Rx response AFU
    output  t_if_ccip_Rx            mgr_RxPort
);

    localparam LNUM_SUB_AFUS = $clog2(NUM_SUB_AFUS);
    localparam VMID_WIDTH = LNUM_SUB_AFUS;

    /* reset fanout */
    logic reset_q;
    logic reset_qq[NUM_SUB_AFUS-1:0];
    always_ff @(posedge clk)
    begin
        reset_q <= reset;
        for (int i=0; i<NUM_SUB_AFUS; i++)
        begin
            reset_qq[i] <= reset_q;
        end
    end

    generate
        genvar n;

        for (n=0; n<NUM_SUB_AFUS+1; n++)
        begin
            /* stage T0 */
            t_if_ccip_Rx T0_Rx;
            assign T0_Rx = up_RxPort[n];

            /* stage T1: register Rx */
            t_if_ccip_c0_Rx T1_c0;
            t_if_ccip_c1_Rx T1_c1;
            t_ccip_c0_ReqMmioHdr T1_mmio_req_hdr;
            logic T1_is_mmio_read;
            logic T1_is_mmio_write;

            always_ff @(posedge clk)
            begin
                if (reset_qq[n])
                begin
                    T1_c0.rspValid <= 0;
                    T1_c0.mmioRdValid <= 0;
                    T1_c0.mmioWrValid <= 0;
                    T1_c1.rspValid <= 0;
                    T1_mmio_req_hdr <= t_ccip_c0_ReqMmioHdr'(0);
                    T1_is_mmio_read <= 0;
                    T1_is_mmio_write <= 0;
                end
                else
                begin
                    T1_c0 <= T0_Rx.c0;
                    T1_c1 <= T0_Rx.c1;
                    T1_mmio_req_hdr <= T0_Rx.c0.hdr;
                    T1_is_mmio_read <= T0_Rx.c0.mmioRdValid;
                    T1_is_mmio_write <= T0_Rx.c0.mmioWrValid;
                end
            end

            /* stage T2: get vmid */
            t_if_ccip_c0_Rx T2_c0;
            t_if_ccip_c1_Rx T2_c1;
            t_ccip_c0_ReqMmioHdr T2_mmio_req_hdr;
            logic T2_is_mmio_read;
            logic T2_is_mmio_write;

            logic [VMID_WIDTH-1:0] T2_c0_vmid;
            logic [VMID_WIDTH-1:0] T2_c1_vmid;
            logic [VMID_WIDTH-1:0] T2_mmio_vmid;
            logic T2_is_ctl_mmio;
            logic T2_c0_choose_mmio;
            logic T2_c0_choose_rsp;


            always_ff @(posedge clk)
            begin
                if (reset_qq[n])
                begin
                    T2_c0.rspValid <= 0;
                    T2_c0.mmioRdValid <= 0;
                    T2_c0.mmioWrValid <= 0;
                    T2_c1.rspValid <= 0;
                    T2_mmio_req_hdr <= t_ccip_c0_ReqMmioHdr'(0);
                    T2_is_mmio_read <= 0;
                    T2_is_mmio_write <= 0;

                    T2_c0_vmid <= 0;
                    T2_c1_vmid <= 0;
                    T2_mmio_vmid <= 0;
                    T2_is_ctl_mmio <= 0;

                    T2_c0_choose_mmio <= 0;
                end
                else
                begin
                    T2_c0 <= T1_c0;
                    T2_c1 <= T1_c1;
                    T2_mmio_req_hdr <= T1_mmio_req_hdr;
                    T2_is_mmio_read <= T1_is_mmio_read;
                    T2_is_mmio_write <= T1_is_mmio_write;

                    /* the vmid of c0 and c1 are decided by the top bits of mdata */
                    T2_c0_vmid <= T1_c0.hdr.mdata[15-:VMID_WIDTH];
                    T2_c1_vmid <= T1_c1.hdr.mdata[15-:VMID_WIDTH];

                    /* the vmid of mmio is decided by the address, each VM has 0xff bytes,
                     * and 0x0-0xff are owned by the hypervisor */
                    T2_is_ctl_mmio <= (T1_mmio_req_hdr.address[CCIP_MMIOADDR_WIDTH-1:10] == 0);
                    T2_mmio_vmid <= (T1_mmio_req_hdr.address[CCIP_MMIOADDR_WIDTH-1:10] - 1);

                    T2_c0_choose_mmio <= ((T1_is_mmio_read || T1_is_mmio_write) && (T1_mmio_req_hdr.address[CCIP_MMIOADDR_WIDTH-1:10] != 0));
                    T2_c0_choose_rsp <= T1_c0.rspValid;
                end
            end



            /* stage T3: handle offset */
            t_if_ccip_c0_Rx T3_c0;
            t_if_ccip_c1_Rx T3_c1;

            /* specially, if T2_is_ctl_mmio is 1, we need to output the c0 channel to the mgr port */
            t_if_ccip_c0_Rx T3_mgr_c0;

            logic [VMID_WIDTH-1:0] T3_c0_vmid;
            logic [VMID_WIDTH-1:0] T3_c1_vmid;

            t_ccip_c0_RspMemHdr T3_c0_mem_hdr_prefetch;
            t_ccip_c0_ReqMmioHdr T3_c0_mmio_hdr_prefetch;

            always_comb
            begin
                /* candidate memory response */
                T3_c0_mem_hdr_prefetch.resp_type =  T2_c0.hdr.resp_type;
                T3_c0_mem_hdr_prefetch.cl_num    =  T2_c0.hdr.cl_num;
                T3_c0_mem_hdr_prefetch.rsvd0     =  T2_c0.hdr.rsvd0;
                T3_c0_mem_hdr_prefetch.hit_miss  =  T2_c0.hdr.hit_miss;
                T3_c0_mem_hdr_prefetch.rsvd1     =  T2_c0.hdr.rsvd1;
                T3_c0_mem_hdr_prefetch.vc_used   =  T2_c0.hdr.vc_used;
                T3_c0_mem_hdr_prefetch.mdata[15:16-VMID_WIDTH]    =  0;
                T3_c0_mem_hdr_prefetch.mdata[15-VMID_WIDTH:0]     =  T2_c0.hdr.mdata[15-VMID_WIDTH:0];

                /* candidate mmio request */
                T3_c0_mmio_hdr_prefetch.address[CCIP_MMIOADDR_WIDTH-1:10]  =   0;
                T3_c0_mmio_hdr_prefetch.address[9:0]  =  T2_mmio_req_hdr.address[9:0];
                T3_c0_mmio_hdr_prefetch.length   =  T2_mmio_req_hdr.length;
                T3_c0_mmio_hdr_prefetch.rsvd     =  T2_mmio_req_hdr.rsvd;
                T3_c0_mmio_hdr_prefetch.tid      =  T2_mmio_req_hdr.tid;
            end

            always_ff @(posedge clk)
            begin
                if (reset_qq[n])
                begin
                    T3_c0.rspValid <= 0;
                    T3_c0.mmioRdValid <= 0;
                    T3_c0.mmioWrValid <= 0;
                    T3_c1.rspValid <= 0;
                    T3_mgr_c0.rspValid <= 0;
                    T3_mgr_c0.mmioRdValid <= 0;
                    T3_mgr_c0.mmioWrValid <= 0;

                    T3_c0_vmid <= 0;
                    T3_c1_vmid <= 0;
                end
                else
                begin
                    /* fix c0 mdata */
                    if (T2_c0_choose_rsp)
                    begin
                        T3_c0_vmid          <=  T2_c0_vmid;
                        T3_c0.hdr           <=  T3_c0_mem_hdr_prefetch;
                        T3_c0.data          <=  T2_c0.data;
                        T3_c0.rspValid      <=  T2_c0.rspValid;
                        T3_c0.mmioRdValid   <=  0;
                        T3_c0.mmioWrValid   <=  0;

                        T3_mgr_c0           <=  t_if_ccip_c0_Rx'(0);
                    end
                    else if (T2_c0_choose_mmio)
                    begin
                        T3_c0_vmid          <=  T2_mmio_vmid;
                        T3_c0.hdr           <=  T3_c0_mmio_hdr_prefetch;
                        T3_c0.data          <=  T2_c0.data;
                        T3_c0.rspValid      <=  0;
                        T3_c0.mmioRdValid   <=  T2_c0.mmioRdValid;
                        T3_c0.mmioWrValid   <=  T2_c0.mmioWrValid;

                        T3_mgr_c0           <=  t_if_ccip_c0_Rx'(0);
                    end
                    else if (T2_is_ctl_mmio)
                    begin
                        T3_c0_vmid          <=  0;
                        T3_c0               <=  t_if_ccip_c0_Rx'(0);

                        T3_mgr_c0.hdr       <=  T3_c0_mmio_hdr_prefetch;
                        T3_mgr_c0.data      <=  T2_c0.data;
                        T3_mgr_c0.rspValid  <=  0;
                        T3_mgr_c0.mmioRdValid   <=  T2_c0.mmioRdValid;
                        T3_mgr_c0.mmioWrValid   <=  T2_c0.mmioWrValid;
                    end
                    else
                    begin
                        T3_c0_vmid  <=  0;
                        T3_c0       <=  t_if_ccip_c0_Rx'(0);
                        T3_mgr_c0   <=  t_if_ccip_c0_Rx'(0);
                    end

                    /* fix c1 mdata */
                    T3_c1.rspValid      <=  T2_c1.rspValid;

                    if (T2_c1.rspValid)
                    begin
                        T3_c1.hdr.resp_type <=  T2_c1.hdr.resp_type;
                        T3_c1.hdr.cl_num    <=  T2_c1.hdr.cl_num;
                        T3_c1.hdr.rsvd0     <=  T2_c1.hdr.rsvd0;
                        T3_c1.hdr.format    <=  T2_c1.hdr.format;
                        T3_c1.hdr.hit_miss  <=  T2_c1.hdr.hit_miss;
                        T3_c1.hdr.rsvd1     <=  T2_c1.hdr.rsvd1;
                        T3_c1.hdr.vc_used   <=  T2_c1.hdr.vc_used;
                        T3_c1.hdr.mdata[15:16-VMID_WIDTH]    <=  0;
                        T3_c1.hdr.mdata[15-VMID_WIDTH:0]     <=  T2_c1.hdr.mdata[15-VMID_WIDTH:0];
                        T3_c1_vmid          <=  T2_c1_vmid;
                    end
                    else
                    begin
                        T3_c1.hdr   <=  0;
                        T3_c1_vmid  <=  0;
                    end

                end
            end


            /* T3 to afu */
            t_if_ccip_c0_Rx T3_c0_to_afu;
            t_if_ccip_c1_Rx T3_c1_to_afu;
            logic [VMID_WIDTH-1:0] T3_c0_vmid_to_afu;
            logic [VMID_WIDTH-1:0] T3_c1_vmid_to_afu;

            always_ff @(posedge clk)
            begin
                T3_c0_to_afu        <=   T3_c0;
                T3_c1_to_afu        <=   T3_c1;

                T3_c0_vmid_to_afu   <=   T3_c0_vmid;
                T3_c1_vmid_to_afu   <=   T3_c1_vmid;
            end

            if (n == NUM_SUB_AFUS) begin
                /* output the mgr port */
                always_ff @(posedge clk)
                begin
                    mgr_RxPort.c0 <= T3_mgr_c0;
                    mgr_RxPort.c1 <= t_if_ccip_c1_Rx'(0);
                end
            end
            else
            begin
                always_ff @(posedge clk)
                begin
                    if (n == T3_c0_vmid_to_afu)
                    begin
                        afu_RxPort[n].c0 <= T3_c0_to_afu;
                    end
                    else 
                    begin
                        afu_RxPort[n].c0 <= t_if_ccip_c0_Rx'(0);
                    end

                    if (n == T3_c1_vmid_to_afu)
                    begin
                        afu_RxPort[n].c1 <= T3_c1_to_afu;
                    end
                    else
                    begin
                        afu_RxPort[n].c1 <= t_if_ccip_c1_Rx'(0);
                    end
                end
            end
        end
    endgenerate

endmodule
