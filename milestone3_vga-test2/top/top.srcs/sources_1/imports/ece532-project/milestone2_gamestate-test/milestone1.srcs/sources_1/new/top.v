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


module top(
    input clk,          // 100 MHz clock from Nexys4 DDR
    output hsync,   // Horizontal sync
    output vsync,   // Vertical sync
    output [3:0] vga_r, // Red (4-bit)
    output [3:0] vga_g, // Green (4-bit)
    output [3:0] vga_b  // Blue (4-bit)
    );
    
    vga_bw my_vga (
        .clk(clk),
        .hsync(hsync),
        .vsync(vsync),
        .vga_r(vga_r),
        .vga_g(vga_g),
        .vga_b(vga_b)
    );
endmodule
