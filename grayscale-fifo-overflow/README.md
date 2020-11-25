### Source
BBB: https://github.com/efeslab/optimus-intel-fpga-bbb/tree/0633e15416a67f49740a8a7ff6af0f9a7b99e8b3

grayscale: https://github.com/efeslab/hardcloud/tree/549015eaeba4d0d6de92248a2c2a7ddc42785457

### Synthetic Code
```verilog
module test (
        input logic clk,

        // read channel
        input logic rdch_almfull,
        output logic rdreq_valid,
        output t_rdreq rdreq,
        input logic rdrsp_valid,
        input t_rdrsp rdrsp,

        // write channel
        input logic wrch_almfull,
        output logic wrreq_valid,
        output t_wrreq wrreq,
        input logic wrrsp_valid,
        input t_wrrsp wrrsp
);

        t_wrreq enq_data;
        logic enq_data_valid;

        weird_module weird_inst(
                .clk(clk),
                .data_in(rdrsp),
                .data_in_valid(rdrsp_valid),
                .data_out(enq_data),
                .data_out_valid(enq_data_valid)
        );

        logic deq_en;
        initial deq_en = 0;

        fifo fifo_inst(
                .enq_data(enq_data),
                .enq_en(enq_data_valid),
                .deq_data(rdreq),
                .deq_en(deq_en)
        );

        always_ff @(posedge clk) begin
                if (~rdch_almfull) begin
                        rdreq <= get_next_rdreq();
                        rdreq_valid <= 1;
                end
                else begin
                        rdreq_valid <= 0;
                end
        end

        always_ff @(posedge clk) begin
                if (~wrch_almfull) begin
                        wrreq <= enq_data;
                        wrreq_valid <= 1;
                end
                else begin
                        wrreq_valid <= 0;
                end
        end

endmodule
```
