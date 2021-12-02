# C1 - Dead Lock - SDSPI

Source: https://github.com/ZipCPU/sdspi/issues/2

Code: https://github.com/ZipCPU/sdspi/commit/53e9a2bf66b8185e3f856a21f1d7c2d672f0da2b

This bug is reported in GitHub issue of the SDSPI project, an SD card controller. It is caused by some circular dependencies during the booting of the circuit. These signals are initialized to a state that would not be tranferred out, which will be explained in the comments of the following synthetic code.

The circular dependency (i.e., dead lock) prevents the clock signal of the SD card being generated. As a result, no data can be accessed to in the SD card.

### Synthetic Code
```verilog
module test(
        input logic clk,
        output logic o_sclk,

        input logic i_speed // i_speed != 0
);

        logic startup_hold;
        initial startup_hold = 1;

        logic [6:0] r_clk_counter;
        logic r_z_counter;
        initial r_clk_counter = 0;
        initial r_z_counter = 1;

        always_ff @(posedge clk) begin
                // During the startup of the circuit, startup_hold is always true. As a result, this block always falls into
                // the first if-statement, which prevents r_z_counter from being updated, which prevents o_sclk to be updated,
          			// which prevents startup_hold to be updated.
                if (startup_hold) begin
                        r_clk_counter <= i_speed;
                        r_z_counter <= (i_speed == 0);
                end
                else if (!r_z_counter) begin
                        r_clk_counter <= (r_clk_counter - 1);
                        r_z_counter <= (r_clk_counter == 1);
                end
                else begin
                        r_clk_counter <= i_speed;
                        r_z_counter <= 0;
                end
        end

        initial o_sclk = 1;
        always_ff @(posedge clk) begin
                if (r_z_counter)
                        o_sclk <= !o_sclk;
        end

        logic [7:0] startup_counter;
        initial startup_counter = 64;
        always_ff @(posedge clk) begin
                if (startup_hold && !past_sclk && o_sclk) begin
                        if (|startup_counter)
                                startup_counter <= startup_counter - 1;
                        startup_hold <= (startup_counter > 0);
                end
        end
end
```
