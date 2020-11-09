module fadd #(parameter N = 32, parameter E = 8, parameter S = 1) (
    // Inputs
    input logic         clk,
    input logic         rst,
    input logic         en,
    input logic [N-1:0] op1,
    input logic [N-1:0] op2,

    // Outputs
    output logic         res_val_correct,
    output logic [N-1:0] res_correct,
    output logic         res_val_buggy,
    output logic [N-1:0] res_buggy
);

    fadd_buggy buggy(
        .clk(clk),
        .rst(rst),
        .en(en),
        .op1(op1),
        .op2(op2),
        .res_val(res_val_buggy),
        .res(res_buggy)
    );

    fadd_correct correct(
        .clk(clk),
        .rst(rst),
        .en(en),
        .op1(op1),
        .op2(op2),
        .res_val(res_val_correct),
        .res(res_correct)
    );

endmodule
