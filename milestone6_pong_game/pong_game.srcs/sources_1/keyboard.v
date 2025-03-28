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
    output spacebar_pressed,
    output r_pressed
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
    
    
    reg spacebar_state;
    always @(posedge CLK) begin
        if (scancode[7:0] == 8'hF0) begin
            // Next byte is the break code identifier, wait for next byte
            spacebar_state <= spacebar_state;  // Hold state
        end else if (scancode[15:0] == 16'hF029) begin // spacebar released
            spacebar_state <= 0;
        end else if (scancode[7:0] == 8'h29) begin
            // Spacebar press detected
            spacebar_state <= 1;
        end
    end
    
    assign spacebar_pressed = spacebar_state; // assign to output
    
    
    reg r_state;
    always @(posedge CLK) begin
        if (scancode[7:0] == 8'hF0) begin
            // Next byte is the break code identifier, wait for next byte
            r_state <= r_state;  // Hold state
        end else if (scancode[15:0] == 16'hF02d) begin // spacebar released
            r_state <= 0;
        end else if (scancode[7:0] == 8'h2d) begin
            // Spacebar press detected
            r_state <= 1;
        end
    end
    
    assign r_pressed = r_state; // assign to output
    
    
endmodule
