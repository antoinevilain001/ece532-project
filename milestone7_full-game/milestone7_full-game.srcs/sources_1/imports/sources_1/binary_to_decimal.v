`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Module Name: binary_to_decimal
// Project Name: joystick
// Target Devices: Nexys 4 DDR
// Description: converts 10 bit binary into decimal (16 bit binary coded)
// 
//////////////////////////////////////////////////////////////////////////////////


module binary_to_decimal(
    CLK,
    RST,
    START,
    IN,
    OUT
    );
    
    input CLK;
    input RST;
    input START;
    input [9:0] IN;
    output [15:0] OUT;
    
    reg [15:0] OUT = 16'h0000;
    reg [4:0] shift_count = 5'b00000;
    reg [27:0] temp_shift;
    
    parameter [2:0] Idle = 3'b000,
                    Init = 3'b001,
                    Shift = 3'b011,
                    Check = 3'b010,
                    Done = 3'b110;
    reg [2:0] state = Idle;
                    
    always @(posedge CLK) begin
        if (RST == 1'b1) begin
            OUT <= 16'h0000;
            temp_shift <= 28'h0000000;
            state <= Idle;
        end
        else begin
            case (state)
                Idle:begin
                    OUT <= OUT;
                    temp_shift <= 28'h0000000;
                    
                    if (START == 1'b1) begin
                        state <= Init;
                    end
                    else begin
                        state <= Idle;
                    end
                end
                Init:begin
                    OUT <= OUT;
                    temp_shift <= {18'b000000000000000000, IN};
                    
                    state <= Shift;
                end
                Shift:begin
                    OUT <= OUT;
                    temp_shift <= {temp_shift[26:0], 1'b0};
                    
                    shift_count <= shift_count + 1'b1;
                    
                    state <= Check;
                end
                Check:begin
                    OUT <= OUT;
                    if (shift_count != 5'd12) begin
                        if (temp_shift[27:24] >= 3'd5) begin
                            temp_shift [27:24] <= temp_shift[27:24] + 2'd3;
                        end
                        if (temp_shift[23:20] >= 3'd5) begin
                            temp_shift [23:20] <= temp_shift[23:20] + 2'd3;
                        end
                        if (temp_shift[19:16] >= 3'd5) begin
                            temp_shift [19:16] <= temp_shift[19:16] + 2'd3;
                        end
                        if (temp_shift[15:12] >= 3'd5) begin
                            temp_shift [15:12] <= temp_shift[15:12] + 2'd3;
                        end
                        
                        state <= Shift;
                    end
                    else begin
                        state <= Done;
                    end
                end
                Done:begin
                    OUT <= temp_shift[27:12];
                    temp_shift <= 28'h0000000;
                    shift_count <= 5'b00000;
                    
                    state <= Idle;
                end
            endcase
        end
    end
    
    
endmodule
