//Copyright 1986-2018 Xilinx, Inc. All Rights Reserved.
//--------------------------------------------------------------------------------
//Tool Version: Vivado v.2018.3 (win64) Build 2405991 Thu Dec  6 23:38:27 MST 2018
//Date        : Sat Mar 29 14:20:23 2025
//Host        : DESKTOP-7EAMSPE running 64-bit major release  (build 9200)
//Command     : generate_target sound_wrapper.bd
//Design      : sound_wrapper
//Purpose     : IP block netlist
//--------------------------------------------------------------------------------
`timescale 1 ps / 1 ps

module sound_wrapper
   (GPIO_0_tri_o,
    collision_tri_i,
    reset,
    sys_clock);
  output [1:0]GPIO_0_tri_o;
  input [0:0]collision_tri_i;
  input reset;
  input sys_clock;

  wire [1:0]GPIO_0_tri_o;
  wire [0:0]collision_tri_i;
  wire reset;
  wire sys_clock;

  sound sound_i
       (.GPIO_0_tri_o(GPIO_0_tri_o),
        .collision_tri_i(collision_tri_i),
        .reset(reset),
        .sys_clock(sys_clock));
endmodule
