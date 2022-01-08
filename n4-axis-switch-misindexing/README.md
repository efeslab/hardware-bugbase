# D8 - Misindexing - AXI Stream Switch

**Source:** Verilog-axis(Verilog AXI Stream Components): https://github.com/alexforencich/verilog-axis/commit/76c805e4167c1065db0a7cdec711b30c1e11da91#diff-09b0ecbe0779c53e7a28b0d57be6ca8bd2f6224a339902399abed42ee0338d57

Bug type: Miss-indexing


### Synthetic Code
```verilog
// Line 228
assign int_s_axis_tready[m] = int_axis_tready[select_reg*M_COUNT+m] || drop_reg; //M_COUNT should be S_COUNT

// Line 296
wire s_axis_tvalid_mux = int_axis_tvalid[grant_encoded*S_COUNT+n] && grant_valid; //S_COUNT should be M_COUNT

```
