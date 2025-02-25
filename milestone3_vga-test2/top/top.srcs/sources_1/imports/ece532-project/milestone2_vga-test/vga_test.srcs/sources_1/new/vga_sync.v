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
    output reg hsync,      // Horizontal sync
    output reg vsync,      // Vertical sync
    output reg active,     // High when pixels are in the visible area
    output reg [9:0] x,    // X coordinate (0 - 639)
    output reg [9:0] y     // Y coordinate (0 - 479)
);
    // VGA 640x480 @ 60Hz timing (25.175 MHz pixel clock)
    localparam H_SYNC_TIME   = 96;   // Horizontal sync pulse width
    localparam H_BACK_PORCH  = 48;   // Horizontal back porch
    localparam H_ACTIVE_TIME = 640;  // Visible area
    localparam H_FRONT_PORCH = 16;   // Horizontal front porch
    localparam H_TOTAL_TIME  = H_SYNC_TIME + H_BACK_PORCH + H_ACTIVE_TIME + H_FRONT_PORCH; // Total line time (800 pixels)

    localparam V_SYNC_TIME   = 2;    // Vertical sync pulse width
    localparam V_BACK_PORCH  = 33;   // Vertical back porch
    localparam V_ACTIVE_TIME = 480;  // Visible area
    localparam V_FRONT_PORCH = 10;   // Vertical front porch
    localparam V_TOTAL_TIME  = V_SYNC_TIME + V_BACK_PORCH + V_ACTIVE_TIME + V_FRONT_PORCH; // Total frame time (525 lines)

    // Initialize x and y to 0
    initial begin
        x = 0;
        y = 0;
    end

    always @(posedge clk) begin
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

    // Generate sync pulses
    always @(posedge clk) begin
        hsync  <= (x >= H_SYNC_TIME);  // Active low sync pulse
        vsync  <= (y >= V_SYNC_TIME);  // Active low sync pulse
        active <= (x >= H_SYNC_TIME + H_BACK_PORCH) && (x < H_SYNC_TIME + H_BACK_PORCH + H_ACTIVE_TIME) &&
                  (y >= V_SYNC_TIME + V_BACK_PORCH) && (y < V_SYNC_TIME + V_BACK_PORCH + V_ACTIVE_TIME);
    end
endmodule

