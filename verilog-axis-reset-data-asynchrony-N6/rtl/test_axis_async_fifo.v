/*

Copyright (c) 2014 Alex Forencich

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.

*/

// Language: Verilog 2001

`timescale 1ns / 1ps

module test_axis_async_fifo(input clk, output reg genclock);

// Inputs
reg [31:0] cycle = 0;
reg async_rst = 0;
reg input_clk = 0;
reg output_clk = 0;
reg [7:0] current_test = 0;

reg [7:0] input_axis_tdata = 0;
reg input_axis_tvalid = 0;
reg input_axis_tlast = 0;
reg input_axis_tuser = 0;
reg output_axis_tready = 0;

// Outputs
wire input_axis_tready;
wire [7:0] output_axis_tdata;
wire output_axis_tvalid;
wire output_axis_tlast;
wire output_axis_tuser;

assign input_clk = clk;
assign output_clk = clk;

initial begin

    async_rst = 1'b1;
    input_axis_tdata = 0;
    input_axis_tvalid = 0;
    input_axis_tlast = 0;
    input_axis_tuser = 0;
    output_axis_tready = 0;
end



always @(posedge clk) begin
        genclock <= cycle < 12;
        cycle <= cycle + 1;

        if(cycle == 0) begin
            input_axis_tdata <= 8'h0;
            input_axis_tvalid <= 1'b0;
            input_axis_tlast <= 0;
            input_axis_tuser <= 0;
            output_axis_tready <= 1'b1;
        end
        else if (cycle == 1) begin
            input_axis_tdata <= 8'h0;
        end
        else if(cycle == 2) begin
            input_axis_tdata <= 8'h1;
            input_axis_tvalid <= 1'b1;
            input_axis_tlast <= 1'b0;
        end
        else if(cycle == 3) begin
            input_axis_tdata <= 8'h2;
        end
        else if(cycle == 4) begin
            input_axis_tdata <= 8'h3;
        end
        else if (cycle == 5) begin
            input_axis_tdata <= 8'h4;
        end
        else if (cycle == 6) begin
            input_axis_tdata <= 8'h5;
        end
        else if(cycle == 7) begin
            input_axis_tdata <= 8'h6;
        end
        else if(cycle == 8) begin
            input_axis_tdata <= 8'h7;
            input_axis_tlast <= 1'b1;
        end
        else if(cycle == 9) begin
            input_axis_tdata <= 8'h8;
        end
        else if (cycle == 10) begin
            
        end
        else if (cycle == 12) begin
            $finish;
        end
    end

always @(negedge clk) begin
    if(cycle == 0) begin
        async_rst <= 1'b0;
    end
    else if (cycle == 4) begin
        async_rst <= 1'b1;
    end
    else if (cycle == 6) begin
        async_rst <= 1'b0;
    end
end

always @(*) begin
    if(cycle==5 && input_axis_tvalid && input_axis_tready && async_rst) begin
        //input must be stalled, otherwise data 03-06 will lost
        $display("@@@Error: Accept data when reseting!\n Input must be stalled, otherwise data 03-06 will lost");
        $finish;
    end
end

axis_async_fifo #(
    .ADDR_WIDTH(2),
    .DATA_WIDTH(8)
)
UUT (
    // Common reset
    .async_rst(async_rst),
    // AXI input
    .input_clk(input_clk),
    .input_axis_tdata(input_axis_tdata),
    .input_axis_tvalid(input_axis_tvalid),
    .input_axis_tready(input_axis_tready),
    .input_axis_tlast(input_axis_tlast),
    .input_axis_tuser(input_axis_tuser),
    // AXI output
    .output_clk(output_clk),
    .output_axis_tdata(output_axis_tdata),
    .output_axis_tvalid(output_axis_tvalid),
    .output_axis_tready(output_axis_tready),
    .output_axis_tlast(output_axis_tlast),
    .output_axis_tuser(output_axis_tuser)
);

endmodule
