### Source
Verilog-axis(Verilog AXI Stream Components): https://github.com/alexforencich/verilog-axis/commit/0b2066abe3d8983a120cb8afe598c2710f2e5be6

Bug type: Fail to reset (signal frame_len_reg)

### Synthetic Code
```verilog
module axis_frame_len #
(
    // Width of AXI stream interfaces in bits
    parameter DATA_WIDTH = 64,
    // Propagate tkeep signal
    // If disabled, tkeep assumed to be 1'b1
    parameter KEEP_ENABLE = (DATA_WIDTH>8),
    // tkeep signal width (words per cycle)
    parameter KEEP_WIDTH = (DATA_WIDTH/8),
    // Width of length counter
    parameter LEN_WIDTH = 16
)
(
    input  wire                   clk,
    input  wire                   rst,

    /*
     * AXI monitor
     */
    input  wire [KEEP_WIDTH-1:0]  monitor_axis_tkeep,
    input  wire                   monitor_axis_tvalid,
    input  wire                   monitor_axis_tready,
    input  wire                   monitor_axis_tlast,

    /*
     * Status
     */
    output wire [LEN_WIDTH-1:0]   frame_len,
    output wire                   frame_len_valid
);

reg [LEN_WIDTH-1:0] frame_len_reg = 0, frame_len_next;
reg frame_len_valid_reg = 1'b0, frame_len_valid_next;
reg frame_reg = 1'b0, frame_next;

assign frame_len = frame_len_reg;
assign frame_len_valid = frame_len_valid_reg;

integer offset, i, bit_cnt;

always @* begin
    frame_len_next = frame_len_reg;
    frame_len_valid_next = 1'b0;
    frame_next = frame_reg;

    if (monitor_axis_tready && monitor_axis_tvalid) begin
        // valid transfer cycle

        if (monitor_axis_tlast) begin
            // end of frame
            frame_len_valid_next = 1'b1;
            frame_next = 1'b0;
        end else if (!frame_reg) begin
        // The bug occurs when two back-to-back data transfer packets come (with tlast set on every transfer), then this "else if" block won't be accessed, and the frame_len_next can't be reset correctly.

            frame_len_next = 0;
            frame_next = 1'b1;
        end

        // increment frame length by number of words transferred
        if (KEEP_ENABLE) begin
            bit_cnt = 0;
            for (i = 0; i <= KEEP_WIDTH; i = i + 1) begin
                if (monitor_axis_tkeep == ({KEEP_WIDTH{1'b1}}) >> (KEEP_WIDTH-i)) bit_cnt = i;
            end
            frame_len_next = frame_len_next + bit_cnt;
        end else begin
            frame_len_next = frame_len_next + 1;
        end
    end
end

always @(posedge clk) begin
    if (rst) begin
        frame_len_reg <= 0;
        frame_len_valid_reg <= 0;
        frame_reg <= 1'b0;
    end else begin
        frame_len_reg <= frame_len_next;
        frame_len_valid_reg <= frame_len_valid_next;
        frame_reg <= frame_next;
    end
end

endmodule
```
