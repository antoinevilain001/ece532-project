`timescale 1ns / 1ps


module vga_bw#(
    parameter GAME_WIDTH = 640,
    parameter GAME_HEIGHT = 480,
    parameter PADDLE_WIDTH = 5,
    parameter PADDLE_HEIGHT = 10,
    parameter BALL_SIZE = 5,
    parameter GAME_UPDATE_DELAY = 4166667, // 24 frames per second with a 100MHz clock
    parameter PADDLE_DISTANCE_FROM_EDGE = 20,
    parameter BORDER_WIDTH = 100
)(
    input clk,          // 100 MHz clock from Nexys4 DDR
    output hsync,   // Horizontal sync
    output vsync,   // Vertical sync
    output [3:0] vga_r, // Red (4-bit)
    output [3:0] vga_g, // Green (4-bit)
    output [3:0] vga_b,  // Blue (4-bit)
    input [7:0] ball_x,
    input [7:0] ball_y,
    input [7:0] paddle1_x,
    input [7:0] paddle1_y,
    input [7:0] paddle2_x,
    input [7:0] paddle2_y
);
    wire active;
    wire [9:0] x, y;
    wire clk_25MHz;

    // Generate 25 MHz clock from 100 MHz input clock
    clock_divider clkdiv(.clk_in(clk), .clk_out(clk_25MHz));

    // VGA sync signal generator
    vga_sync vga(.clk(clk_25MHz), .hsync(hsync), .vsync(vsync), .active(active), .x(x), .y(y));

    wire border = (x < BORDER_WIDTH) || (x > GAME_WIDTH - BORDER_WIDTH) || (y < BORDER_WIDTH) || (y > GAME_HEIGHT - BORDER_WIDTH);
    wire final_display = border;
    
    reg video;
    always @(posedge clk_25MHz) begin
        video <= final_display && active;  // Base condition: Only draw within the active display area
    end

    // Assign the same B&W signal to all color channels
    assign vga_r = video ? 4'b1111 : 4'b0000;
    assign vga_g = video ? 4'b1111 : 4'b0000;
    assign vga_b = video ? 4'b1111 : 4'b0000;
endmodule
