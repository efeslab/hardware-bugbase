### Source
sha512: https://github.com/efeslab/hardcloud/tree/e28ca96fdbb67904ef909fb04e026cf6dc724198/samples/sha512

### Simplifed Code
#### Bug 1: Valid Signal Uncleared
``` verilog
typedef enum {
  DO_IDLE,
  DO_WORK,
  DO_RESULT
 } state_t;
state_t state;
 
initial state = DO_IDLE;
always_ff @(posedge clk) begin
  case (state)
    DO_IDLE: if (start) state <= DO_WORK;
    DO_WORK: if (finish) state <= DO_RESULT;
    DO_RESULT: state <= DO_IDLE;
  endcase
end
 
always_ff @(posedge clk) begin
  if (reset) begin
    valid <= 0;
    data <= 0;
  end
  else begin
    case (state)
      DO_WORK:
        if (result_valid) begin
          valid <= 1; data <= get_result();
        end;
      DO_RESULT:
        valid <= 1;
        data <= get_result_summary();
        // The valid bit will still be 1 in the next cycle, because DO_IDLE does not clear it.
    endcase
  end
end
```
 
#### Bug 2: Assign 64bit to 42bit
``` verilog
logic [41:0] left;
logic [63:0] right;
assign left = 42'(right) >> 6;
```
