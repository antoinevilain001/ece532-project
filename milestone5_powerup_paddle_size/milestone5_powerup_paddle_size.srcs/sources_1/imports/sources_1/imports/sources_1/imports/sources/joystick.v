`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Module Name: joystick
// Project Name: joystick_test
// Target Devices: Nexys 4 DDR
// Description: read joystick input, data transfer at rate of 5 Hz
//              positional data displayed on seven segment display
//              LED0-1 illuminate when button pressed
//              Button BTND used to reset
//              joystick connects to JA pins 1-4
//              SPI mode 0 communication used
// 
//              adapted from https://www.instructables.com/How-to-Use-the-PmodJSTK-With-the-Basys3-FPGA/             
// 
//////////////////////////////////////////////////////////////////////////////////


module joystick(
    CLK,
    RST,
    MISO,
    chip_select,
    MOSI,
    SCLK,
    CALIBRATE,
    user_dir
    );
    
    // declare ports
    input CLK;              // 100 MHz onboard clock
    input RST;              // BTND
    input MISO;             // Port JA Pin 3
    output chip_select;     // Port JA Pin 1
    output MOSI;            // Port JA Pin 2
    output SCLK;            // Port JA Pin 4
    input CALIBRATE;        // BTNU
    output reg [1:0] user_dir;  // whether to go up or down
    
    wire chip_select;
    wire MOSI;
    wire SCLK;
    
    reg [7:0] send_data;
    wire transmit;
    wire [39:0] joystick_data;
    wire [9:0] position_x_data;
    wire [9:0] position_y_data;
    
    // initialize joystick interface
    joystick_interface JSTK_INT(
        .CLK(CLK),
        .RST(RST),
        .transmit(transmit),
        .data_in(send_data),
        .chip_select(chip_select),
        .MOSI(MOSI),
        .MISO(MISO),
        .SCLK(SCLK),
        .data_out(joystick_data)
    );
    
    // initialize 5 Hz clock for transmit signals
    clk_5hz CLK5(
        .CLK(CLK),
        .RST(RST),
        .CLKOUT(transmit)
    );
    
    assign position_y_data = {joystick_data[9:8], joystick_data[23:16]};
    assign position_x_data = {joystick_data[25:24], joystick_data[39:32]};
    
    // turn on LED on PMOD
    always @(posedge CLK) begin
        if (CALIBRATE == 1'b1) begin
            send_data <= 8'b10100100;
        end
        else begin
            send_data <= {8'b1000000, (user_dir != 0)}; // light up anytime the paddle is either up or down
        end
    end
    
    
    always @(posedge CLK) begin
        if (position_x_data < 360) begin // down boundary
            user_dir <= 2'b01;
        end else if (position_x_data > 700) begin // up boundary
            user_dir <= 2'b10;
        end else begin
            user_dir <= 2'b00;
        end
    end
    
endmodule
