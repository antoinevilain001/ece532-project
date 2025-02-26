`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/10/2025 11:59:04 PM
// Design Name: 
// Module Name: vga_sync
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


module vga_sync(
    input clk,             // 25 MHz clock
    input resetn,
    output reg hsync,      // Horizontal sync
    output reg vsync,      // Vertical sync
    output reg active,     // High when pixels are in the visible area
    output reg [9:0] x,    // X coordinate (0 - 639)
    output reg [9:0] y     // Y coordinate (0 - 479)
);
    // VGA 640x480 @ 60Hz timing parameters
    parameter H_ACTIVE = 640;   // Active pixels per line
    parameter H_FRONT_PORCH = 16;
    parameter H_SYNC_PULSE = 96;
    parameter H_BACK_PORCH = 48;
    parameter H_TOTAL_TIME = H_ACTIVE + H_FRONT_PORCH + H_SYNC_PULSE + H_BACK_PORCH;

    parameter V_ACTIVE = 480;   // Active lines per frame
    parameter V_FRONT_PORCH = 10;
    parameter V_SYNC_PULSE = 2;
    parameter V_BACK_PORCH = 33;
    parameter V_TOTAL_TIME = V_ACTIVE + V_FRONT_PORCH + V_SYNC_PULSE + V_BACK_PORCH;

    initial begin
        x <= 0;
        y <= 0;
    end

    always @(posedge clk) begin
        if (0) begin // never reset
            x <= 0;
            y <= 0;
        end else begin
            // Increment X coordinate
            if (x < H_TOTAL_TIME - 1)
                x <= x + 1;
            else begin
                x <= 0;
                // Increment Y coordinate
                if (y < V_TOTAL_TIME - 1)
                    y <= y + 1;
                else
                    y <= 0;
            end
        end
    end

    // Generate sync pulses
    always @(posedge clk) begin
        if (0) begin // never reset
            hsync <= 1; // active low
            vsync <= 1; // active low
            active <= 0;
        end else begin
            hsync <= ~((x >= (H_ACTIVE + H_FRONT_PORCH)) && (x < (H_ACTIVE + H_FRONT_PORCH + H_SYNC_PULSE)));
            vsync <= ~((y >= (V_ACTIVE + V_FRONT_PORCH)) && (y < (V_ACTIVE + V_FRONT_PORCH + V_SYNC_PULSE)));
            active <= (x < H_ACTIVE) && (y < V_ACTIVE);
        end
    end
endmodule

