`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Module Name: PS2_controller
// Project Name: keyboard_test
// Target Devices: Nexys 4 DDR 
// Description: communicate with device (keyboard in PS2 interface
//////////////////////////////////////////////////////////////////////////////////


module PS2_controller(
    input clk,
    input pclk,
    input pdata,
    output [31:0] keyout
    );
    
    reg [7:0] data;
    reg [7:0] prev_data;
    reg [3:0] count;
    reg [31:0] key;
    reg flag;
    
    initial begin
        key[31:0] <= 32'h88888888;
        count <= 4'h0;
    end
    
    always @(negedge pclk) begin
        case (count)
            0:; 
            1: data[0] <= pdata;
            2: data[1] <= pdata;
            3: data[2] <= pdata;
            4: data[3] <= pdata;
            5: data[4] <= pdata;
            6: data[5] <= pdata;
            7: data[6] <= pdata;
            8: data[7] <= pdata;
            9: flag <= 1'b1;
            10: flag <= 1'b0;
        endcase
        if (count <= 9) count <= count + 1'b1;
        else if (count == 10) count <= 0;
    end
    
    always @(posedge flag) begin
        if (prev_data != data) begin
            key[31:24] <= key[23:16];
            key[23:16] <= key[15:8];
            key[15:8] <= key[7:0];
            key[7:0] <= data;
            prev_data <= data;
        end
    end
    
    assign keyout = key;
    
endmodule
