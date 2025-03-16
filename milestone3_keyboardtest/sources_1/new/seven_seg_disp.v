`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Module Name: seven_seg_disp
// Project Name: keyboard_test
// Target Devices: Nexys 4 DDR
// Description: output keyboard data onto seven segment display in PS/2 scan code
//////////////////////////////////////////////////////////////////////////////////


module seven_seg_disp(
    input [31:0] data,
    input clk,
    output reg[6:0] SEG,
    output reg[7:0] AN,
    output wire dp
    );
    
    wire [2:0] select;
    reg [3:0] digit;
    wire [7:0] ANODES;
    reg [19:0] slowCLK;
    
    assign dp = 1;
    assign select = slowCLK[19:17];
    assign ANODES = 8'b11111111; // no seven seg display connected
    
    always @(posedge clk) begin
        case(select)
            0: digit = data[3:0];
            1: digit = data[7:4];
            2: digit = data[11:8];
            3: digit = data[15:12];
            4: digit = data[19:16];
            5: digit = data[23:20];
            6: digit = data[27:24];
            7: digit = data[31:28];
            default: digit = data[3:0];
        endcase
    end
    
    always @(*) begin
        case(digit)
            0: SEG = 7'b1000000;
            1: SEG = 7'b1111001;
            2: SEG = 7'b0100100;
            3: SEG = 7'b0110000;
            4: SEG = 7'b0011001;
            5: SEG = 7'b0010010;
            6: SEG = 7'b0000010;
            7: SEG = 7'b1111000;
            8: SEG = 7'b0000000;
            9: SEG = 7'b0010000;
            'hA: SEG = 7'b0001000;
            'hB: SEG = 7'b0000011;
            'hC: SEG = 7'b1000110;
            'hD: SEG = 7'b0100001;
            'hE: SEG = 7'b0000110;
            'hF: SEG = 7'b0001110;
            
            default: SEG = 7'b0000000;
        endcase
    end
    
    always @(*)begin
        AN = 8'b11111111;
        if (ANODES[select] == 1) begin
            AN[select] = 0;
        end
    end
    
    always @(posedge clk) begin
        slowCLK <= slowCLK + 1'b1;
    end
    
endmodule
