`timescale 1ns / 1ps
module clock_divider(
    input clk_in,        // 100 MHz clock
    output reg clk_out   // 25 MHz clock
);
    reg [1:0] count = 0;
    always @(posedge clk_in) begin
        count <= count + 1;
        clk_out <= (count == 0);
    end
endmodule
