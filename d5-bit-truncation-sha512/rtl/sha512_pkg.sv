// sha512_pkg.sv

package sha512_pkg;
  import ccip_if_pkg::*;

  //
  // HardCloud definitions
  //

  parameter HC_DSM_BASE_LOW        = 16'h110; // 32b - RW  Lower 32-bits of DSM base address
  parameter HC_CONTROL             = 16'h118; // 32b - RW  Control to start n stop the test

  parameter HC_BUFFER_BASE_ADDRESS = 16'h120;
  parameter HC_BUFFER_SIZE         = 2;

  // HC_CONTROL actions
  parameter HC_CONTROL_ASSERT_RST   = 32'h0000;
  parameter HC_CONTROL_DEASSERT_RST = 32'h0001;
  parameter HC_CONTROL_START        = 32'h0003;
  parameter HC_CONTROL_STOP         = 32'h0007;

  typedef logic [31:0] t_hc_control;

  typedef struct packed {
    t_ccip_clAddr address;
    logic [31:0]  size;
  } t_hc_buffer;

  function logic hc_buffer_which(input t_if_ccip_c0_Rx rx_mmio_channel);
    t_ccip_c0_ReqMmioHdr mmio_req_hdr;

    mmio_req_hdr = t_ccip_c0_ReqMmioHdr'(rx_mmio_channel.hdr);

    return (mmio_req_hdr.address >> 2) - (HC_BUFFER_BASE_ADDRESS >> 4);
  endfunction : hc_buffer_which

  function logic [1:0] hc_buffer_sel(input t_if_ccip_c0_Rx rx_mmio_channel);
    logic is_write;
    logic has_sel;
    logic is_size_type;
    t_ccip_c0_ReqMmioHdr mmio_req_hdr;
    t_ccip_mmioAddr top_addr;

    is_write = rx_mmio_channel.mmioWrValid;
    mmio_req_hdr = t_ccip_c0_ReqMmioHdr'(rx_mmio_channel.hdr);
    top_addr = 16'h120 + 16'h10*HC_BUFFER_SIZE + 16'h8;

    has_sel = is_write &&
      (mmio_req_hdr.address >= HC_BUFFER_BASE_ADDRESS >> 2) &&
      (mmio_req_hdr.address <= top_addr >> 2);

    is_size_type = mmio_req_hdr.address[1];

    return {is_size_type, has_sel};
  endfunction : hc_buffer_sel

  function logic hc_control_sel(input t_if_ccip_c0_Rx rx_mmio_channel);
    logic is_write;
    t_ccip_c0_ReqMmioHdr mmio_req_hdr;

    is_write = rx_mmio_channel.mmioWrValid;
    mmio_req_hdr = t_ccip_c0_ReqMmioHdr'(rx_mmio_channel.hdr);

    return is_write && (mmio_req_hdr.address == HC_CONTROL >> 2);
  endfunction : hc_control_sel

  function logic hc_dsm_sel(input t_if_ccip_c0_Rx rx_mmio_channel);
    logic is_write;
    t_ccip_c0_ReqMmioHdr mmio_req_hdr;

    is_write = rx_mmio_channel.mmioWrValid;
    mmio_req_hdr = t_ccip_c0_ReqMmioHdr'(rx_mmio_channel.hdr);

    return is_write && (mmio_req_hdr.address == HC_DSM_BASE_LOW >> 2);
  endfunction : hc_dsm_sel

  //
  // request definitions
  //

  typedef struct packed {
    logic         dirty;
    logic [511:0] data;
  } t_block;

  typedef enum logic [2:0] {
    S_RD_IDLE,
    S_RD_FETCH,
    S_RD_WAIT_0,
    S_RD_WAIT_1,
    S_RD_FINISH
  } t_rd_state;

  typedef enum logic [2:0] {
    S_WR_IDLE,
    S_WR_DATA,
    S_WR_FINISH
  } t_wr_state;

endpackage : sha512_pkg

