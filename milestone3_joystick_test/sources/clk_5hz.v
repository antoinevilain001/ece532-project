`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Module Name: clk_5hz
// Project Name: joystick
// Target Devices: Nexys 4 DDR
// Description: converts on board 100 MHz signal to 5 Hz clock signal
// 

//////////////////////////////////////////////////////////////////////////////////


module clk_5hz(
    CLK,
    RST,
    CLKOUT
    );
    
    input CLK;
    input RST;
    output CLKOUT;
    
    reg CLKOUT;
    reg [23:0] clk_count = 24'h000000;
    // 100 MHz to 5 Hz, count to 10M cycles so clock period 20 M cycles
    parameter count_end = 24'h989680;
    
    always @(posedge CLK) begin
        if (RST == 1'b1) begin
            CLKOUT <= 1'b0;
            clk_count <= 24'h000000;
        end
        else begin
            if (clk_count == count_end) begin
                CLKOUT <= ~CLKOUT;
                clk_count <= 24'h000000;
            end
            else begin
                clk_count <= clk_count + 1'b1;
            end
        end
    end
    
endmodule
