`timescale 1ns / 1ps


module vga_bw#(
    parameter GAME_WIDTH = 640,
    parameter GAME_HEIGHT = 480,
    parameter PADDLE_WIDTH = 5,
    parameter PADDLE_HEIGHT = 10,
    parameter BALL_SIZE = 5,
    parameter GAME_UPDATE_DELAY = 4166667, // 24 frames per second with a 100MHz clock
    parameter PADDLE_DISTANCE_FROM_EDGE = 20,
    parameter BORDER_WIDTH = 1
)(
    input clk,          // 100 MHz clock from Nexys4 DDR
    input resetn,
    output hsync,   // Horizontal sync
    output vsync,   // Vertical sync
    output [3:0] vga_r, // Red (4-bit)
    output [3:0] vga_g, // Green (4-bit)
    output [3:0] vga_b,  // Blue (4-bit)
    input [9:0] ball_x,
    input [9:0] ball_y,
    input [9:0] paddle1_x,
    input [9:0] paddle1_y,
    input [9:0] paddle2_x,
    input [9:0] paddle2_y
);
    wire active;
    wire [9:0] x, y;
    wire [9:0] hcount, vcount;
    wire clk_25MHz;

    // Generate 25 MHz clock from 100 MHz input clock
    clock_divider clkdiv(.clk_in(clk), .clk_out(clk_25MHz));

    // VGA sync signal generator
    vga_sync vga(.clk(clk_25MHz), .hsync(hsync), .vsync(vsync), .active(active), .x(hcount), .y(vcount));
    assign x = hcount;
    assign y = vcount;

    // the current positions
    wire [9:0] vball_x = ball_x;
    wire [9:0] vball_y = ball_y;
    wire [9:0] vpaddle1_x = paddle1_x;
    wire [9:0] vpaddle1_y = paddle1_y;
    wire [9:0] vpaddle2_x = paddle2_x;
    wire [9:0] vpaddle2_y = paddle2_y;
    
    wire border_left = (x == 0) || (x == 2);
    wire border_right = (x == GAME_WIDTH - 1) || (x == GAME_WIDTH - 3);
    wire border_top = (y == 0) || (y == 2);
    wire border_bottom = (y == GAME_HEIGHT - 1) || (y == GAME_HEIGHT - 3);
    wire border = border_left || border_right || border_bottom || border_top;
    wire centerlines = (x == GAME_WIDTH >> 1) || (y == GAME_HEIGHT >> 1);
    
    wire vball = (x >= vball_x) && (x < vball_x + BALL_SIZE) && (y >= vball_y) && (y < vball_y + BALL_SIZE);
    wire vpaddle1 = (x >= vpaddle1_x) && (x < vpaddle1_x + PADDLE_WIDTH) && (y >= vpaddle1_y) && (y < vpaddle1_y + PADDLE_HEIGHT);
    wire vpaddle2 = (x >= vpaddle2_x) && (x < vpaddle2_x + PADDLE_WIDTH) && (y >= vpaddle2_y) && (y < vpaddle2_y + PADDLE_HEIGHT);
    
    wire ball_trace = (x == ball_x) || (y == ball_y);
    wire paddle1_trace = (x == paddle1_x) || (y == paddle1_y);
    wire paddle2_trace = (x == paddle2_x) || (y == paddle2_y);
    
    wire final_display = border || vball || vpaddle1 || vpaddle2 || ball_trace || paddle1_trace || paddle2_trace;
    
    reg video;
    always @(posedge clk_25MHz) begin
        video <= final_display && active;  // Base condition: Only draw within the active display area
    end

    // Assign the same B&W signal to all color channels
    assign vga_r = video ? 4'b1111 : 4'b0000;
    assign vga_g = video ? 4'b1111 : 4'b0000;
    assign vga_b = video ? 4'b1111 : 4'b0000;
endmodule
