`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Module Name: keyboard
// Project Name: keyboard_test
// Target Devices: Nexys 4 DDR
// Description: communicate to keyboard and output returned PS/2 scan codes
//              to the seven segment display (8 displays show most recent 4 bytes)
//////////////////////////////////////////////////////////////////////////////////


module keyboard(
    input CLK,
    input pclk,
    input pdata,
	input resetn,
    //output [6:0] SEG,
    //output [7:0] AN,
    //output DP,
    //output [15:0] LED
	
	// any flags triggered by keyboard inputs set as 1-bit flags
	// as such, in top-level can trigger on posedge (won't repeatedly speed up as flag held high)
	output game_speedup;
	output game_slowdown;
	// add more flags here as needed
    );
    
    wire [31:0] scancode;
	wire data_in;
    
    reg clk_div = 1'b0;
    reg CLK25MHZ = 0;
    always @(posedge CLK) begin
        clk_div <= clk_div + 1'b1;
        if (clk_div == 1'b1) CLK25MHZ <= ~CLK25MHZ;
    end
    
    PS2_controller keyboard_ctrl(
        .clk(CLK25MHZ),
        .pclk(pclk),
        .pdata(pdata),
		.data_valid(data_in),
        .keyout(scancode[31:0])
    );
    
    //seven_seg_disp display(
    //    .data(scancode[31:0]),
    //    .clk(CLK),
    //    .SEG(SEG[6:0]),
    //    .AN(AN[7:0]),
    //    .dp(DP)
    //);
    
    //assign LED[15:0] = scancode[15:0];
	
	// key assigned code, sent whenever pressed
	// if held down, sent repeatedly every 100 ms
	// on break F0 sent followed by released key scancode
	// wanted behaviour on make, send action ONCE 
	// e.g. holding W only increases game speed once, have to release to speed up again
	
	// possibilities
	// nothing yet 		88888888		do nothing
	// press W 			8888881D		trigger game flag
	// hold W			8888881D		do nothing (trigger game flag)
	// let go of W		88881DF0		do nothing
	// 					881DF01D		untrigger game flag
	// nothing pressed	881DF01D		do nothing (untrigger game flag)
	// press W again	1DF01D1D		trigger game flag again
	always @(posedge CLK) begin
		if (~resetn) begin
			game_speedup <= 0;
			game_slowdown <= 0;
			// add any new game flags here
		end
	end
	
	always @(posedge data_in) begin
		if (scancode[15:8] == 8'hF0) begin // break detected
			case (scancode[7:0]) begin
				8'h1D: game_speedup <= 1'b0;
				8'h1B: game_slowdown <= 1'b0;
				// add any new game flags here
				default:;
			endcase
		end
		else begin // no break, make input
			case (scancode[7:0]) 
				8'h1D: game_speedup <= 1'b1; 	// W: speed up
				8'h1B: game_slowdown <= 1'b1;	// S: speed down
				// add any new game flags here
				default:;
			endcase
		end
	end
	
	
	
	
	// ignore this FSM implementation, for base implementation not worrying about sustain input
	// implement as FSM with states: wait, make, sustain, break
	
	// parameter [1:0] Wait: 2'd0,
					// Make: 2'd1, 
					// Sustain: 2'd2,
					// Break: 2'd3;
					
	// reg [1:0] current_state = Wait;
	// reg [1:0] game_flags; 
	// // 0: speed down, 1: speed up
	
	// // trigger on data received from PS2 controller
	// always @(posedge data_in) begin
		// if (~resetn) begin
			// flags <= 2'b00;
			// current_state <= Wait;
		// end
		// else begin
			// case (current_state)
				// Wait: begin
					// if (scancode[7:0] == 8'h88) begin
						// current_state <= Wait; // 88 is initialized value (check PS2_controller.v)
					// end
					// else if (scancode[7:0] == scancode[23:16]) begin
						// current_state <= Wait; // happens after break, repeats scancode of released key
					// end
					// else begin
						// current_state <= Make;
					// end
				// end
				
				// Make: begin
					// case(scancode[15:8]) // set game flags (now in scancode[15:8])
						// 8'h1B: game_flags <= 2'b01; // S: speed down
						// 8'h1D: game_flags <= 2'b10; // W: speed up
						// // any additional ones go here
						// default: game_flags <= game_flags;
					// endcase
					// if (scancode[7:0] == scancode[15:8]) begin
						// current_state <= Sustain;
					// end
					// else if (scancode[7:0] == 8'hF0) begin
						// current_state <= Break;
					// end
					// else begin
						// // this should never be reached, but just in case
						// current_state <= Make; 
					// end
					
				// end
				
				// Sustain: begin
					// game_flags <= 2'b00; // ensure game flags only high for one cycle
					// // except this FSM clock is data_in signal, so might need additional
					// // synch in game logic module
					// if (scancode[7:0] == 8'hF0) begin
						// current_state <= Break;
					// end
					// else begin
						// current_state <= Sustain;
					// end
				// end
				
				// Break: begin
					// game_flags <= 2'b00; // ensure game flags only high for one cycle (if not sustain)
					
				// end
				
				// default: current_state <= Wait;
				
			// endcase
		// end
	// end
	
	
    
endmodule
