`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Module Name: keyboard
// Project Name: keyboard_test
// Target Devices: Nexys 4 DDR
// Description: communicate to keyboard and output returned PS/2 scan codes
//              to the seven segment display (8 displays show most recent 4 bytes)
//////////////////////////////////////////////////////////////////////////////////


module keyboard(
    input CLK,
    input pclk,
    input pdata,
    input resetn,
    output [6:0] SEG,
    output [7:0] AN,
    output DP,
    output [15:0] LED
    );
    
    wire [31:0] scancode;
    reg [7:0] last_key;
    reg key_pressed; 
    
    reg clk_div = 1'b0;
    reg CLK25MHZ = 0;
    always @(posedge CLK) begin
        clk_div <= clk_div + 1'b1;
        if (clk_div == 1'b1) CLK25MHZ <= ~CLK25MHZ;
    end
    
    PS2_controller keyboard_ctrl(
        .clk(CLK25MHZ),
        .pclk(pclk),
        .pdata(pdata),
        .keyout(scancode[31:0])
    );
    
    seven_seg_disp seven_inst (
        .data(scancode),
        .clk(CLK),
        .SEG(SEG),
        .AN(AN),
        .dp(DP)
    );
    
    wire spacebar_released = (scancode[15:0] == 16'hF029);
    assign LED[0] = spacebar_released;
    
endmodule
