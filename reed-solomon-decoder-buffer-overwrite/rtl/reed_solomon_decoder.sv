// reed_solomon_decoder.sv

module reed_solomon_decoder
(
  input  logic       clk,
  input  logic       reset,
  input  logic [7:0] data_in,
  input  logic       valid_in,
  output logic [7:0] data_out,
  output logic       valid_out
);

  RS_dec  uu_rs_dec
  (
    .clk        (clk),
    .reset      (reset),
    .input_byte (data_in),
    .CE         (valid_in),
    .Out_byte   (data_out),
    .CEO        (valid_out),
    .Valid_out  ()
  );

endmodule : reed_solomon_decoder

