### Source
BBB: https://github.com/efeslab/optimus-intel-fpga-bbb

SSSP: https://github.com/efeslab/optimus-intel-fpga-bbb/tree/master/samples/tutorial/vai_sssp

### Simplified Code
``` verilog
module test (
    input logic clk,
    input logic valid
);

    typedef enum {
        DO_VERTEX,
        DO_EDGE
    } state_t;
    state_t state;
    initial state = DO_VERTEX;

    logic [15:0] count;
    initial count = 0;

    always_ff @(posedge clk) begin
        count <= count + 1;
    end

    always_ff @(posedge clk) begin
        if (count == 2) begin
            state <= DO_EDGE;
        end
    end

    always_ff @(posedge clk) begin
        // The following code may "do vertex" three times, if the second and third 'valid' come in adjacent cycles.
        if (valid) begin
            case (state)
                DO_VERTEX: $display("do vertex!");
                DO_EDGE: $display("do edge!");
            endcase
        end
    end
endmodule
```
