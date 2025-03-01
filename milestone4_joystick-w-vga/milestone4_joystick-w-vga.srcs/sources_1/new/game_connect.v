`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
//
// connects the pong game and vga output to the joystick input
// 
//////////////////////////////////////////////////////////////////////////////////


module game_connect (
    input clk,
    input resetn,
    input MISO,         // SPI MISO from joystick
    input CALIBRATE,    // Calibration button
    output hsync,
    output vsync,
    output [3:0] vga_r,
    output [3:0] vga_g,
    output [3:0] vga_b,
    output chip_select, // SPI Chip Select
    output MOSI,        // SPI MOSI
    output SCLK,        // SPI Clock
    output [11:0] LED,  // LEDs
    output [3:0] AN,    // 7-segment anodes
    output [6:0] SEG    // 7-segment cathodes
);

    wire [1:0] user_dir;  // Direction output from joystick

    // Instantiate the joystick module
    joystick joystick_inst (
        .CLK(clk),
        .RST(!resetn), // uses active-high reset?
        .MISO(MISO),
        .chip_select(chip_select),
        .MOSI(MOSI),
        .SCLK(SCLK),
        .LED(LED),
        .AN(AN),
        .SEG(SEG),
        .CALIBRATE(CALIBRATE),
        .user_dir(user_dir)
    );

    // Instantiate the game logic (top) module
    top #(
        .GAME_WIDTH(640),
        .GAME_HEIGHT(480),
        .PADDLE_WIDTH(10),
        .PADDLE_HEIGHT(50),
        .BALL_SIZE(10),
        .GAME_UPDATE_DELAY(4166667), // 24 FPS with 100MHz clock
        .PADDLE_DISTANCE_FROM_EDGE(100)
    ) top_inst (
        .clk(clk),
        .resetn(resetn),
        .user_dir(user_dir),
        .hsync(hsync),
        .vsync(vsync),
        .vga_r(vga_r),
        .vga_g(vga_g),
        .vga_b(vga_b)
    );

endmodule

