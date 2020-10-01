`include "graph.vh"

module sssp #(
    parameter ADDR_W = 8)
(
    input logic clk,
    input logic rst,
    input logic last_input_in,
    input logic [511:0] word_in,
    input logic [31:0] w_addr,
    input logic word_in_valid,
    input logic [1:0] control,
    input logic [15:0] current_level,

    output logic done,
    output logic [31:0] update_entry_count,
    output logic [511:0] word_out,
    output logic word_out_valid
);

    logic [3:0] pipeline_last_input_out;
    logic [63:0] pipeline_word_out [3:0];
    logic [3:0] pipeline_word_out_valid;

    integer i;

    /* verilator lint_off PINMISSING */
    genvar k;
    generate
        for (k = 0; k < 4; k = k + 1)
        begin: pipeline
            sssp_pipeline #(.ADDR_W(ADDR_W), .pipeline_id(k))
            pipe(
                .clk(clk),
                .rst(rst),
                .last_input_in(last_input_in),
                .word_in(word_in),
                .w_addr(w_addr),
                .word_in_valid(word_in_valid),
                .control(control),
                .current_level(current_level),
                .last_input_out(pipeline_last_input_out[k]),
                .word_out(pipeline_word_out[k]),
                .valid_out(pipeline_word_out_valid[k])
                );
        end
    endgenerate
    /* verilator lint_on PINMISSING */

    logic filter_last_input_out;
    logic [3:0] filter_word_out_valid;
    logic [63:0] filter_word_out [3:0];

    filter filter_inst(
        .clk(clk),
        .rst(rst),
        .last_input_in(pipeline_last_input_out[0]),
        .word_in_valid(pipeline_word_out_valid),
        .word_in(pipeline_word_out),
        .last_input_out(filter_last_input_out),
        .word_out_valid(filter_word_out_valid),
        .word_out(filter_word_out)
        );


    logic [63:0] update_buffer [6:0];
    logic [2:0] buffer_counter;
    logic filter_last_input_out_q;
    logic [31:0] total_counter;

    /* buffer the valid outputs */
    always_ff @(posedge clk)
    begin
        if (rst) begin
            done <= 1'b0;
            buffer_counter <= 0;
            word_out <= 0;
            word_out_valid <= 0;
            filter_last_input_out_q <= 0;
            total_counter <= 0;
            update_entry_count <= 0;
        end
        else begin
            filter_last_input_out_q <= filter_last_input_out;

            if (filter_last_input_out_q) begin
                done <= 1'b1;
                update_entry_count <= total_counter + buffer_counter;
                if (buffer_counter) begin
                    for (i = 0; i < 7; i = i + 1) begin
                        word_out[i * 64 +: 64] <= update_buffer[i];
                    end
                    word_out[7 * 64 +: 64] <= 64'h0;
                    word_out_valid <= 1'b1;
                end
                else begin
                    word_out_valid <= 1'b0;
                end
            end
            else begin
                case (filter_word_out_valid)
                    4'b0000: begin
                        buffer_counter <= buffer_counter;
                        word_out_valid <= 1'b0;
                    end
                    4'b0001: begin
                        if (buffer_counter < 7) begin
                            buffer_counter <= buffer_counter + 1;
                            update_buffer[buffer_counter] <= filter_word_out[0];
                            word_out_valid <= 1'b0;
                        end
                        else begin
                            buffer_counter <= 0;
                            word_out_valid <= 1'b1;

                            for (i = 0; i < 7; i = i + 1) begin
                                word_out[i * 64 +: 64] <= update_buffer[i];
                            end
                            word_out[7 * 64 +: 64] <= filter_word_out[0];

                            total_counter <= total_counter + 8;
                        end
                    end
                    4'b0011: begin
                        if (buffer_counter < 6) begin
                            buffer_counter <= buffer_counter + 2;
                            update_buffer[buffer_counter] <= filter_word_out[0];
                            update_buffer[buffer_counter + 1] <= filter_word_out[1];
                            word_out_valid <= 1'b0;
                        end
                        else if (buffer_counter == 6) begin
                            buffer_counter <= 0;
                            word_out_valid <= 1'b1;

                            for (i = 0; i < 6; i = i + 1) begin
                                word_out[i * 64 +: 64] <= update_buffer[i];
                            end
                            word_out[6 * 64 +: 64] <= filter_word_out[0];
                            word_out[7 * 64 +: 64] <= filter_word_out[1];

                            total_counter <= total_counter + 8;
                        end
                        else begin
                            buffer_counter <= 1;
                            word_out_valid <= 1'b1;

                            for (i = 0; i < 7; i = i + 1) begin
                                word_out[i * 64 +: 64] <= update_buffer[i];
                            end
                            word_out[7 * 64 +: 64] <= filter_word_out[0];
                            update_buffer[0] <= filter_word_out[1];

                            total_counter <= total_counter + 8;
                        end
                    end
                    4'b0111: begin
                        if (buffer_counter < 5) begin
                            buffer_counter <= buffer_counter + 3;
                            update_buffer[buffer_counter] <= filter_word_out[0];
                            update_buffer[buffer_counter + 1] <= filter_word_out[1];
                            update_buffer[buffer_counter + 2] <= filter_word_out[2];
                            word_out_valid <= 1'b0;
                        end
                        else if (buffer_counter == 5) begin
                            buffer_counter <= 0;
                            word_out_valid <= 1'b1;

                            for (i = 0; i < 5; i = i + 1) begin
                                word_out[i * 64 +: 64] <= update_buffer[i];
                            end
                            word_out[5 * 64 +: 64] <= filter_word_out[0];
                            word_out[6 * 64 +: 64] <= filter_word_out[1];
                            word_out[7 * 64 +: 64] <= filter_word_out[2];

                            total_counter <= total_counter + 8;
                        end
                        else if (buffer_counter == 6) begin
                            buffer_counter <= 1;
                            word_out_valid <= 1'b1;

                            for (i = 0; i < 6; i = i + 1) begin
                                word_out[i * 64 +: 64] <= update_buffer[i];
                            end
                            word_out[6 * 64 +: 64] <= filter_word_out[0];
                            word_out[7 * 64 +: 64] <= filter_word_out[1];
                            update_buffer[0] <= filter_word_out[2];

                            total_counter <= total_counter + 8;
                        end
                        else begin /* buffer_counter == 7 */
                            buffer_counter <= 2;
                            word_out_valid <= 1'b1;

                            for (i = 0; i < 7; i = i + 1) begin
                                word_out[i * 64 +: 64] <= update_buffer[i];
                            end
                            word_out[7 * 64 +: 64] <= filter_word_out[0];
                            update_buffer[0] <= filter_word_out[1];
                            update_buffer[1] <= filter_word_out[2];

                            total_counter <= total_counter + 8;
                        end
                    end
                    4'b1111: begin
                        if (buffer_counter < 4) begin
                            buffer_counter <= buffer_counter + 4;
                            for (i = 0; i < 4; i = i + 1) begin
                                update_buffer[buffer_counter + i] <= filter_word_out[i];
                            end
                            word_out_valid <= 1'b0;
                        end
                        else if (buffer_counter == 4) begin
                            buffer_counter <= 0;
                            word_out_valid <= 1'b1;

                            for (i = 0; i < 4; i = i + 1) begin
                                word_out[i * 64 +: 64] <= update_buffer[i];
                            end
                            for (i = 0; i < 4; i = i + 1) begin
                                word_out[(4 + i) * 64 +: 64] <= filter_word_out[i];
                            end

                            total_counter <= total_counter + 8;
                        end
                        else if (buffer_counter == 5) begin
                            buffer_counter <= 1;
                            word_out_valid <= 1'b1;

                            for (i = 0; i < 5; i = i + 1) begin
                                word_out[i * 64 +: 64] <= update_buffer[i];
                            end
                            for (i = 0; i < 3; i = i + 1) begin
                                word_out[(5 + i) * 64 +: 64] <= filter_word_out[i];
                            end
                            update_buffer[0] <= filter_word_out[3];

                            total_counter <= total_counter + 8;
                        end
                        else if (buffer_counter == 6) begin
                            buffer_counter <= 2;
                            word_out_valid <= 1'b1;

                            for (i = 0; i < 6; i = i + 1) begin
                                word_out[i * 64 +: 64] <= update_buffer[i];
                            end
                            for (i = 0; i < 2; i = i + 1) begin
                                word_out[(6 + i) * 64 +: 64] <= filter_word_out[i];
                            end
                            update_buffer[0] <= filter_word_out[2];
                            update_buffer[1] <= filter_word_out[3];

                            total_counter <= total_counter + 8;
                        end
                        else if (buffer_counter == 7) begin
                            buffer_counter <= 3;
                            word_out_valid <= 1'b1;

                            for (i = 0; i < 7; i = i + 1) begin
                                word_out[i * 64 +: 64] <= update_buffer[i];
                            end
                            word_out[7 * 64 +: 64] <= filter_word_out[0];
                            update_buffer[0] <= filter_word_out[1];
                            update_buffer[1] <= filter_word_out[2];
                            update_buffer[2] <= filter_word_out[3];

                            total_counter <= total_counter + 8;
                        end
                    end
                    default: begin
                        word_out_valid <= 1'b0;
                        $display("error: filter_word_out_valid=%b\n", filter_word_out_valid);
                        $finish;
                    end
                endcase
            end
        end
    end

endmodule
