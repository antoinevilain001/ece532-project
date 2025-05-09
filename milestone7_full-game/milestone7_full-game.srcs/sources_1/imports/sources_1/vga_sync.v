`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
//
// generates the properly-formatted vga output pulses to show things on the monitor
// 
//////////////////////////////////////////////////////////////////////////////////


module vga_sync(
    input clk,             // 25 MHz clock
    input resetn,
    output hsync,      // Horizontal sync
    output vsync,      // Vertical sync
    output active,     // High when pixels are in the visible area
    output reg [9:0] x,    // X coordinate (0 - 639)
    output reg [9:0] y     // Y coordinate (0 - 479)
);
    // VGA 640x480 @ 60Hz timing parameters
    parameter H_ACTIVE = 640;   // Active pixels per line
    parameter H_FRONT_PORCH = 16;   // 16
    parameter H_SYNC_PULSE = 96;    // 96
    parameter H_BACK_PORCH = 48;    // 48
    parameter H_TOTAL_TIME = H_ACTIVE + H_FRONT_PORCH + H_SYNC_PULSE + H_BACK_PORCH;

    parameter V_ACTIVE = 480;   // Active lines per frame
    parameter V_FRONT_PORCH = 10;   // 10
    parameter V_SYNC_PULSE = 2;     // 2
    parameter V_BACK_PORCH = 33;    // 33
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
    assign hsync = ~((x >= (H_ACTIVE + H_FRONT_PORCH)) && (x < (H_ACTIVE + H_FRONT_PORCH + H_SYNC_PULSE)));
    assign vsync = ~((y >= (V_ACTIVE + V_FRONT_PORCH)) && (y < (V_ACTIVE + V_FRONT_PORCH + V_SYNC_PULSE)));
    assign active = (x < H_ACTIVE) && (y < V_ACTIVE);

endmodule

