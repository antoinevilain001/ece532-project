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
    input sys_clock
    );

    wire [1:0]GPIO_0_tri_o;
    wire [31:0]game_input_tri_i;
    wire reset;
    wire sys_clock;
    
    assign game_input_tri_i[0] = SW0;
    assign game_input_tri_i[31:1] = 0;

    sound_wrapper sound_wrapper_inst(
        .GPIO_0_tri_o(GPIO_0_tri_o),
        .game_input_tri_i(game_input_tri_i),
        .reset(reset),
        .sys_clock(sys_clock)
    );
endmodule

