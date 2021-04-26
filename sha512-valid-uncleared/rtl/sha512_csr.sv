// sha512_csr.sv

import ccip_if_pkg::*;
import sha512_pkg::*;

module sha512_csr
(
  input  logic           clk,
  input  logic           reset,
  input  t_if_ccip_c0_Rx rx_mmio_channel,
  output t_if_ccip_c2_Tx tx_mmio_channel,
  output t_hc_control    hc_control,
  output t_ccip_clAddr   hc_dsm_base,
  output t_hc_buffer     hc_buffer[HC_BUFFER_SIZE]
);

  // register map to HardCloud
  localparam HC_DEVICE_HEADER    = 16'h000; // 64b - RO  Constant: 0x1000010000000000.
  localparam HC_AFU_ID_LOW       = 16'h008; // 64b - RO  Constant: 0xC000C9660D824272.
  localparam HC_AFU_ID_HIGH      = 16'h010; // 64b - RO  Constant: 0x9AEFFE5F84570612.

  // =========================================================================
  //
  //   CSR (MMIO) handling.
  //
  // =========================================================================

  // The AFU ID is a unique ID for a given program.  Here we generated
  // one with the "uuidgen" program.
  logic [127:0] afu_id = 128'hC000C966_0D82_4272_9AEF_FE5F84570612;

  //
  // A valid AFU must implement a device feature list, starting at MMIO
  // address 0.  Every entry in the feature list begins with 5 64-bit
  // words: a device feature header, two AFU UUID words and two reserved
  // words.
  //

  // Is a CSR read request active this cycle?
  logic is_csr_read;
  assign is_csr_read = rx_mmio_channel.mmioRdValid;

  // The MMIO request header is overlayed on the normal c0 memory read
  // response data structure.  Cast the c0Rx header to an MMIO request
  // header.
  t_ccip_c0_ReqMmioHdr mmio_req_hdr;
  assign mmio_req_hdr = t_ccip_c0_ReqMmioHdr'(rx_mmio_channel.hdr);

  //
  // Implement the device feature list by responding to MMIO reads.
  //

  always_ff @(posedge clk)
  begin
    if (reset) begin
      tx_mmio_channel.mmioRdValid <= 1'b0;
    end
    else begin
      // Always respond with something for every read request
      tx_mmio_channel.mmioRdValid <= is_csr_read;

      // The unique transaction ID matches responses to requests
      tx_mmio_channel.hdr.tid <= mmio_req_hdr.tid;

      // Addresses are of 32-bit objects in MMIO space.  Addresses
      // of 64-bit objects are thus multiples of 2.
      case (mmio_req_hdr.address)
        HC_DEVICE_HEADER: // AFU DFH (device feature header)
          begin
              // Here we define a trivial feature list.  In this
              // example, our AFU is the only entry in this list.
              tx_mmio_channel.data <= t_ccip_mmioData'(0);
              // Feature type is AFU
              tx_mmio_channel.data[63:60] <= 4'h1;
              // End of list (last entry in list)
              tx_mmio_channel.data[40] <= 1'b1;
          end

        // AFU_ID_L
        (HC_AFU_ID_LOW >> 2): tx_mmio_channel.data <= afu_id[63:0];

        // AFU_ID_H
        (HC_AFU_ID_HIGH >> 2): tx_mmio_channel.data <= afu_id[127:64];

        // DFH_RSVD0
        6: tx_mmio_channel.data <= t_ccip_mmioData'(0);

        // DFH_RSVD1
        8: tx_mmio_channel.data <= t_ccip_mmioData'(0);

        default: tx_mmio_channel.data <= t_ccip_mmioData'(0);
      endcase
    end
  end

  //
  // CSR write handling.  Host software must tell the AFU the memory address
  // to which it should be writing.  The address is set by writing a CSR.
  //

  always_ff @(posedge clk) begin
    if (hc_dsm_sel(rx_mmio_channel)) begin
      hc_dsm_base <= t_ccip_clAddr'(rx_mmio_channel.data) >> 6;
      $display("[%0t], hc_dsm_base 0x%h, clAddr 0x%h", $time, hc_dsm_base, t_ccip_clAddr'(rx_mmio_channel.data)) /*verilator tag debug_display_2.2.1*/;
    end
  end

  always_ff @(posedge clk) begin
    if (hc_control_sel(rx_mmio_channel)) begin
      hc_control <= t_hc_control'(rx_mmio_channel.data[31:0]);
    end
  end

  always_ff @(posedge clk) begin
    logic [1:0] sel;

    sel = hc_buffer_sel(rx_mmio_channel);

    if (sel == 2'b01) begin
      hc_buffer[hc_buffer_which(rx_mmio_channel)].address <=
        t_ccip_clAddr'(rx_mmio_channel.data);
    end
    else if (sel == 2'b11) begin
      hc_buffer[hc_buffer_which(rx_mmio_channel)].size <=
        rx_mmio_channel.data[31:0];
    end

  end

endmodule : sha512_csr

