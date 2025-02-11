`timescale 1ns / 1ps


module vga_bw(
    input clk,          // 100 MHz clock from Nexys4 DDR
    output hsync,   // Horizontal sync
    output vsync,   // Vertical sync
    output [3:0] vga_r, // Red (4-bit)
    output [3:0] vga_g, // Green (4-bit)
    output [3:0] vga_b  // Blue (4-bit)
);
    wire active;
    wire [9:0] x, y;
    wire clk_25MHz;

    // Generate 25 MHz clock from 100 MHz input clock
    clock_divider clkdiv(.clk_in(clk), .clk_out(clk_25MHz));

    // VGA sync signal generator
    vga_sync vga(.clk(clk_25MHz), .hsync(hsync), .vsync(vsync), .active(active), .x(x), .y(y));

    // B&W pattern: Simple vertical stripes
    wire video = x[5] & active;

    // Assign the same B&W signal to all color channels
    assign vga_r = video ? 4'b1111 : 4'b0000;
    assign vga_g = video ? 4'b1111 : 4'b0000;
    assign vga_b = video ? 4'b1111 : 4'b0000;
endmodule
