module filter(
    input logic clk,
    input logic rst,

    input logic last_input_in,
    input logic [3:0] word_in_valid,
    input logic [63:0] word_in [3:0],

    output logic last_input_out,
    output logic [3:0] word_out_valid,
    output logic [63:0] word_out [3:0]
);

    logic [63:0] s0 [3:0];
    logic [63:0] s1 [3:0];
    logic [63:0] s2 [3:0];
    logic [63:0] s3 [3:0];
    logic [3:0] v0;
    logic [3:0] v1;
    logic [3:0] v2;
    logic [3:0] v3;

    logic li0, li1, li2, li3;

    /* stage 0: input */
    always_comb
    begin
        s0[0] = word_in[0];
        s0[1] = word_in[1];
        s0[2] = word_in[2];
        s0[3] = word_in[3];
        v0[0] = word_in_valid[0];
        v0[1] = word_in_valid[1];
        v0[2] = word_in_valid[2];
        v0[3] = word_in_valid[3];
        li0 = last_input_in;
    end

    /* stage 1: compare w0:w1 and w2:w3 */
    always_ff @(posedge clk) begin
        if (rst) begin
            s1[0] <= 0;
            s1[1] <= 0;
            s1[2] <= 0;
            s1[3] <= 0;
            v1[0] <= 0;
            v1[1] <= 0;
            v1[2] <= 0;
            v1[3] <= 0;
            li1 <= 0;
        end
        else begin
            if (v0[1]) begin
                s1[0] <= s0[1];
                v1[0] <= v0[1];
                s1[1] <= s0[0];
                v1[1] <= v0[0];
            end
            else begin
                s1[0] <= s0[0];
                v1[0] <= v0[0];
                s1[1] <= s0[1];
                v1[1] <= v0[1];
            end

            if (v0[3]) begin
                s1[2] <= s0[3];
                v1[2] <= v0[3];
                s1[3] <= s0[2];
                v1[3] <= v0[2];
            end
            else begin
                s1[2] <= s0[2];
                v1[2] <= v0[2];
                s1[3] <= s0[3];
                v1[3] <= v0[3];
            end

            li1 <= li0;
        end
    end

    /* stage 2: compare w1:w2 */
    always_ff @(posedge clk) begin
        if (rst) begin
                s2[0] <= 0;
                s2[1] <= 0;
                s2[2] <= 0;
                s2[3] <= 0;
                v2[0] <= 0;
                v2[1] <= 0;
                v2[2] <= 0;
                v2[3] <= 0;
            li2 <= 0;
        end
        else begin
            if (v1[3]) begin
                s2[3] <= s1[0];
                v2[3] <= v1[0];
                s2[0] <= s1[3];
                v2[0] <= v1[3];
            end
            else begin
                s2[0] <= s1[0];
                v2[0] <= v1[0];
                s2[3] <= s1[3];
                v2[3] <= v1[3];
            end

            if (v1[2]) begin
                s2[1] <= s1[2];
                v2[1] <= v1[2];
                s2[2] <= s1[1];
                v2[2] <= v1[1];
            end
            else begin
                s2[1] <= s1[1];
                v2[1] <= v1[1];
                s2[2] <= s1[2];
                v2[2] <= v1[2];
            end

            li2 <= li1;
        end
    end

    /* stage 3: compare w0:w1 and w2:w3 */
    always_ff @(posedge clk) begin
        if (rst) begin
                s3[0] <= 0;
                s3[1] <= 0;
                s3[2] <= 0;
                s3[3] <= 0;
                v3[0] <= 0;
                v3[1] <= 0;
                v3[2] <= 0;
                v3[3] <= 0;
            li3 <= 0;
        end
        else begin
            if (v2[1]) begin
                s3[0] <= s2[1];
                v3[0] <= v2[1];
                s3[1] <= s2[0];
                v3[1] <= v2[0];
            end
            else begin
                s3[0] <= s2[0];
                v3[0] <= v2[0];
                s3[1] <= s2[1];
                v3[1] <= v2[1];
            end

            if (v2[3]) begin
                s3[2] <= s2[3];
                v3[2] <= v2[3];
                s3[3] <= s2[2];
                v3[3] <= v2[2];
            end
            else begin
                s3[2] <= s2[2];
                v3[2] <= v2[2];
                s3[3] <= s2[3];
                v3[3] <= v2[3];
            end

            li3 <= li2;
        end
    end

    /* output */
    always_comb
    begin
            word_out[0] = s3[0];
            word_out[1] = s3[1];
            word_out[2] = s3[2];
            word_out[3] = s3[3];
            word_out_valid[0] = v3[0];
            word_out_valid[1] = v3[1];
            word_out_valid[2] = v3[2];
            word_out_valid[3] = v3[3];
        last_input_out = li3;
    end

endmodule
