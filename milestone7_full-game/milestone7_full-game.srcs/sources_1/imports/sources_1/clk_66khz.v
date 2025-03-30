`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Module Name: clk_66khz
// Project Name: joystick
// Target Devices: Nexys 4 DDR
// Description: generates 66 kHz clock signal from 100 MHz signal
// 
//////////////////////////////////////////////////////////////////////////////////


module clk_66khz(
    CLK,
    RST,
    CLKOUT
    );
    
    input CLK;
    input RST;
    output CLKOUT;
    
    reg CLKOUT = 1'b1;
    
    parameter count_end = 10'b1011101110; // 66 kHz frequency driver
    reg [9:0] count = 10'b0;
    
    always @(posedge CLK) begin
        if (RST == 1'b1) begin
            CLKOUT <= 1'b0;
            count <= 10'b0;
        end
        else begin
            if (count == count_end)begin
                CLKOUT <= ~CLKOUT;
                count <= 10'b0;
            end
            else begin
                count <= count + 1'b1;
            end
        end
    end
    
endmodule
