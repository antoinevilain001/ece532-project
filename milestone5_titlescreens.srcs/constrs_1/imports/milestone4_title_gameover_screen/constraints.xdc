## Set the 100 MHz System Clock (Nexys4 DDR)
set_property PACKAGE_PIN E3 [get_ports clk]
set_property IOSTANDARD LVCMOS33 [get_ports clk]
create_clock -period 10.000 [get_ports clk]

## Set the resetn to switch 0 for the moment (Nexys4 DDR)
set_property PACKAGE_PIN J15 [get_ports resetn]
set_property IOSTANDARD LVCMOS33 [get_ports resetn]

## VGA Output (HSYNC, VSYNC)
set_property PACKAGE_PIN B11 [get_ports hsync]
set_property PACKAGE_PIN B12 [get_ports vsync]
set_property IOSTANDARD LVCMOS33 [get_ports hsync]
set_property IOSTANDARD LVCMOS33 [get_ports vsync]

## VGA Red (4-bit)
set_property PACKAGE_PIN A3 [get_ports {vga_r[0]}]
set_property PACKAGE_PIN B4 [get_ports {vga_r[1]}]
set_property PACKAGE_PIN C5 [get_ports {vga_r[2]}]
set_property PACKAGE_PIN A4 [get_ports {vga_r[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports {vga_r[*]}]

## VGA Green (4-bit)
set_property PACKAGE_PIN C6 [get_ports {vga_g[0]}]
set_property PACKAGE_PIN A5 [get_ports {vga_g[1]}]
set_property PACKAGE_PIN B6 [get_ports {vga_g[2]}]
set_property PACKAGE_PIN A6 [get_ports {vga_g[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports {vga_g[*]}]

## VGA Blue (4-bit)
set_property PACKAGE_PIN B7 [get_ports {vga_b[0]}]
set_property PACKAGE_PIN C7 [get_ports {vga_b[1]}]
set_property PACKAGE_PIN D7 [get_ports {vga_b[2]}]
set_property PACKAGE_PIN D8 [get_ports {vga_b[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports {vga_b[*]}]

# ==============================
# 7-Segment Display Outputs
# ==============================
set_property IOSTANDARD LVCMOS33 [get_ports {AN[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {AN[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {AN[2]}]
set_property IOSTANDARD LVCMOS33 [get_ports {AN[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports {AN[4]}]
set_property IOSTANDARD LVCMOS33 [get_ports {AN[5]}]
set_property IOSTANDARD LVCMOS33 [get_ports {AN[6]}]
set_property IOSTANDARD LVCMOS33 [get_ports {AN[7]}]
set_property PACKAGE_PIN J17 [get_ports {AN[0]}]
set_property PACKAGE_PIN J18 [get_ports {AN[1]}]
set_property PACKAGE_PIN T9  [get_ports {AN[2]}]
set_property PACKAGE_PIN J14 [get_ports {AN[3]}]
set_property PACKAGE_PIN P14 [get_ports {AN[4]}]
set_property PACKAGE_PIN T14 [get_ports {AN[5]}]
set_property PACKAGE_PIN K2  [get_ports {AN[6]}]
set_property PACKAGE_PIN U13 [get_ports {AN[7]}]

set_property IOSTANDARD LVCMOS33 [get_ports {SEG[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {SEG[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {SEG[2]}]
set_property IOSTANDARD LVCMOS33 [get_ports {SEG[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports {SEG[4]}]
set_property IOSTANDARD LVCMOS33 [get_ports {SEG[5]}]
set_property IOSTANDARD LVCMOS33 [get_ports {SEG[6]}]
set_property PACKAGE_PIN T10 [get_ports {SEG[0]}]
set_property PACKAGE_PIN R10 [get_ports {SEG[1]}]
set_property PACKAGE_PIN K16 [get_ports {SEG[2]}]
set_property PACKAGE_PIN K13 [get_ports {SEG[3]}]
set_property PACKAGE_PIN P15 [get_ports {SEG[4]}]
set_property PACKAGE_PIN T11 [get_ports {SEG[5]}]
set_property PACKAGE_PIN L18 [get_ports {SEG[6]}]

# ==============================
# LED Outputs
# ==============================
set_property IOSTANDARD LVCMOS33 [get_ports {LED[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {LED[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {LED[2]}]
set_property IOSTANDARD LVCMOS33 [get_ports {LED[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports {LED[4]}]
set_property IOSTANDARD LVCMOS33 [get_ports {LED[5]}]
set_property IOSTANDARD LVCMOS33 [get_ports {LED[6]}]
set_property IOSTANDARD LVCMOS33 [get_ports {LED[7]}]
set_property IOSTANDARD LVCMOS33 [get_ports {LED[8]}]
set_property IOSTANDARD LVCMOS33 [get_ports {LED[9]}]
set_property IOSTANDARD LVCMOS33 [get_ports {LED[10]}]
set_property IOSTANDARD LVCMOS33 [get_ports {LED[11]}]
set_property PACKAGE_PIN H17 [get_ports {LED[0]}]
set_property PACKAGE_PIN K15 [get_ports {LED[1]}]
set_property PACKAGE_PIN J13 [get_ports {LED[2]}]
set_property PACKAGE_PIN N14 [get_ports {LED[3]}]
set_property PACKAGE_PIN R18 [get_ports {LED[4]}]
set_property PACKAGE_PIN V17 [get_ports {LED[5]}]
set_property PACKAGE_PIN U17 [get_ports {LED[6]}]
set_property PACKAGE_PIN U16 [get_ports {LED[7]}]
set_property PACKAGE_PIN V16 [get_ports {LED[8]}]
set_property PACKAGE_PIN T15 [get_ports {LED[9]}]
set_property PACKAGE_PIN U14 [get_ports {LED[10]}]
set_property PACKAGE_PIN T16 [get_ports {LED[11]}]

# ==============================
# PMOD (SPI) Outputs
# ==============================
set_property IOSTANDARD LVCMOS33 [get_ports MISO]
set_property IOSTANDARD LVCMOS33 [get_ports MOSI]
set_property IOSTANDARD LVCMOS33 [get_ports SCLK]
set_property IOSTANDARD LVCMOS33 [get_ports chip_select]

set_property PACKAGE_PIN E18 [get_ports MISO]
set_property PACKAGE_PIN D18 [get_ports MOSI]
set_property PACKAGE_PIN G17 [get_ports SCLK]
set_property PACKAGE_PIN C17 [get_ports chip_select]

# Calibrate input (up button)
set_property IOSTANDARD LVCMOS33 [get_ports CALIBRATE]
set_property PACKAGE_PIN M18 [get_ports CALIBRATE]

# ==============================
# startgame and gameover button inputs, to be changed, for testing purposes
# ==============================
# startgame down button
set_property IOSTANDARD LVCMOS33 [get_ports startgame]
set_property PACKAGE_PIN P17 [get_ports startgame]

# gameover middle button
set_property IOSTANDARD LVCMOS33 [get_ports gameover]
set_property PACKAGE_PIN N17 [get_ports gameover]
