`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Module Name: spi_interface
// Project Name: joystick_test
// Target Devices: Nexys 4 DDR
// Description: joystick uses SPI mode 0
//              Nexys read MISO input on rising edges
//              joystick read MOSI output on rising edges
//              change data on falling edges
//              assert transmit to initialize data transfer
//              BUSY asserted while transfer in progress
//      
//////////////////////////////////////////////////////////////////////////////////


module spi_interface(
    CLK,
    RST,
    transmit,
    data_in,
    MISO,
    MOSI,
    SCLK,
    BUSY,
    data_out
    );
    
    input CLK;
    input RST;
    input transmit;
    input [7:0] data_in;
    input MISO;
    output MOSI;
    output SCLK;
    output BUSY;
    output [7:0] data_out;
    
    
    wire MOSI;
    wire SCLK;
    wire [7:0] data_out;
    reg BUSY;
    
    parameter [1:0] Idle = 2'd0,
                    Init = 2'd1,
                    Transfer = 2'd2,
                    Done = 2'd3;
    
    reg [4:0] bit_count;
    reg [7:0] read_shift = 8'h00;
    reg [7:0] write_shift = 8'h00;
    reg [1:0] current_state = Idle;
    
    reg clock_enable = 0;
    
    assign SCLK = (clock_enable == 1'b1) ? CLK : 1'b0;
    assign MOSI = write_shift[7]; // all commands start with MSB = 1
    assign data_out = read_shift;
    
    always @(negedge CLK) begin
        if (RST == 1'b1) begin
            write_shift <= 8'h00;
        end
        else begin
            case(current_state)
                Idle: begin
                    write_shift <= data_in;
                end
                Init: begin
                    write_shift <= write_shift;
                end
                Transfer: begin
                    if (clock_enable == 1'b1) begin
                        write_shift <= {write_shift[6:0], 1'b0};
                    end
                end
                Done: begin
                    write_shift <= write_shift;
                end
            endcase
        end
    end
    
    always @(posedge CLK) begin
        if (RST == 1'b1) begin
            read_shift <= 8'h00;
        end
        else begin
            case(current_state)
                Idle: begin
                    read_shift <= read_shift;
                end
                Init: begin
                    read_shift <= read_shift;
                end
                Transfer: begin
                    if (clock_enable == 1'b1) begin
                        read_shift <= {read_shift[6:0], MISO};
                    end
                end
                Done: begin
                    read_shift <= read_shift;
                end
            endcase
        end
    end
    
    // SPI mode 0
    always @(negedge CLK) begin
        if (RST == 1'b1) begin
            clock_enable <= 1'b0;
            BUSY <= 1'b0;
            bit_count <= 4'h0;
            current_state <= Idle;
        end
        else begin
            case (current_state)
                Idle: begin
                    clock_enable <= 1'b0;
                    BUSY <= 1'b0;
                    bit_count <= 4'd0;
                    
                    if (transmit == 1'b1) begin
                        current_state <= Init;
                    end
                    else begin
                        current_state <= Idle;
                    end
                end
                Init: begin
                    BUSY <= 1'b1;
                    bit_count <= 4'h0;
                    clock_enable <= 1'b0;
                    
                    current_state <= Transfer;
                end
                Transfer: begin
                    BUSY <= 1'b1;
                    bit_count <= bit_count + 1'b1;
                    
                    if (bit_count >= 4'd8) begin
                        clock_enable <= 1'b0;
                    end
                    else begin
                        clock_enable <= 1'b1;
                    end
                    if (bit_count == 4'd8) begin
                        current_state <= Done;
                    end
                    else begin
                        current_state <= Transfer;
                    end
                end
                Done: begin
                    clock_enable <= 1'b0;
                    BUSY <= 1'b1;
                    bit_count <= 4'd0;
                    
                    current_state <= Idle;
                end
                default: current_state <= Idle;
            endcase
        end
    end
    
endmodule
