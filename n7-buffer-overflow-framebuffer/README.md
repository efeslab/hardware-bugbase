# D6 - Misindexing - FADD

A PhD student at University of Michigan reports this bug in one of his hardware project.

This bug is in a simple floating point adder that's optimized for resource. The author uses the wrong index range to access the fraction, which causes the least significant bit of the exponent being treated as the most significant bit of the fraction, thus making the adder producing wrong results.

The following code snippet shows the errorous code and the correct one.

### Code Snippet

```verilog
// errorous code
for(int i = 0; i < N-E; ++i) begin
  if(tmp_mant[N-E-i]) begin
    // Check for underflow
    if(i > tmp_exp) begin
      res_exp_next = 1;
    end else begin
      res_exp_next = tmp_exp - i;
      res_mant_next = tmp_mant[N-E-S:0] << i;
    end

    break;
  end
end

// correct code
for(int i = 0; i < N-E-1; ++i) begin
  if(tmp_mant[N-E-1-i]) begin
    // Check for underflow
    if(i > tmp_exp) begin
      res_exp_next = 1;
    end else begin
      res_exp_next = tmp_exp - i;
      res_mant_next = tmp_mant[N-E-S-1:0] << i;
    end

    break;
  end
end
```

