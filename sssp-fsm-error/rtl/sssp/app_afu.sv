`include "cci_mpf_if.vh"
`include "csr_mgr.vh"
`include "graph.vh"

module sssp_app_afu
(
    input logic clk,
    cci_mpf_if.to_fiu fiu,
    app_csrs.app csrs,
    input logic c0NotEmpty,
    input logic c1NotEmpty
);

    logic reset = 1'b1;
    always @(posedge clk)
    begin
        reset <= fiu.reset;
    end

    t_if_ccip_Rx mpf2af_sRx;
    t_if_ccip_Tx af2mpf_sTx;

    always_comb
    begin
		mpf2af_sRx.c0 = fiu.c0Rx;
        mpf2af_sRx.c1 = fiu.c1Rx;

        mpf2af_sRx.c0TxAlmFull = fiu.c0TxAlmFull;
        mpf2af_sRx.c1TxAlmFull = fiu.c1TxAlmFull;

        fiu.c0Tx = cci_mpf_cvtC0TxFromBase(af2mpf_sTx.c0);
        if (cci_mpf_c0TxIsReadReq(fiu.c0Tx))
        begin
            fiu.c0Tx.hdr.ext.addrIsVirtual = 1'b1;
            fiu.c0Tx.hdr.ext.mapVAtoPhysChannel = 1'b1;
            fiu.c0Tx.hdr.ext.checkLoadStoreOrder = 1'b1;
        end

        fiu.c1Tx = cci_mpf_cvtC1TxFromBase(af2mpf_sTx.c1);
        if (cci_mpf_c1TxIsWriteReq(fiu.c1Tx))
        begin
            fiu.c1Tx.hdr.ext.addrIsVirtual = 1'b1;
            fiu.c1Tx.hdr.ext.mapVAtoPhysChannel = 1'b1;
            fiu.c1Tx.hdr.ext.checkLoadStoreOrder = 1'b1;
            fiu.c1Tx.hdr.pwrite = t_cci_mpf_c1_PartialWriteHdr'(0);
        end

        fiu.c2Tx = af2mpf_sTx.c2;
    end

    sssp_app_top app_cci(
        .clk,
        .reset,
        .cp2af_sRx(mpf2af_sRx),
        .af2cp_sTx(af2mpf_sTx),
        .csrs,
        .c0NotEmpty,
        .c1NotEmpty
        );

endmodule

module sssp_app_top
(
    input logic clk,
    input logic reset,
    input t_if_ccip_Rx cp2af_sRx,
    output t_if_ccip_Tx af2cp_sTx,
    app_csrs.app csrs,
    input logic c0NotEmpty,
    input logic c1NotEmpty
);

    logic reset_r;
    assign reset_r = ~reset;

    t_if_ccip_Rx sRx;
    always_ff @(posedge clk)
    begin
        sRx <= cp2af_sRx;
    end

    t_if_ccip_Tx sTx;
	always_ff @(posedge clk)
    begin
        if (reset) begin
            af2cp_sTx.c0.valid <= 0;
        end
        else begin
            af2cp_sTx.c0 <= sTx.c0;
        end
    end
    assign af2cp_sTx.c2.mmioRdValid = 1'b0;

    /* sTx.c1 needs a buffer */
    logic fifo_c1tx_rdack, fifo_c1tx_dout_v, fifo_c1tx_full, fifo_c1tx_almFull;
    t_if_ccip_c1_Tx fifo_c1tx_dout;
    logic [7:0] fifo_c1tx_count;
	sync_C1Tx_fifo_copy #(
		.DATA_WIDTH($bits(t_if_ccip_c1_Tx)),
		.CTL_WIDTH(0),
		.DEPTH_BASE2($clog2(256)),
		.GRAM_MODE(3),
		.FULL_THRESH(256-8)
	)
	inst_fifo_c1tx(
		.Resetb(reset_r),
		.Clk(clk),
		.fifo_din(sTx.c1),
		.fifo_ctlin(),
		.fifo_wen(sTx.c1.valid),
		.fifo_rdack(fifo_c1tx_rdack),
		.T2_fifo_dout(fifo_c1tx_dout),
		.T0_fifo_ctlout(),
		.T0_fifo_dout_v(fifo_c1tx_dout_v),
		.T0_fifo_empty(),
		.T0_fifo_full(fifo_c1tx_full),
		.T0_fifo_count(fifo_c1tx_count),
		.T0_fifo_almFull(fifo_c1tx_almFull),
		.T0_fifo_underflow(),
		.T0_fifo_overflow()
		);

    logic fifo_c1tx_rdack_q, fifo_c1tx_rdack_qq;
    assign fifo_c1tx_rdack = fifo_c1tx_dout_v & ~sRx.c1TxAlmFull;
    always_ff @(posedge clk)
    begin
        if (reset)
        begin
            fifo_c1tx_rdack_q <= 0;
            fifo_c1tx_rdack_qq <= 0;
            af2cp_sTx.c1.valid <= 0;
        end
        else
        begin
            fifo_c1tx_rdack_q <= fifo_c1tx_dout_v & ~sRx.c1TxAlmFull;
            fifo_c1tx_rdack_qq <= fifo_c1tx_rdack_q;

            if (fifo_c1tx_rdack_qq)
                af2cp_sTx.c1 <= fifo_c1tx_dout;
            else
                af2cp_sTx.c1 <= t_if_ccip_c1_Tx'(0);
        end
    end
        
    logic [127:0] afu_id = 128'h4e38df2af09b4e6ba19521221b2ed2d6;

    t_ccip_c0_ReqMmioHdr mmio_req_hdr;
    assign mmio_req_hdr = t_ccip_c0_ReqMmioHdr'(sRx.c0.hdr);

    typedef enum {
        MAIN_FSM_IDLE,
        MAIN_FSM_READ_DESC,
        MAIN_FSM_LOAD_NEXT_DESC,
        MAIN_FSM_PREPARE_PREFETCH,
        MAIN_FSM_PREFETCH_DESC,
        MAIN_FSM_PREPARE_CONFIG,
        MAIN_FSM_CONFIG,
        MAIN_FSM_READ_VERTEX, /* read vertices */
        MAIN_FSM_PROCESS_EDGE_EARLY_START, /* still receiving vertices in this stage */
        MAIN_FSM_PROCESS_EDGE, /* all vertices are received */
        MAIN_FSM_WRITE_RESULT_FENCE,
        MAIN_FSM_WRITE_RESULT,
        MAIN_FSM_FINISH
    } main_fsm_state_t;
    main_fsm_state_t state;


    localparam MMIO_CSR_CONTROL = 0;

    t_ccip_clAddr csr_first_desc_addr;
    logic [3:0] dma_state;
    logic dma_pause;
    logic csr_ctl_start;
    logic csr_ctl_start_q;
    desc_t desc, next_desc;

    always_comb
    begin
        csrs.afu_id = afu_id;
        csrs.cpu_rd_csrs[MMIO_CSR_CONTROL].data = t_ccip_mmioData'({32'h0, 15'h0, dma_pause, 8'(state), 8'(dma_state)});
    end

    always_ff @(posedge clk)
    begin
		if (reset)
		begin
            csr_first_desc_addr <= t_ccip_clAddr'(0);
            csr_ctl_start <= 0;
            csr_ctl_start_q <= 0;
		end
        else
        begin
            if (csrs.cpu_wr_csrs[MMIO_CSR_CONTROL].en)
			begin
                csr_first_desc_addr <= t_ccip_clAddr'(csrs.cpu_wr_csrs[MMIO_CSR_CONTROL].data);
                csr_ctl_start <= 1'b1;
			end
            else
            begin
                csr_ctl_start <= 1'b0;
            end
            csr_ctl_start_q <= csr_ctl_start;
        end
    end

    t_ccip_clAddr dma_src_addr;
    logic [31:0] dma_src_ncl;
    logic dma_start;
    logic [511:0] dma_out, dma_out_q, dma_out_qq;
    logic dma_out_valid, dma_out_valid_q, dma_out_valid_qq;
    logic dma_done, dma_request_done;

    dma_read_engine dma_read(
        .clk(clk),
        .reset(reset),
        .src_addr(dma_src_addr),
        .src_ncl(dma_src_ncl),
        .start(dma_start),
        .pause(dma_pause),
        .c0rx(sRx.c0),
        .c0TxAlmFull(sRx.c0TxAlmFull),
        .c0tx(sTx.c0),
        .out(dma_out),
        .out_valid(dma_out_valid),
        .request_done(dma_request_done),
        .done(dma_done),
        .state_out(dma_state)
        );

    always_ff @(posedge clk)
    begin
        if (reset) begin
            dma_out_valid_q <= 0;
            dma_out_valid_qq <= 0;
        end
        else begin
            dma_out_q <= dma_out;
            dma_out_qq <= dma_out_q;
            dma_out_valid_q <= dma_out_valid;
            dma_out_valid_qq <= dma_out_valid_q;
        end
    end

    logic [31:0] sssp_word_in_addr;
    logic [1:0] sssp_control;
    logic [15:0] sssp_current_level;
    logic sssp_done;
    logic [31:0] sssp_update_entry_count;
    logic [511:0] sssp_word_out;
    logic sssp_word_out_valid;
    logic sssp_reset;

    logic sssp_last_input_in;

    sssp sssp_inst(
        .clk(clk),
        .rst(sssp_reset | reset),
        .last_input_in(sssp_last_input_in),
        .word_in(dma_out_qq),
        .w_addr(sssp_word_in_addr),
        .word_in_valid(dma_out_valid_qq),
        .control(sssp_control),
        .current_level(sssp_current_level),
        .done(sssp_done),
        .update_entry_count(sssp_update_entry_count),
        .word_out(sssp_word_out),
        .word_out_valid(sssp_word_out_valid)
        );

    logic responses_received;
    logic vertices_received;
    logic is_last_desc;

    /* the main state machine */
    always_ff @(posedge clk)
    begin
        if (reset) begin
            state <= MAIN_FSM_IDLE;
        end
        else begin
            case (state)
                MAIN_FSM_IDLE: begin
                     if (csr_ctl_start_q) begin
                         state <= MAIN_FSM_READ_DESC;
                     end
                end
                MAIN_FSM_READ_DESC: begin
                    if (dma_done) begin
                        state <= MAIN_FSM_PREPARE_PREFETCH;
                    end
                end
                MAIN_FSM_LOAD_NEXT_DESC: begin
                    state <= MAIN_FSM_PREPARE_PREFETCH;
                end
                MAIN_FSM_PREPARE_PREFETCH: begin
                    if (~dma_request_done) begin
                        state <= MAIN_FSM_PREFETCH_DESC;
                    end
                end
                MAIN_FSM_PREFETCH_DESC: begin
                    if (dma_request_done || is_last_desc) begin
                        state <= MAIN_FSM_PREPARE_CONFIG;
                    end
                end
                MAIN_FSM_PREPARE_CONFIG: begin
                    if (~dma_request_done) begin
                        state <= MAIN_FSM_CONFIG;
                    end
                end
                MAIN_FSM_CONFIG: begin
                    state <= MAIN_FSM_READ_VERTEX;
                end
                MAIN_FSM_READ_VERTEX: begin
                    if (dma_request_done) begin
                        state <= MAIN_FSM_PROCESS_EDGE_EARLY_START;
                    end
                end
                MAIN_FSM_PROCESS_EDGE_EARLY_START: begin
                    if (vertices_received) begin
                        state <= MAIN_FSM_PROCESS_EDGE;
                    end
                end
                MAIN_FSM_PROCESS_EDGE: begin
                    if (sssp_done) begin
                        state <= MAIN_FSM_WRITE_RESULT_FENCE;
                    end
                end
                MAIN_FSM_WRITE_RESULT_FENCE: begin
                    state <= MAIN_FSM_WRITE_RESULT;
                end
                MAIN_FSM_WRITE_RESULT: begin
                    if (is_last_desc) begin
                        state <= MAIN_FSM_FINISH;
                    end
                    else begin
                        state <= MAIN_FSM_LOAD_NEXT_DESC;
                    end
                end
                MAIN_FSM_FINISH: begin
                    state <= MAIN_FSM_IDLE;
                end
            endcase
        end
    end

    assign sssp_last_input_in = dma_done && state == MAIN_FSM_PROCESS_EDGE;

    logic vertex_dma_started, edge_dma_started, desc_dma_started;
    logic prefetch_desc_received, prefetch_desc_received_q, prefetch_desc_received_qq;
    logic desc_prefetch_dma_started;
    logic [31:0] write_cls;
    logic [31:0] num_write_req;
    logic [31:0] num_write_rsp;
    logic [8:0] vertex_need_cnt;
    logic [8:0] vertex_receive_cnt;

    t_ccip_c1_ReqMemHdr default_c1_memhdr;
    t_ccip_c1_ReqFenceHdr default_c1_fencehdr;

    always_comb
    begin
        default_c1_memhdr.sop = 1'b1;
        default_c1_memhdr.vc_sel = eVC_VA;
        default_c1_memhdr.cl_len = eCL_LEN_1;
        default_c1_memhdr.req_type = eREQ_WRLINE_I;
        default_c1_memhdr.address = t_ccip_clAddr'(0);
        default_c1_memhdr.mdata = 0;
        default_c1_memhdr.rsvd0 = 0;
        default_c1_memhdr.rsvd1 = 0;
        default_c1_memhdr.rsvd2 = 0;

        default_c1_fencehdr.vc_sel = eVC_VA;
        default_c1_fencehdr.req_type = eREQ_WRFENCE;
        default_c1_fencehdr.mdata = 0;
        default_c1_fencehdr.rsvd0 = 0;
        default_c1_fencehdr.rsvd1 = 0;
        default_c1_fencehdr.rsvd2 = 0;
    end

    assign vertices_received = vertex_receive_cnt == vertex_need_cnt;

    always_ff @(posedge clk)
    begin
        if (vertex_receive_cnt > vertex_need_cnt) begin
            $error("received vertices exceeds needed vertices");
        end
    end

    /* dma read, sssp, and write request */
    always_ff @(posedge clk)
    begin
        if (reset) begin
            sssp_reset <= 1;
            vertex_dma_started <= 0;
            edge_dma_started <= 0;
            desc_dma_started <= 0;
            desc_prefetch_dma_started <= 0;
            prefetch_desc_received <= 0;
            prefetch_desc_received_q <= 0;
            prefetch_desc_received_qq <= 0;
            sTx.c1.valid <= 0;
            dma_src_addr <= t_ccip_clAddr'(32'hffff0000);
            dma_src_ncl <= 32'hffffffff;
            dma_start <= 0;
            dma_pause <= 0;
            num_write_req <= 0;
            vertex_need_cnt <= 0;
            vertex_receive_cnt <= 0;
        end
        else begin
            sssp_reset <= 0;
            sTx.c1.valid <= 0;

            prefetch_desc_received_q <= prefetch_desc_received;
            prefetch_desc_received_qq <= prefetch_desc_received_q;

            if (fifo_c1tx_count >= 12) begin
                dma_pause <= 1;
            end
            else if (fifo_c1tx_count <= 4) begin
                dma_pause <= 0;
            end

            case (state)
                MAIN_FSM_IDLE: begin
                    dma_start <= 0;
                    desc_dma_started <= 0;
                    vertex_dma_started <= 0;
                    edge_dma_started <= 0;
                    is_last_desc <= 0;

                    sssp_reset <= 1;
                    sssp_control <= 0;
                    sssp_word_in_addr <= 0;

                    vertex_need_cnt <= 0;
                    vertex_receive_cnt <= 0;

                    //num_write_req <= 0;

                    desc.next_desc_addr <= csr_first_desc_addr;
                end
                MAIN_FSM_READ_DESC: begin
                    /* start dma */
                    if (desc_dma_started) begin
                        dma_start <= 0;
                    end
                    else begin
                        dma_start <= 1;
                        desc_dma_started <= 1;
                    end

                    /* configure dma address */
                    dma_src_addr <= desc.next_desc_addr;
                    dma_src_ncl <= 32'h1;

                    /* reset vertex counters */
                    vertex_need_cnt <= 0;
                    vertex_receive_cnt <= 0;

                    /* config */
                    if (dma_out_valid) begin
                        desc <= int512_to_desc(dma_out);
                    end
                    sssp_reset <= 1;
                end
                MAIN_FSM_LOAD_NEXT_DESC: begin
                    desc <= next_desc;
                    sssp_reset <= 1;

                    /* reset vertex counters */
                    vertex_need_cnt <= 0;
                    vertex_receive_cnt <= 0;
                end
                MAIN_FSM_PREPARE_PREFETCH: begin
                    /* we need to make dma_request_done 0 in this stage */
                    dma_src_ncl <= 32'hffffffff;
                end
                MAIN_FSM_PREFETCH_DESC: begin
                    if (desc_prefetch_dma_started) begin
                        dma_start <= 0;
                    end
                    else if (desc.next_desc_addr != 0) begin
                        dma_start <= 1;
                        desc_prefetch_dma_started <= 1;
                        dma_src_addr <= desc.next_desc_addr;
                        dma_src_ncl <= 32'h1;
                    end
                    else begin
                        is_last_desc <= 1;
                        prefetch_desc_received <= 1;
                        dma_src_ncl <= 32'h0;
                    end
                    sssp_reset <= 1;
                end
                MAIN_FSM_PREPARE_CONFIG: begin
                    dma_src_ncl <= 32'hffffffff;
                end
                MAIN_FSM_CONFIG: begin
                    sssp_word_in_addr <= desc.vertex_idx;
                    write_cls <= 0;

                    /* configure dma address */
                    dma_src_addr <= desc.vertex_addr;
                    dma_src_ncl <= desc.vertex_ncl;
                end
                MAIN_FSM_READ_VERTEX: begin
                    /* we need to receive the next_desc here */
                    if (!is_last_desc && dma_out_valid && ~prefetch_desc_received) begin
                        next_desc <= int512_to_desc(dma_out);
                        prefetch_desc_received <= 1;
                    end

                    /* start dma when entering this state */
                    if (vertex_dma_started) begin
                        dma_start <= 0;
                    end
                    else begin
                        dma_start <= 1;
                        vertex_dma_started <= 1;
                    end

                    /* configure vertex counters */
                    vertex_need_cnt <= 9'(desc.vertex_ncl);
                    if (prefetch_desc_received) begin
                        vertex_receive_cnt <= vertex_receive_cnt + dma_out_valid;
                    end

                    /* configure sssp */
                    sssp_control <= 2'b01;
                    if (prefetch_desc_received_qq) begin
                        sssp_word_in_addr <= (sssp_word_in_addr + (dma_out_valid_qq << 3));
                    end
                end
                MAIN_FSM_PROCESS_EDGE_EARLY_START: begin
                    /* it is also possible that the desc comes back here */
                    if (!is_last_desc && dma_out_valid && ~prefetch_desc_received) begin
                        next_desc <= int512_to_desc(dma_out);
                        prefetch_desc_received <= 1;
                    end

                    /* start dma for edges when entering this state, at this time
                     * it is gauranteed that the dma read engine is in wait status */
                    if (edge_dma_started) begin
                        dma_start <= 0;
                    end
                    else begin
                        dma_start <= 1;
                        edge_dma_started <= 1;
                    end

                    /* configure dma address */
                    dma_src_addr <= desc.edge_addr;
                    dma_src_ncl <= desc.edge_ncl;

                    /* configure sssp */
                    sssp_control <= 2'b01;
                    if (prefetch_desc_received_qq) begin
                        sssp_word_in_addr <= (sssp_word_in_addr + (dma_out_valid_qq << 3));
                    end

                    if (prefetch_desc_received) begin
                        vertex_receive_cnt <= vertex_receive_cnt + dma_out_valid;
                    end
                end
                MAIN_FSM_PROCESS_EDGE: begin
                    /* send out requests */
                    sTx.c1.valid <= sssp_word_out_valid;
                    sTx.c1.hdr <= default_c1_memhdr;
                    sTx.c1.hdr.address <= desc.update_bin_addr + write_cls;
                    sTx.c1.data <= sssp_word_out;
                    write_cls <= write_cls + sssp_word_out_valid;
                    num_write_req <= num_write_req + sssp_word_out_valid;

                    /* configure sssp */
                    sssp_control <= 2'b10;
                    sssp_current_level <= desc.level;
                end
                MAIN_FSM_WRITE_RESULT_FENCE: begin
                    num_write_req <= num_write_req + 1;
                    sTx.c1.valid <= 1;
                    sTx.c1.hdr <= default_c1_fencehdr;
                end
                MAIN_FSM_WRITE_RESULT: begin
                    num_write_req <= num_write_req + 1;
                    sTx.c1.valid <= 1;
                    sTx.c1.hdr <= default_c1_memhdr;
                    sTx.c1.hdr.address <= desc.status_addr;
                    sTx.c1.data <= {256'h0, 32'h0, sssp_update_entry_count, 64'h1};

                    /* Now these dma control signals should all be 1,
                     * reset them to 0 here. */
                    desc_dma_started <= 0;
                    vertex_dma_started <= 0;
                    edge_dma_started <= 0;
                    desc_prefetch_dma_started <= 0;
                    prefetch_desc_received <= 0;
                end
                MAIN_FSM_FINISH: begin
                    /* do nothing here */
                end
            endcase
        end
    end

	/* handle write response */
	always_ff @(posedge clk)
	begin
		if (reset) begin
			num_write_rsp <= 32'h0;
            responses_received <= 0;
            num_write_rsp <= 0;
		end
        else begin
            if (state == MAIN_FSM_IDLE) begin
                //num_write_rsp <= 0;
            end
            else if (sRx.c1.rspValid == 1'b1) begin
                num_write_rsp <= num_write_rsp + 1;
            end
            responses_received <= (num_write_req == num_write_rsp);
		end
	end
endmodule
