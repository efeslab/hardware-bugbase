### Source
Verilog-axis(Verilog AXI Stream Components): https://github.com/alexforencich/verilog-axis/commit/9cca78bc7c082b1bff9dd4168fac4841dd47b03b

Bug type: Incomplete Conditions


TKEEP is the byte qualifier that indicates whether the content
of the associated byte of TDATA is processed as part of the data
stream.

When adapting signals with different lengths, the tlast signal should be considered carefully, so we need to count when is the last cycle for tranfering data.

This bug failed to consider the third case, only considering the first two.

The code here shows the correct version:
### Synthetic Code
```verilog
if (input_axis_tready & input_axis_tvalid) begin
    // word transfer in - store it in data register
    cycle_count_next = 0;

    // is this the last cycle?
    if (CYCLE_COUNT == 1) begin
        // Case 1: last cycle by counter value
        last_cycle = 1;
    end else if (input_axis_tkeep[CYCLE_KEEP_WIDTH-1:0] != {CYCLE_KEEP_WIDTH{1'b1}}) begin
        // Case 2: last cycle by tkeep fall in current cycle
        last_cycle = 1;
    end else if (input_axis_tkeep[(CYCLE_KEEP_WIDTH*2)-1:CYCLE_KEEP_WIDTH] == {CYCLE_KEEP_WIDTH{1'b0}}) begin
        // Case 3(missing): last cycle by tkeep fall at end of current cycle
        last_cycle = 1;
    end else begin
        last_cycle = 0;
    end
```