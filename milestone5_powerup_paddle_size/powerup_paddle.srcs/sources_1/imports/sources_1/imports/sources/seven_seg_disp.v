`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Module Name: seven_seg_disp
// Project Name: joystick
// Target Devices: Nexys 4 DDR
// Description: takes in x and y position (0~1023)
//              output position in decimal format on seven seg display
// 
//////////////////////////////////////////////////////////////////////////////////


module seven_seg_disp(
    CLK,
    RST,
    x_pos,
    y_pos,
    AN,
    SEG
    );
    
    input CLK;
    input RST;
    input [9:0] x_pos;
    input [9:0] y_pos;
    output [7:0] AN;
    output [6:0] SEG;
    
    reg [7:0] AN = 7'b1111111;
    reg [6:0] SEG = 7'b0000000;
    
    // 1 kHz clock divider
    parameter clock_end = 16'hC350;
    reg [15:0] clock_count = 16'h0000;
    reg DCLK;
    
    reg [2:0] count = 3'b000;
    wire [15:0] x_decimal;
    wire [15:0] y_decimal;
    reg [3:0] data_mux;
    
    binary_to_decimal BtoD_x(
		.CLK(CLK),
		.RST(RST),
		.START(DCLK),
		.IN(x_pos),
		.OUT(x_decimal)
	);
	
	binary_to_decimal BtoD_y(
		.CLK(CLK),
		.RST(RST),
		.START(DCLK),
		.IN(y_pos),
		.OUT(y_decimal)
	);
	
	// select which data for which seven seg disp
	always @(count[1], count[0], x_decimal, y_decimal, RST) begin
	   if (RST == 1'b1) begin
	       data_mux <= 4'b0000;
	   end
	   else begin
	       case (count)
	           3'b000: data_mux <= y_decimal[3:0];
	           3'b001: data_mux <= y_decimal[7:4];
	           3'b010: data_mux <= y_decimal[11:8];
	           3'b011: data_mux <= y_decimal[15:12];
	           3'b100: data_mux <= x_decimal[3:0];
	           3'b101: data_mux <= x_decimal[7:4];
	           3'b110: data_mux <= x_decimal[11:8];
	           3'b111: data_mux <= x_decimal[15:12];
	       endcase
	   end
	end
	
	// cathode detector drives low if illuminated
	always @(posedge DCLK) begin
	   if (RST == 1'b1) begin
	       SEG <= 7'b1000000;
	   end
	   else begin
	       case (data_mux)
	           4'b0000: SEG <= 7'b1000000;
	           4'b0001: SEG <= 7'b1111001;
	           4'b0010: SEG <= 7'b0100100;
	           4'b0011: SEG <= 7'b0110000;
	           4'b0100: SEG <= 7'b0011001;
	           4'b0101: SEG <= 7'b0010010;
	           4'b0110: SEG <= 7'b0000010;
	           4'b0111: SEG <= 7'b1111000;
	           4'b1000: SEG <= 7'b0000000;
	           4'b1001: SEG <= 7'b0010000;
	           default: SEG <= 7'b1000000;
	       endcase
	   end
	end
	
	// anode decoder, drives correct anode low
	always @(posedge DCLK) begin
	   if (RST == 1'b1) begin
	       AN <= 8'h00;
	   end
	   else begin
	       case (count)
	           3'b000: AN <= 8'b11111110;
	           3'b001: AN <= 8'b11111101;
	           3'b010: AN <= 8'b11111011;
	           3'b011: AN <= 8'b11110111;
	           3'b100: AN <= 8'b11101111;
	           3'b101: AN <= 8'b11011111;
	           3'b110: AN <= 8'b10111111;
	           3'b111: AN <= 8'b01111111;
	       endcase
	   end
	end
	
	// 3 bit counter
	always @(posedge DCLK) begin
	   count <= count + 1'b1;
	end
    
	
	// generate 1 kHz clock divider for refreshing seven seg disp
	always @(posedge CLK) begin
	   if (clock_count == clock_end) begin
	       DCLK <= 1'b1;
	       clock_count <= 16'h0000;
	   end
	   else begin
	       DCLK <= 1'b0;
	       clock_count <= clock_count + 1'b1;
	   end
	end
	
endmodule
