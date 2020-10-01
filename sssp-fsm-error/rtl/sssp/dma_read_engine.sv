`include "cci_mpf_if.vh"

/* In this module we assume read responses come back in,
 * sequence, which can be achieved with the help of MPF. */
module dma_read_engine
(
    input logic clk,
    input logic reset,

    input t_ccip_clAddr src_addr,
    input logic [31:0] src_ncl,
    input logic start,
    input logic pause,

    input t_if_ccip_c0_Rx c0rx,
    input logic c0TxAlmFull,
    output t_if_ccip_c0_Tx c0tx,
    
    output logic [511:0] out,
    output logic out_valid,
    output logic request_done,
    output logic done,

    output logic [3:0] state_out
);

    typedef enum {
        STATE_IDLE,
        STATE_AUTO_START,
        STATE_READ_RUN,
        STATE_READ_PAUSE,
        STATE_READ_WAIT,
        STATE_FINISH
    } rd_state_t;
    rd_state_t state;

    assign state_out = state;

    logic [31:0] req_idx, rsp_idx;
    logic req_done, rsp_done;
    logic go_pause;

    assign req_done = req_idx == src_ncl;
    assign rsp_done = rsp_idx == src_ncl;

    /* state machine */
    always_ff @(posedge clk)
    begin
        if (reset) begin
            state <= STATE_IDLE;
        end
        else begin
            case (state)
                STATE_IDLE: begin
                    if (start) begin
                        state <= STATE_READ_RUN;
                    end
                end
                STATE_AUTO_START: begin
                    state <= STATE_READ_RUN;
                end
                STATE_READ_RUN: begin
                    if (req_done) begin
                        state <= STATE_READ_WAIT;
                    end
                    else if (c0TxAlmFull || pause || go_pause) begin
                        state <= STATE_READ_PAUSE;
                    end
                end
                STATE_READ_PAUSE: begin
                    if (!c0TxAlmFull && !pause) begin
                        state <= STATE_READ_RUN;
                    end
                end
                STATE_READ_WAIT: begin
                    if (start) begin
                        state <= STATE_AUTO_START;
                    end
                    else if (rsp_done) begin
                        state <= STATE_FINISH;
                    end
                end
                STATE_FINISH: begin
                    state <= STATE_IDLE;
                end
            endcase
        end
    end

    logic c0rx_valid;
    assign c0rx_valid = c0rx.rspValid;

    /* requset */
    always_ff @(posedge clk)
    begin
        if (reset) begin
            req_idx <= 0;
            c0tx.valid <= 1'b0;
        end
        else begin
            c0tx.valid <= 1'b0;

            case (state)
                STATE_IDLE,
                STATE_AUTO_START: begin
                    req_idx <= 0;
                end
                STATE_READ_RUN: begin
                    /* Check the valid signal here. After sending out
                     * the last request, req_idx becomes src_ncl. However,
                     * the FSM may keep in the run state for an additional
                     * cycle. */
                    c0tx <= t_if_ccip_c0_Tx'(0);
                    c0tx.valid <= (req_idx != src_ncl);
                    c0tx.hdr.vc_sel <= eVC_VA;
                    c0tx.hdr.cl_len <= eCL_LEN_1;
                    c0tx.hdr.req_type <= eREQ_RDLINE_S;
                    c0tx.hdr.address <= src_addr + req_idx;

                    req_idx <= req_idx + (req_idx != src_ncl);

                    /* debug */
                    if (req_idx > src_ncl) begin
                        $display("fatal error. req_idx > src_ncl!\n");
                        $finish;
                    end
                end
                STATE_READ_PAUSE,
                STATE_READ_WAIT,
                STATE_FINISH: begin
                    /* do nothing here */
                end
            endcase
        end
    end

    logic req_valid;
    assign req_valid = req_idx != src_ncl && state == STATE_READ_RUN;
    logic [31:0] on_the_fly;
    always_ff @(posedge clk)
    begin
        if (reset) begin
            on_the_fly <= 0;
            go_pause <= 0;
        end
        else begin
            case ({c0tx.valid,c0rx_valid})
                2'b00: on_the_fly <= on_the_fly;
                2'b01: on_the_fly <= on_the_fly - 1;
                2'b10: on_the_fly <= on_the_fly + 1;
                2'b11: on_the_fly <= on_the_fly;
            endcase
            go_pause <= on_the_fly > 222;
        end
    end
                    
    /* response */
    always_ff @(posedge clk)
    begin
        if (reset) begin
            rsp_idx <= 0;
            out_valid <= 1'b0;
            done <= 0;
        end
        else begin
            /* It's fine to always feed the data to 'out',
             * since we can control the valid signal. */
            out <= c0rx.data;
            out_valid <= 1'b0;
            done <= 0;
            request_done <= req_done;

            if (c0rx_valid) begin
                out_valid <= 1'b1;
                rsp_idx <= rsp_idx + 1;
            end

            case (state)
                STATE_IDLE,
                STATE_AUTO_START: begin
                    rsp_idx <= 0 - on_the_fly;
                end
                STATE_READ_PAUSE,
                STATE_READ_WAIT,
                STATE_READ_RUN: begin
                    /* do nothing */
                end
                STATE_FINISH: begin
                    done <= 1;
                end
            endcase
        end
    end

endmodule
