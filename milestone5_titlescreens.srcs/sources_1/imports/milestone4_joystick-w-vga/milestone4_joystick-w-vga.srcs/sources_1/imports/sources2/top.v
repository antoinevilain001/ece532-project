`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/09/2025 02:54:11 PM
// Design Name: 
// Module Name: top
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module top #(
    parameter GAME_WIDTH = 640,
    parameter GAME_HEIGHT = 480,
    parameter PADDLE_WIDTH = 10,
    parameter PADDLE_HEIGHT = 50,
    parameter BALL_SIZE = 10,
    parameter GAME_UPDATE_DELAY = 4166667, // 24 frames per second with a 100MHz clock
    parameter PADDLE_DISTANCE_FROM_EDGE = 100
    )(
    input clk,          // 100 MHz clock from Nexys4 DDR
    input resetn,
    input [1:0] user_dir,
    output hsync,   // Horizontal sync
    output vsync,   // Vertical sync
    output [3:0] vga_r, // Red (4-bit)
    output [3:0] vga_g, // Green (4-bit)
    output [3:0] vga_b,  // Blue (4-bit)
    output [9:0] score1,
    output [9:0] score2
    );
    
    // Signal declarations
    wire [9:0] paddle1_x, paddle1_y;
    wire [9:0] paddle2_x, paddle2_y;
    wire [9:0] ball_x, ball_y;
    wire [31:0] update_game_counter;
    wire update_game;
    
    vga_bw #(
        .GAME_WIDTH(GAME_WIDTH),
        .GAME_HEIGHT(GAME_HEIGHT),
        .PADDLE_WIDTH(PADDLE_WIDTH),
        .PADDLE_HEIGHT(PADDLE_HEIGHT),
        .BALL_SIZE(BALL_SIZE),
        .GAME_UPDATE_DELAY(GAME_UPDATE_DELAY),
        .PADDLE_DISTANCE_FROM_EDGE(PADDLE_DISTANCE_FROM_EDGE)
    ) vga_instance (
        .clk(clk),
        .resetn(resetn),
        .hsync(hsync),
        .vsync(vsync),
        .vga_r(vga_r),
        .vga_g(vga_g),
        .vga_b(vga_b),
        .ball_x(ball_x),
        .ball_y(ball_y),
        .paddle1_x(paddle1_x),
        .paddle1_y(paddle1_y),
        .paddle2_x(paddle2_x),
        .paddle2_y(paddle2_y)
    );
    
    // Instantiate the pong module
    pong #(
        .GAME_WIDTH(GAME_WIDTH),
        .GAME_HEIGHT(GAME_HEIGHT),
        .PADDLE_WIDTH(PADDLE_WIDTH),
        .PADDLE_HEIGHT(PADDLE_HEIGHT),
        .BALL_SIZE(BALL_SIZE),
        .GAME_UPDATE_DELAY(GAME_UPDATE_DELAY),
        .PADDLE_DISTANCE_FROM_EDGE(PADDLE_DISTANCE_FROM_EDGE)
    ) pong_instance (
        .clk(clk),
        .resetn(resetn),
        .user_dir(user_dir),
        .paddle1_x(paddle1_x),
        .paddle1_y(paddle1_y),
        .paddle2_x(paddle2_x),
        .paddle2_y(paddle2_y),
        .ball_x(ball_x),
        .ball_y(ball_y),
        .score1(score1),
        .score2(score2),
        .update_game_counter(update_game_counter),
        .update_game(update_game)
    );

    
endmodule
