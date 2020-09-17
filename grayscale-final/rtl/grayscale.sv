// grayscale.sv

module grayscale
(
  input  logic         clk,
  input  logic         reset,
  input  logic [511:0] data_in,
  input  logic         valid_in,
  output logic [511:0] data_out,
  output logic         valid_out
);

  function [31:0] rgb2luma(input logic [31:0] data);
    logic [7:0] tmp;

    tmp  = data[7:0]   >> 2;
    tmp += data[7:0]   >> 5;
    tmp += data[15:8]  >> 1;
    tmp += data[15:8]  >> 4;
    tmp += data[23:16] >> 4;
    tmp += data[23:16] >> 5;

    return {tmp, tmp, tmp};
  endfunction : rgb2luma

  always_ff@(posedge clk or posedge reset) begin
    if (reset) begin
      valid_out <= 1'b0;
    end
    else begin
      valid_out <= valid_in;
    end
  end

  always_ff@(posedge clk or posedge reset) begin
    if (reset) begin
      data_out <= '0;
    end
    else begin
      for (int i = 0; i < 16; i++) begin
        data_out[32*i +: 32] <= rgb2luma(data_in[32*i +: 32]);
      end
    end
  end

endmodule : grayscale

