module example(
    clk, a_valid, b_valid, a, b, o1, o2);
  input clk, a_valid, b_valid, a, b;
  output o1, o2;
  wire clk, a_valid, b_valid, valid;
  wire [7:0] a, b;
  reg [7:0] o1, o2, tmp;
  assign valid  = a_valid & b_valid;
  always @(posedge clk) begin
    if (valid) begin
      o1 <= a + b; o2 <= tmp;
    end else begin
      o1 <= 0; o2 <= 0;
    end
  end
  always @(*) begin
    tmp = a - b;
  end
endmodule
