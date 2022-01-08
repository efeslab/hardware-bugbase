// sha512.sv

import ccip_if_pkg::*;

module sha512
(
  input  logic         clk,
  input  logic         reset,
  input  logic [511:0] block,
  input  logic         block_valid,
  output logic [511:0] digest,
  output logic         digest_valid
);

  localparam MODE_SHA_512 = 3;

  logic          init;
  logic          next;
  logic          ptr;
  logic          ready;
  logic [1023:0] local_block;

  logic          first_time;

  sha512_core uu_sha512_core
  (
    .clk             (clk),
    .reset_n         (!reset),
    .init            (init),
    .next            (next),
    .mode            (MODE_SHA_512),
    .work_factor     (),
    .work_factor_num (),
    .block           (local_block),
    .ready           (ready),
    .digest          (digest),
    .digest_valid    (digest_valid)
  );

  always_ff@(posedge clk or posedge reset) begin
    if (reset) begin
      local_block[0] <= '0;
      local_block[1] <= '0;
    end
    else begin
      if (block_valid) begin
        local_block[ptr*512 +: 512] <= block;
      end
    end
  end

  int cnt;
  always_ff@(posedge clk or posedge reset) begin
    if (reset) begin
      ptr <= 0;
      cnt <= 0;
    end
    else begin
      if (block_valid) begin
        ptr <= !ptr;
        cnt <= cnt + 1;
      end
    end
  end

  always_ff@(posedge clk or posedge reset) begin
    if (reset) begin
      first_time <= 1'b1;
    end
    else begin
      if (block_valid && ptr == 1'b1) begin
        first_time <= 1'b0;
      end
    end
  end

  always_ff@(posedge clk or posedge reset) begin
    if (reset) begin
      init <= 1'b0;
    end
    else begin
      if (block_valid && first_time && ptr == 1'b1) begin
        init <= 1'b1;
      end
      else begin
        init <= 1'b0;
      end
    end
  end

  always_ff@(posedge clk or posedge reset) begin
    if (reset) begin
      next <= 1'b0;
    end
    else begin
      if (block_valid && !first_time && ptr == 1'b1) begin
        next <= 1'b1;
      end
      else begin
        next <= 1'b0;
      end
    end
  end

endmodule : sha512

