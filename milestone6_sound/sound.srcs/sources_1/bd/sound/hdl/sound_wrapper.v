//Copyright 1986-2018 Xilinx, Inc. All Rights Reserved.
//--------------------------------------------------------------------------------
//Tool Version: Vivado v.2018.3 (win64) Build 2405991 Thu Dec  6 23:38:27 MST 2018
//Date        : Wed Mar 26 15:58:54 2025
//Host        : DESKTOP-7EAMSPE running 64-bit major release  (build 9200)
//Command     : generate_target sound_wrapper.bd
//Design      : sound_wrapper
//Purpose     : IP block netlist
//--------------------------------------------------------------------------------
`timescale 1 ps / 1 ps

module sound_wrapper
   (GPIO_0_tri_o,
    reset,
    sys_clock);
  output [1:0]GPIO_0_tri_o;
  input reset;
  input sys_clock;

  wire [1:0]GPIO_0_tri_o;
  wire reset;
  wire sys_clock;

  sound sound_i
       (.GPIO_0_tri_o(GPIO_0_tri_o),
        .reset(reset),
        .sys_clock(sys_clock));
endmodule
