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
    SW,
    chip_select,
    MOSI,
    SCLK,
    LED,
    AN,
    SEG,
    CALIBRATE
    //user_dir
    );
    
    // declare ports
    input CLK;              // 100 MHz onboard clock
    input RST;              // BTND
    input MISO;             // Port JA Pin 3
    input [1:0] SW;         // Switch 0 
    output chip_select;     // Port JA Pin 1
    output MOSI;            // Port JA Pin 2
    output SCLK;            // Port JA Pin 4
    output [11:0] LED;      // LED 12 to 0
    output [3:0] AN;        // Seven Segment Display Anode
    output [6:0] SEG;       // Seven Segment Display Cathode
    input CALIBRATE;        // BTNU
    //output reg [1:0] user_dir;  // binary whether to go up or down
    reg [1:0] user_dir;
    
    wire chip_select;
    wire MOSI;
    wire SCLK;
    reg [11:0] LED;
    wire [7:0] AN;
    wire [6:0] SEG;
    
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
    
    // take position data output to seven segment display
    seven_seg_disp SSD(
        .CLK(CLK),
        .RST(RST),
        .x_pos(position_x_data),
        .y_pos(position_y_data),
        .AN(AN),
        .SEG(SEG)
    );
    
    
    assign position_y_data = {joystick_data[9:8], joystick_data[23:16]};
    assign position_x_data = {joystick_data[25:24], joystick_data[39:32]};
    
    // turn on LED on PMOD
    always @(CALIBRATE) begin
        if (CALIBRATE == 1'b1) begin
            send_data <= 8'b10100100;
        end
        else begin
            send_data <= {8'b1000000, SW[0]};
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
    
    
    always @(posedge transmit) begin
        LED[11:10] <= user_dir;
    end
    
    // turn on LED[1] or LED[0] if PMOD buttons pressed
    always @(transmit or RST or joystick_data) begin
        if (RST == 1'b1) begin
            LED[1:0] <= 2'b00;
        end
        else begin
            LED[1:0] <= {joystick_data[1], joystick_data[0]};
        end
    end
    
endmodule
