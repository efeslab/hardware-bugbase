# D8 - Failure-to-Reset - SHA512

sha512: https://github.com/efeslab/hardcloud/tree/e28ca96fdbb67904ef909fb04e026cf6dc724198/samples/sha512

This bug is found in the memory requestor of a SHA512 accelerator. The accelerator may keep asserting the valid signal of the memory request, causing a number of memory requests to be issued when the accelerator is being back-pressured, which violates the CCIP interface used by the FPGA platform.

More details about the bug can be found in the comments of the synthetic code below.

### Synthetic Code
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
    DO_IDLE:
      if (start) state <= DO_WORK;
    DO_WORK:
      if (finish) state <= DO_RESULT;
    DO_RESULT: 
      if (!almfull) state <= DO_IDLE;
    	// When the state machine enters DO_RESULT, it will not get out of it until the back-pressure signal,
      // `almfull`, is deasserted.
  endcase
end
 
always_ff @(posedge clk) begin
  if (reset) begin
    valid <= 0;
    data <= 0;
  end
  else begin
    case (state)
      DO_IDLE:
        valid <= 0;
      DO_WORK:
        if (result_valid) begin
          valid <= 1; data <= get_result();
        end;
      DO_RESULT:
        // If `almfull` is asserted exactly at the cycle when the state machine enters DO_RESULT, the `valid`
        // signal which is asserted during DO_WORK will not be cleared. As a result, multiple write requests
        // will be issued to the channel, causing a CCIP violation (i.e., the accelerator should not send out
        // more than 8 packets when being back-pressured).
        if (!almfull) begin
          valid <= 1;
          data <= get_result_summary();
        end
    endcase
  end
end
```
