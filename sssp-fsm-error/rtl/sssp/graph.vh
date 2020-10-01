`ifndef GRAPH_VH
`define GRAPH_VH

`include "cci_mpf_if.vh"

typedef struct packed {
    logic [31:0] weight;
    logic [15:0] level;
    logic winf;
} vertex_t;

function logic [63:0] vertex_to_int64(
    input vertex_t vertex
);
    logic [63:0] int64;
    int64[31:0] = vertex.weight;
    int64[47:32] = vertex.level;
    int64[48] = vertex.winf;
    int64[63:49] = 15'h0;
    return int64;
endfunction

function vertex_t int64_to_vertex(
    input logic [63:0] int64
);
    vertex_t vertex;
    vertex.weight = int64[31:0];
    vertex.level = int64[47:32];
    vertex.winf = int64[48];
    return vertex;
endfunction

typedef struct packed {
    logic [31:0] src;
    logic [31:0] dst;
    logic [31:0] weight;
    logic [31:0] rsvd;
} edge_t;

function logic [127:0] edge_to_int128(
    input edge_t e
);
    logic [127:0] int128;
    int128[31:0] = e.src;
    int128[63:32] = e.dst;
    int128[95:64] = e.weight;
    int128[127:96] = e.rsvd;
    return int128;
endfunction

function edge_t int128_to_edge(
    input logic [127:0] int128
);
    edge_t e;
    e.src = int128[31:0];
    e.dst = int128[63:32];
    e.weight = int128[95:64];
    e.rsvd = int128[127:96];
    return e;
endfunction

typedef struct packed {
    logic [31:0] vertex;
    logic [31:0] weight;
} update_t;

typedef struct packed {
    t_ccip_clAddr status_addr;
    t_ccip_clAddr update_bin_addr;
    t_ccip_clAddr next_desc_addr;
    t_ccip_clAddr vertex_addr;
    t_ccip_clAddr edge_addr;

    logic [31:0] vertex_ncl;
    logic [31:0] vertex_idx;
    logic [31:0] edge_ncl;
    logic [15:0] level;

    logic [63:0] seq_id;
} desc_t;

function desc_t int512_to_desc(
    input logic [511:0] int512
);
    desc_t desc;
    desc.status_addr = t_ccip_clAddr'(int512[63:0]);
    desc.update_bin_addr = t_ccip_clAddr'(int512[127:64]);
    desc.vertex_addr = t_ccip_clAddr'(int512[191:128]);
    desc.vertex_ncl = int512[223:192];
    desc.vertex_idx = int512[255:224];
    desc.edge_addr = t_ccip_clAddr'(int512[319:256]);
    desc.edge_ncl = int512[351:320];
    desc.level = int512[367:352];
    desc.seq_id = int512[447:384];
    desc.next_desc_addr = t_ccip_clAddr'(int512[511:448]);
    return desc;
endfunction

`endif
