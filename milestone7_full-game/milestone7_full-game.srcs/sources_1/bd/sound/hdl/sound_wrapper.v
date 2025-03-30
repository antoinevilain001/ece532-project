//Copyright 1986-2018 Xilinx, Inc. All Rights Reserved.
//--------------------------------------------------------------------------------
//Tool Version: Vivado v.2018.3 (win64) Build 2405991 Thu Dec  6 23:38:27 MST 2018
//Date        : Sun Mar 30 11:48:09 2025
//Host        : LAPTOP-DLQ934AQ running 64-bit major release  (build 9200)
//Command     : generate_target sound_wrapper.bd
//Design      : sound_wrapper
//Purpose     : IP block netlist
//--------------------------------------------------------------------------------
`timescale 1 ps / 1 ps

module sound_wrapper
   (GPIO_0_tri_o,
    microblaze_input_tri_i,
    microblaze_output_tri_o,
    resetn,
    sys_clock);
  output [1:0]GPIO_0_tri_o;
  input [31:0]microblaze_input_tri_i;
  output [15:0]microblaze_output_tri_o;
  input resetn;
  input sys_clock;

  wire [1:0]GPIO_0_tri_o;
  wire [31:0]microblaze_input_tri_i;
  wire [15:0]microblaze_output_tri_o;
  wire resetn;
  wire sys_clock;

  sound sound_i
       (.GPIO_0_tri_o(GPIO_0_tri_o),
        .microblaze_input_tri_i(microblaze_input_tri_i),
        .microblaze_output_tri_o(microblaze_output_tri_o),
        .resetn(resetn),
        .sys_clock(sys_clock));
endmodule
