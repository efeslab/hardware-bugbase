`include "platform_if.vh"
`include "vendor_defines.vh"
module vai_mgr # (parameter NUM_SUB_AFUS=8)
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
    output	        t_if_ccip_Rx      afu_RxPort,           // to mux rx port
    input     		t_if_ccip_Tx	  afu_TxPort,		 	// from mux tx port

    output  logic [63:0]            offset_array    [NUM_SUB_AFUS-1:0],  // to tx auditor
    output  logic [63:0]            sub_afu_reset
);

    localparam LNUM_SUB_AFUS = $clog2(NUM_SUB_AFUS);
    localparam VMID_WIDTH = LNUM_SUB_AFUS;


    logic clk;
    logic reset=1, reset_r=0;
    assign clk = pClk;

    always @(posedge clk)
    begin
        reset <= pck_cp2af_softReset;
        reset_r <= ~reset;;
    end

    logic mgr_c0tx_sidebuf_overflow;
    logic mgr_c1tx_sidebuf_overflow;
    logic mgr_c2tx_overflow_T0;
    logic mgr_c2tx_underflow_T0;
    logic mgr_c2tx_overflow;
    logic mgr_c2tx_underflow;

    logic mgr_c0tx_conflict;
    logic mgr_c1tx_conflict;

    always @(posedge clk)
    begin
        if (reset)
        begin
            mgr_c2tx_overflow <= 0;
            mgr_c2tx_underflow <= 0;
        end
        else
        begin
            if (mgr_c2tx_overflow_T0)
                mgr_c2tx_overflow <= 1;
            if (mgr_c2tx_underflow_T0)
                mgr_c2tx_underflow <= 1;
        end
    end


    /* T0: connect to ccip */
    t_if_ccip_Rx sRx;
    t_if_ccip_Tx sTx;
    assign sRx = pck_cp2af_sRx;
    assign pck_af2cp_sTx = sTx;


    /* T1: register */
    t_ccip_clData T1_mmio_data;
    t_ccip_c0_ReqMmioHdr T1_mmio_req_hdr;
    logic T1_is_mmio_read;
    logic T1_is_mmio_write;
    t_if_ccip_Rx T1_Rx_temp;

    logic c0tx_buf_almfull, c1tx_buf_almfull;

    always_ff @(posedge clk)
    begin
        if (reset)
        begin
            T1_mmio_data <= 0;
            T1_mmio_req_hdr <= 0;
            T1_is_mmio_read <= 0;
            T1_is_mmio_write <= 0;
            T1_Rx_temp <= 0;
        end
        else
        begin
            T1_mmio_data <= sRx.c0.data;
            T1_mmio_req_hdr <= sRx.c0.hdr;
            T1_is_mmio_read <= sRx.c0.mmioRdValid;
            T1_is_mmio_write <= sRx.c0.mmioWrValid;
            T1_Rx_temp <= sRx;
        end
    end

    /* T1: output */
    /* we do not support read and write from mgr_afu */
    always_ff @(posedge clk)
    begin
        afu_RxPort.c0 <= T1_Rx_temp.c0;
        afu_RxPort.c1 <= T1_Rx_temp.c1;
        afu_RxPort.c0TxAlmFull <= sRx.c0TxAlmFull | c0tx_buf_almfull;
        afu_RxPort.c1TxAlmFull <= sRx.c1TxAlmFull | c0tx_buf_almfull;
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
    logic T2_is_ctl_mmio;
	//t_if_ccip_Rx T2_Rx_temp;

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
            //T2_Rx_temp <= 0;
        end
        else
        begin
        	T2_is_ctl_mmio <= (T1_mmio_req_hdr.address[CCIP_MMIOADDR_WIDTH-1:10] == 0);
        	//T2_Rx_temp <= T1_Rx_temp;
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
    logic [LNUM_SUB_AFUS-1:0] T3_vmid;
	logic T3_is_ctl_mmio;
	logic T3_is_read;
    logic [127:0] mgr_id;
    assign mgr_id = 128'hd1d383aaca4c4c60a0a013a421139e69;

    always_ff @(posedge clk)
    begin
        if (reset)
        begin
            /*
            for (int i=0; i<NUM_SUB_AFUS; i++)
            begin
                offset_array[i] <= 0;
                user_clk_array[i] <= 0;
            end
            */

            T3_Tx_c2.mmioRdValid <= 0;
            sub_afu_reset <= 0;
            T3_is_ctl_mmio <= 0;
            T3_is_read <= 0;
        end
        else
        begin
        	T3_is_ctl_mmio <= T2_is_ctl_mmio;
            T3_vmid <= T2_vmid;
            if (T2_is_write && T2_is_ctl_mmio)
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

            if (T2_is_read && T2_is_ctl_mmio)
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
                    T3_Tx_c2.data <= t_if_ccip_c2_Tx'(0);
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
                    T3_Tx_c2.data <= 64'h0;
                    T3_Tx_c2.data[0] <= mgr_c0tx_sidebuf_overflow;
                    T3_Tx_c2.data[1] <= mgr_c1tx_sidebuf_overflow;
                    T3_Tx_c2.data[4] <= mgr_c2tx_overflow;
                    T3_Tx_c2.data[5] <= mgr_c2tx_underflow;
                    T3_Tx_c2.data[6] <= mgr_c0tx_conflict;
                    T3_Tx_c2.data[7] <= mgr_c1tx_conflict;
                end
            end
            else
            begin
                T3_Tx_c2 <= 0;
            end
            T3_is_read <= T2_is_read;
        end
    end

    localparam TX_BUF_SIZE = 3;
    localparam LOG_TX_BUF_SIZE = $clog2(TX_BUF_SIZE);
    (* ramstyle = "logic" *) t_if_ccip_c0_Tx c0tx_buf [TX_BUF_SIZE-1:0];
    (* ramstyle = "logic" *) t_if_ccip_c1_Tx c1tx_buf [TX_BUF_SIZE-1:0];
    logic [2:0] c0tx_buf_cnt, c1tx_buf_cnt;
    logic [2:0] c0tx_buf_cnt2, c1tx_buf_cnt2;
    logic [4:0] c0tx_balance, c1tx_balance;

    always_ff @(posedge clk)
    begin
        if (reset)
        begin
            sTx.c0.valid <= 0;
            sTx.c1.valid <= 0;
            c0tx_buf_cnt <= 0;
            c0tx_buf_cnt2 <= 0;
            c1tx_buf_cnt <= 0;
            c1tx_buf_cnt2 <= 0;
            mgr_c0tx_sidebuf_overflow <= 0;
            mgr_c1tx_sidebuf_overflow <= 0;
            mgr_c0tx_conflict <= 0;
            mgr_c1tx_conflict <= 0;
        end
        else
        begin
            if (~sRx.c0TxAlmFull)
                c0tx_balance <= 0;
            else if (sTx.c0.valid)
                c0tx_balance <= c0tx_balance + 1;
            else
                c0tx_balance <= c0tx_balance;

            if (~sRx.c1TxAlmFull)
                c1tx_balance <= 0;
            else if (sTx.c1.valid)
                c1tx_balance <= c1tx_balance + 1;
            else
                c1tx_balance <= c1tx_balance;

            if (c0tx_balance >= 5 && afu_TxPort.c0.valid)
            begin
                c0tx_buf[c0tx_buf_cnt] <= afu_TxPort.c0;
                c0tx_buf_cnt <= c0tx_buf_cnt + 1;
                c0tx_buf_cnt2 <= c0tx_buf_cnt + 1;
                sTx.c0.valid <= 0;

                if (c0tx_buf_cnt == TX_BUF_SIZE)
                begin
                    mgr_c0tx_sidebuf_overflow <= 1;
                    $error("c0tx side buffer overflow detected");
                end
            end
            else if (~sRx.c0TxAlmFull && c0tx_buf_cnt != 0)
            begin
                sTx.c0 <= c0tx_buf[c0tx_buf_cnt2-c0tx_buf_cnt];
                c0tx_buf_cnt <= c0tx_buf_cnt - 1;

                if (afu_TxPort.c0.valid)
                begin
                    mgr_c0tx_conflict <= 1;
                    $error("c0tx side buffer and afu packet conflict");
                end
            end
            else
                sTx.c0 <= afu_TxPort.c0;

            if (c1tx_balance >= 5 && afu_TxPort.c1.valid)
            begin
                c1tx_buf[c1tx_buf_cnt] <= afu_TxPort.c1;
                c1tx_buf_cnt <= c1tx_buf_cnt + 1;
                c1tx_buf_cnt2 <= c1tx_buf_cnt + 1;
                sTx.c1.valid <= 0;

                if (c1tx_buf_cnt == TX_BUF_SIZE)
                begin
                    mgr_c1tx_sidebuf_overflow <= 1;
                    $error("c1tx side buffer overflow detected");
                end
            end
            else if (~sRx.c1TxAlmFull && c1tx_buf_cnt != 0)
            begin
                sTx.c1 <= c1tx_buf[c1tx_buf_cnt2-c1tx_buf_cnt];
                c1tx_buf_cnt <= c1tx_buf_cnt - 1;

                if (afu_TxPort.c1.valid)
                begin
                    mgr_c1tx_conflict <= 1;
                    $error("c1tx side buffer and afu packet conflict");
                end
            end
            else
                sTx.c1 <= afu_TxPort.c1;

            c0tx_buf_almfull <= (c0tx_buf_cnt!=0);
            c1tx_buf_almfull <= (c1tx_buf_cnt!=0);
        end
    end
    
	logic fifo_c2tx_rdack, fifo_c2tx_dout_v, fifo_c2tx_full, fifo_c2tx_almFull;
    t_if_ccip_c2_Tx fifo_c2tx_dout;
    logic fifo_c2tx_dout_v_T1, fifo_c2tx_dout_v_T2;
	sync_C1Tx_fifo #(
		.DATA_WIDTH($bits(t_if_ccip_c2_Tx)),
		.CTL_WIDTH(0),
		.DEPTH_BASE2($clog2(4)),
		.GRAM_MODE(3),
		.FULL_THRESH(2)
	)
	inst_fifo_c2tx(
		.Resetb(reset_r),
		.Clk(clk),
		.fifo_din(afu_TxPort.c2),
		.fifo_ctlin(),
		.fifo_wen(afu_TxPort.c2.mmioRdValid),
		.fifo_rdack(fifo_c2tx_rdack),
		.T2_fifo_dout(fifo_c2tx_dout),
		.T0_fifo_ctlout(),
		.T0_fifo_dout_v(fifo_c2tx_dout_v),
		.T0_fifo_empty(),
		.T0_fifo_full(fifo_c2tx_full),
		.T0_fifo_count(),
		.T0_fifo_almFull(fifo_c2tx_almFull),
		.T0_fifo_underflow(mgr_c2tx_underflow_T0),
		.T0_fifo_overflow(mgr_c2tx_overflow_T0)
		);
    assign fifo_c2tx_rdack = fifo_c2tx_dout_v;
	always_ff @(posedge clk)
    begin
    	if (T3_is_read && T3_is_ctl_mmio) 
    	begin
    		sTx.c2 <= T3_Tx_c2;
    	end 
    	else 
    	begin
    		if (fifo_c2tx_dout_v_T2)
    			sTx.c2 <= fifo_c2tx_dout;
            else
                sTx.c2.mmioRdValid <= 0;
    	end 
    	
        fifo_c2tx_dout_v_T2 <= fifo_c2tx_dout_v_T1;
        fifo_c2tx_dout_v_T1 <= fifo_c2tx_dout_v;	
    end	



endmodule
