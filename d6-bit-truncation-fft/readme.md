# D6 - Bit Truncation - FFT

Source: https://github.com/ZipCPU/dblclockfft/issues/5

This bug is caused by the loss of the sign bit of a signal. The problematic module takes a 27 bit signed integer as input and outputs a 11-bit signed integer. Part of the input would be truncated during computation. If the value of the most significant bit changes after truncation (i.e., `i_val[26] != o_val[10]`), the sign of the output would be different from the sign of the input, thus causing problems.

The following code snippet shows the problematic code, with all parameters replaced by concrete values.

### Code Snippet

```verilog
input	wire signed [26:0] i_val;
output reg signed [10:0] o_val;

wire	[26:0]	truncated_value, rounded_up;
wire			last_valid_bit, first_lost_bit;

assign	truncated_value=i_val[22:12];
assign	rounded_up=truncated_value + {10{1'b0}, 1'b1};
assign	last_valid_bit = i_val[12];
assign	first_lost_bit = i_val[11];

wire	[10:0]	other_lost_bits;
assign	other_lost_bits = i_val[10:0];

always @(posedge i_clk) begin
		if (!first_lost_bit) // Round down / truncate
				o_val <= truncated_value;
		else if (|other_lost_bits) // Round up to
				o_val <= rounded_up; // closest value
		else if (last_valid_bit) // Round up to
				o_val <= rounded_up; // nearest even
		else	// else round down to nearest even
				o_val <= truncated_value;
end
```

