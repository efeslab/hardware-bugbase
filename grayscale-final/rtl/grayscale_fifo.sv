// grayscale_fifo.sv

import grayscale_pkg::*;

module grayscale_fifo
#(
  parameter SOBEL_FIFO_DEPTH = 16
)
(
  input  logic clk,
  input  logic reset,

  input  logic [511:0] enq_data,
  input  logic         enq_en,
  output logic         not_full,

  output logic [511:0] deq_data,
  input  logic         deq_en,
  output logic         not_empty,

  output logic [7:0] counter,
  output logic [7:0] dec_counter
);

  logic [$clog2(SOBEL_FIFO_DEPTH) - 1:0] wr_pointer;
  logic [$clog2(SOBEL_FIFO_DEPTH) - 1:0] rd_pointer;

  t_block mem[SOBEL_FIFO_DEPTH];

  assign not_full  = (counter == (SOBEL_FIFO_DEPTH - 1)) ? 1'b0 : 1'b1;
  assign not_empty = (counter == '0) ? 1'b0 : 1'b1;

  assign deq_data  = mem[rd_pointer];

  assign dec_counter = SOBEL_FIFO_DEPTH - counter;

  always_ff@(posedge clk or posedge reset) begin
    if (reset) begin
      wr_pointer <= '0;
    end
    else begin
      if (enq_en && not_full) begin
        wr_pointer <= wr_pointer + 1;
      end
    end
  end

  always_ff@(posedge clk or posedge reset) begin
    if (reset) begin
      rd_pointer <= '0;
    end
    else begin
      if (deq_en && not_empty) begin
        rd_pointer <= rd_pointer + 1;
      end
    end
  end

  always_ff@(posedge clk or posedge reset) begin
    if (reset) begin
      counter <= '0;
    end
    else begin
      if (enq_en && !deq_en && not_full) begin
        counter <= counter + 1;
      end
      else if (!enq_en && deq_en && not_empty) begin
        counter <= counter - 1;
      end
    end
  end

  always_ff@(posedge clk or posedge reset) begin
    if (reset) begin
      for (int i = 0; i < SOBEL_FIFO_DEPTH; i++) begin
        mem[i] <= '0;
      end
    end
    else begin
      if (enq_en && not_full) begin
        mem[wr_pointer] <= enq_data;
      end
    end
  end

endmodule : grayscale_fifo

