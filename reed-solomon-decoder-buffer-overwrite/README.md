### Source
BBB: https://github.com/efeslab/optimus-intel-fpga-bbb/tree/0633e15416a67f49740a8a7ff6af0f9a7b99e8b3
rsd: https://github.com/efeslab/hardcloud/tree/b40185e13f6d7d7a613218e26913d860c8384130/samples/reed_solomon_decoder

### Synthetic Bug
```
module test (
        input logic clk,

        // input channel, i_request and i_valid are asynchronize
        input logic [63:0] i_data,
        input logic i_valid,
        output logic i_request,

        // output channel, when o_almfull is asserted, no more than 8 packet can be issued
        output logic [63:0] o_data,
        output logic o_valid,
        input logic o_almfull
);

        always_ff @(posedge clk) begin
                i_request <= !o_almfull;
        end

        logic weird_out;
        logic weird_out_valid;

        // a weird module, take 64-bit input and generate 1-bit output
        weird_module weird_inst(
                .clk(clk),
                .i_data(i_data),
                .i_valid(i_valid),
                .o_data(weird_out), // this is an 1 bit output
                .o_valid(weird_out_valid)
        );

        logic [63:0] buffer;
        logic [5:0] ptr;
        initial buffer = 64'h0;
        initial ptr = 6'h0;

        always_ff @(posedge clk) begin
                if (weird_out_valid) begin
                        buffer[63 - ptr] <= weird_out;
                        ptr <= ptr + 1;
                end
        end

        typedef enum {
                DO_WAIT,
                DO_OUT
        } state_t;
        state_t state;
        initial state = DO_WAIT;

        always_ff @(posedge clk) begin
                case(state)
                        DO_WAIT: if (weird_out_valid && wr_ptr == '1) state <= DO_OUT;
                        DO_OUT: if (!o_almfull) state <= DO_WAIT;
                endcase
        end

        always_ff @(posedge clk) begin
                case(state)
                        DO_WAIT: o_valid <= 0;
                        DO_OUT:
                                if (!o_almfull) begin
                                        o_valid <= 1;
                                        o_data <= buffer;
                                end
                                else begin
                                        o_valid <= 0;
                                end
                endcase
        end
endmodule
```
