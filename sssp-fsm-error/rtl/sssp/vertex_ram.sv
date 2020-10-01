`include "graph.vh"

module vertex_bank #(
    parameter ADDR_W = 5)
(
    input clk,
    input vertex_t vertex_in,
    input logic [ADDR_W-1:0] w_addr,
    input logic [ADDR_W-1:0] r_addr,
    input we_in,
    output vertex_t vertex_out
);

    localparam DEPTH = (2**ADDR_W);
    vertex_t ram [DEPTH-1:0]  /* synthesis ramstyle = "no_rw_check" */;

    always_ff @(posedge clk)
    begin
        vertex_out <= ram[r_addr];
        if (we_in) begin
            ram[w_addr] <= vertex_in;
        end
    end

endmodule

/* input as cachelines, output as vertex_t */
module vertex_ram #(
    parameter ADDR_W = 8)
(
    input clk,
    input logic [511:0] cl_in,
    input logic [ADDR_W-1:0] w_addr, /* the addr of the first vertex in the cacheline */
    input logic [ADDR_W-1:0] r_addr, /* the addr of the exact vertex */
    input logic we_in,
    output vertex_t vertex_out
);

    logic [2:0] r_addr_buff;

    vertex_t bank [7:0];

    genvar i;
    generate
        for (i = 0; i < 8; i++)
        begin: banks
            vertex_t v;
            assign v = int64_to_vertex(cl_in[i * 64 + 49: i * 64]);

            vertex_bank #(.ADDR_W(ADDR_W-3))
            banks(
                .clk(clk),
                .vertex_in(v),
                .r_addr(r_addr[ADDR_W-1:3]),
                .w_addr(w_addr[ADDR_W-1:3]),
                .we_in(we_in),
                .vertex_out(bank[i])
                );
        end
    endgenerate

    always_ff @(posedge clk)
    begin
        vertex_out <= bank[r_addr_buff];
        r_addr_buff <= r_addr[2:0];
    end

endmodule
