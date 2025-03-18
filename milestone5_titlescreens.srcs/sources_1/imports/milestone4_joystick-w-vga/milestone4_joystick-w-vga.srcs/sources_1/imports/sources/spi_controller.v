`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Module Name: spi_controller
// Project Name: joystick_test
// Target Devices: Nexys 4 DDR
// Description: manages data transfer requests, exact data packet
//              is found at https://digilent.com/reference/pmod/pmodjstk2/reference-manual?redirect=1
// 
//////////////////////////////////////////////////////////////////////////////////


module spi_controller(
    CLK,
    RST,
    transmit,
    BUSY,
    data_in,
    recv_data,
    chip_select,
    get_byte,
    send_data,
    data_out
    );
    
    // declare ports
    input CLK;
    input RST;
    input transmit;
    input BUSY;
    input [7:0] data_in;
    input [7:0] recv_data;
    output chip_select;
    output get_byte;
    output send_data;
    output [39:0] data_out;
    
    reg chip_select = 1'b1;     // chip select is active low
    reg get_byte = 1'b0;
    reg [7:0] send_data = 8'h00;
    reg [39:0] data_out = 40'h0000000000;
    
    // finite state machine
    parameter [2:0] Idle = 3'd0,
                    Init = 3'd1,
                    Wait = 3'd2,
                    Check = 3'd3,
                    Done = 3'd4;
    
    reg [2:0] current_state = Idle;
    reg [2:0] byte_count = 3'd0;
    parameter  byte_end = 3'd5;      // read 5 bytes
    reg [39:0] temp_shift = 40'h0000000000;
    
    
    
    always @ (posedge CLK) begin
        if (RST == 1'b1) begin
            chip_select <= 1'b1;
            get_byte <= 1'b0;
            send_data <= 8'h00;
            temp_shift <= 40'h0000000000;
            data_out <= 40'h0000000000;
            byte_count <= 3'd0;
            current_state <= Idle;
        end
        else begin
            case(current_state)
                Idle: begin
                    chip_select <= 1'b1;
                    get_byte <= 1'b0;
                    send_data <= 8'h00;
                    temp_shift <= 40'h0000000000;
                    data_out <= data_out;
                    byte_count <= 3'd0;
                    
                    if (transmit == 1'b1) begin
                        current_state <= Init;
                    end
                    else begin
                        current_state <= Idle;
                    end
                end
                Init: begin
                    chip_select <= 1'b0;
                    get_byte <= 1'b1;
                    send_data <= data_in;
                    temp_shift <= temp_shift;
                    data_out <= data_out;
                    
                    if (BUSY == 1'b1) begin
                        current_state <= Wait;
                        byte_count <= byte_count + 1'b1;
                    end 
                    else begin
                        current_state <= Init;
                    end
                end
                Wait: begin
                    chip_select <= 1'b0;
                    get_byte <= 1'b0;
                    send_data <= send_data;
                    temp_shift <= temp_shift;
                    data_out <= data_out;
                    byte_count <= byte_count;
                    
                    if (BUSY == 1'b0) begin
                        current_state <= Check;
                    end
                    else begin
                        current_state <= Wait;
                    end
                end
                Check: begin
                    chip_select <= 1'b0;
                    get_byte <= 1'b0;
                    send_data <= send_data;
                    temp_shift <= {temp_shift[31:0], recv_data};
                    data_out <= data_out;
                    byte_count <= byte_count;
                    
                    if (byte_count == 3'd5) begin
                        current_state <= Done;
                    end
                    else begin
                        current_state <= Init;
                    end
                end
                Done: begin
                    chip_select = 1'b1;
                    get_byte <= 1'b0;
                    send_data <= 8'h00;
                    temp_shift <= temp_shift;
                    data_out <= temp_shift[39:0];
                    byte_count <= byte_count;
                    
                    if (transmit == 1'b0) begin
                        current_state <= Idle;
                    end
                    else begin
                        current_state <= Done;
                    end
                end
                default: current_state <= Idle;
            endcase
        end
        
    end
    
endmodule
