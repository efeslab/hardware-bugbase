`include "graph.vh"

module sssp_pipeline #(
    parameter ADDR_W = 8, pipeline_id = 0
)
(
    input logic clk,
    input logic rst,
	input logic last_input_in,
    input logic [511:0] word_in,
    input logic [31:0] w_addr,
    input logic word_in_valid,
    input logic [1:0] control,
    input logic [15:0] current_level,
    output logic [1:0] control_out,
    output logic last_input_out,
	output logic [63:0] word_out,
    output logic valid_out,
	output logic word_in_valid_out
);

    vertex_t vertex_out;

    reg	last_input_q;
    reg	last_input_qq;
    reg	last_input_qqq;

    logic [1:0] control_q;
    logic [1:0] control_qq;
    logic [1:0] control_qqq;

    logic word_in_valid_q;
    logic word_in_valid_qq;
    logic word_in_valid_qqq;

    edge_t target_edge;
    edge_t target_edge_q;
    edge_t target_edge_qq;
    assign target_edge = int128_to_edge(word_in[pipeline_id*128+127:pipeline_id*128]);

    logic [23:0] w_addr_prefix;
    always_ff @(posedge clk)
    begin
        /* if control is 1, which means the afu is importing vertices,
         * we remember the prefix of the addresses. Since the address
         * is always 256 aligned, the prefix should be the same for all
         * imported edges. */
        if (control == 2'h1 & word_in_valid) begin
            w_addr_prefix <= w_addr[31:ADDR_W];
        end
    end

    logic should_update;
    logic prefix_match;
    logic level_match;
    logic edge_valid;
    logic [63:0] word_out_prepare;

    vertex_ram #(.ADDR_W(ADDR_W))
    bram0(
        .clk(clk),
        .cl_in(word_in),
        .w_addr(w_addr[ADDR_W-1:0]),
        .r_addr(target_edge.src[ADDR_W-1:0]),
        .we_in((control == 2'h1) & (word_in_valid)),
        .vertex_out(vertex_out)
        );

    always_ff @(posedge clk)
    begin
        if (rst) begin
            word_out <= 64'h0;
            valid_out <= 1'b0;

            control_out <= 2'h0;
            control_q <= 2'h0;
            control_qq <= 2'h0;
            control_qqq <= 2'h0;

            last_input_out <= 1'b0;
            last_input_q <= 1'b0;
            last_input_qq <= 1'b0;
            last_input_qqq <= 1'b0;

			word_in_valid_out <= 1'b0;
			word_in_valid_q <= 1'b0;  
			word_in_valid_qq <= 1'b0; 
            word_in_valid_qqq <= 1'b0;

            target_edge_q <= edge_t'(0);
            target_edge_qq <= edge_t'(0);

            should_update <= 0;
            prefix_match <= 0;
            level_match <= 0;
            edge_valid <= 0;
        end
        else begin

            /* The block ram needs two cycles to get the value out,
             * and we add an additional cycle. */
            control_out <= control_qqq;
            control_qqq <= control_qq;
            control_qq <= control_q;
            control_q <= control;

			last_input_out <= last_input_qqq;
			last_input_qqq <= last_input_qq;
			last_input_qq <= last_input_q;
            last_input_q <= last_input_in;

			word_in_valid_out <= word_in_valid_qqq;
			word_in_valid_qqq <= word_in_valid_qq;
			word_in_valid_qq <= word_in_valid_q;
			word_in_valid_q <= word_in_valid;

            target_edge_qq <= target_edge_q;
            target_edge_q <= target_edge;

			word_out <= 64'h0; 
			valid_out <= 1'b0;

            /* We add an additional stage here to satisfy the timing
             * requirement easier. */
            should_update <= (word_in_valid_qq) & (control_qq == 2'h2);
            /* We need to check the prefix since the address only
             * contains the last 8 bits. */
            prefix_match <= (w_addr_prefix == target_edge_qq.src[31:ADDR_W]);
            level_match <= (vertex_out.level == current_level);
            /* Currently we just check whether src == dst, however, we
             * should have a bit to indicate whether an edge is valid. */
            edge_valid <= (target_edge_qq.src != target_edge_qq.dst);
            word_out_prepare <=
                {target_edge_qq.weight + vertex_out.weight, target_edge_qq.dst};

            if (should_update & level_match & prefix_match & edge_valid) begin
                word_out <= word_out_prepare;
                valid_out <= 1'b1;
            end
        end
    end

endmodule
