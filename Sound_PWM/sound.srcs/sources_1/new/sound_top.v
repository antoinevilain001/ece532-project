`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/29/2025 02:32:38 PM
// Design Name: 
// Module Name: sound_top
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


module sound_top(
    GPIO_0_tri_o,
    reset,
    sys_clock
    );
  output [1:0]GPIO_0_tri_o;
  input reset;
  input sys_clock;
  
  wire collision;
  
  sound_wrapper sound_wrapper_i
       (.GPIO_0_tri_o(GPIO_0_tri_o),
        .collision_tri_i(collision),
        .reset(reset),
        .sys_clock(sys_clock));
        
  assign collision = 1;
  
endmodule
