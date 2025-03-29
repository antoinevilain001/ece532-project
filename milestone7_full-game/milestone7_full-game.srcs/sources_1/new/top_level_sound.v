`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/29/2025 04:10:50 PM
// Design Name: 
// Module Name: top_level_sound
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


module top_level_sound (
    output [1:0]GPIO_0_tri_o,
    input SW0,
    input reset,
    input sys_clock,
    output [1:0] LED
    );

    wire [1:0]GPIO_0_tri_o;
    wire [31:0]microblaze_input_tri_i;
    wire [15:0]microblaze_output_tri_o;
    wire reset;
    wire sys_clock;
    
    assign microblaze_input_tri_i[0] = SW0;
    assign microblaze_input_tri_i[31:1] = 0;
    
    assign LED[0] = microblaze_output_tri_o[0];
    assign LED[1] = microblaze_output_tri_o[1];

    sound_wrapper sound_wrapper_inst(
        .GPIO_0_tri_o(GPIO_0_tri_o),
        .microblaze_input_tri_i(microblaze_input_tri_i),
        .microblaze_output_tri_o(microblaze_output_tri_o),
        .reset(reset),
        .sys_clock(sys_clock)
    );
endmodule

