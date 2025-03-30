`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Module Name: joystick_interface
// Project Name: joystick_interface
// Target Devices: Nexys 4 DDR
//
// Description: module consists of SPI controller and SPI interface
//              interace sends and receives data from/to joystick
//              controller manages the data transfer requests
// 
//////////////////////////////////////////////////////////////////////////////////


module joystick_interface(
    CLK,
    RST,
    transmit,
    data_in,
    chip_select,
    MOSI,
    MISO,
    SCLK,
    data_out
    );
    
    // declare ports
    input CLK;              // 100 MHz FPGA clock
    input RST;              // reset
    input transmit;         // 
    input [7:0] data_in;    // send data to slave
    output chip_select;     // chip select on slave, active high
    output MOSI;            // master out slave in
    input MISO;             // master in slave out
    output SCLK;            // serial clock
    output [7:0] data_out;  // all data that is read from slave
    
    wire chip_select;
    wire SCLK;
    wire MOSI;
    wire [39:0] data_out;
    wire get_byte;          // signal to initiate data byte transfer
    wire [7:0] send_data;   // data to send to slave
    wire [7:0] recv_data;   // data byte received 
    wire BUSY;              // interface<->controller handshake signal
    wire slowCLK;
    
    // instantiate SPI controller
    spi_controller SPI_CTRL(
        .CLK(slowCLK),
        .RST(RST),
        .transmit(transmit),
        .BUSY(BUSY),
        .data_in(data_in),
        .recv_data(recv_data),
        .chip_select(chip_select),
        .get_byte(get_byte),
        .send_data(send_data),
        .data_out(data_out)
    );
    
    spi_interface SPI_INT(
        .CLK(slowCLK),
        .RST(RST),
        .transmit(get_byte),
        .data_in(send_data),
        .MISO(MISO),
        .MOSI(MOSI),
        .SCLK(SCLK),
        .BUSY(BUSY),
        .data_out(recv_data)
    );
    
    clk_66khz CLK66K(
        .CLK(CLK),
        .RST(RST),
        .CLKOUT(slowCLK)
    );
    
    
endmodule
