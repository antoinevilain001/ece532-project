`timescale 1ns / 1ps

//////////////////////////////////////////////////////////////////////////////////
//
// calculates vga output given pong x and pong y signals
// 
//////////////////////////////////////////////////////////////////////////////////

module vga_bw#(
    parameter GAME_WIDTH = 640,
    parameter GAME_HEIGHT = 480,
    parameter PADDLE_WIDTH = 5,
    parameter PADDLE_HEIGHT = 10,
    parameter BALL_SIZE = 5,
    parameter GAME_UPDATE_DELAY = 4166667, // 24 frames per second with a 100MHz clock
    parameter PADDLE_DISTANCE_FROM_EDGE = 20,
    parameter BORDER_WIDTH = 1
)(
    input clk,          // 100 MHz clock from Nexys4 DDR
    input resetn,
    output hsync,   // Horizontal sync
    output vsync,   // Vertical sync
    output [3:0] vga_r, // Red (4-bit)
    output [3:0] vga_g, // Green (4-bit)
    output [3:0] vga_b,  // Blue (4-bit)
    input [9:0] ball_x,
    input [9:0] ball_y,
    input [9:0] paddle1_x,
    input [9:0] paddle1_y,
    input [9:0] paddle2_x,
    input [9:0] paddle2_y,
    input startgame,
    input gameover
);
    wire active;
    wire [9:0] x, y;
    wire [9:0] hcount, vcount;
    wire clk_25MHz;
    
    reg [1:0] game_state = 2'b00; // initialize to title screen upon boot
    localparam TITLE_SCREEN = 2'b00;
    localparam GAMEPLAY = 2'b01;
    localparam GAMEOVER = 2'b10;

    // Generate 25 MHz clock from 100 MHz input clock
    clock_divider clkdiv(.clk_in(clk), .clk_out(clk_25MHz));

    // VGA sync signal generator
    vga_sync vga(.clk(clk_25MHz), .resetn(resetn), .hsync(hsync), .vsync(vsync), .active(active), .x(hcount), .y(vcount));
    assign x = hcount;
    assign y = vcount;

    // the current positions
    wire [9:0] vball_x = ball_x;
    wire [9:0] vball_y = ball_y;
    wire [9:0] vpaddle1_x = paddle1_x;
    wire [9:0] vpaddle1_y = paddle1_y;
    wire [9:0] vpaddle2_x = paddle2_x;
    wire [9:0] vpaddle2_y = paddle2_y;
    
    wire border_left = (x == 0) || (x == 2);
    wire border_right = (x == GAME_WIDTH - 1) || (x == GAME_WIDTH - 3);
    wire border_top = (y == 0) || (y == 2);
    wire border_bottom = (y == GAME_HEIGHT - 1) || (y == GAME_HEIGHT - 3);
    wire border = border_left || border_right || border_bottom || border_top;
    //wire centerlines = (x == GAME_WIDTH >> 1) || (y == GAME_HEIGHT >> 1);
    
    wire vball = (x >= vball_x) && (x < vball_x + BALL_SIZE) && (y >= vball_y) && (y < vball_y + BALL_SIZE);
    wire vpaddle1 = (x >= vpaddle1_x) && (x < vpaddle1_x + PADDLE_WIDTH) && (y >= vpaddle1_y) && (y < vpaddle1_y + PADDLE_HEIGHT);
    wire vpaddle2 = (x >= vpaddle2_x) && (x < vpaddle2_x + PADDLE_WIDTH) && (y >= vpaddle2_y) && (y < vpaddle2_y + PADDLE_HEIGHT);
    
    //wire ball_trace = (x == ball_x) || (y == ball_y);
    //wire paddle1_trace = (x == paddle1_x) || (y == paddle1_y);
    //wire paddle2_trace = (x == paddle2_x) || (y == paddle2_y);
    
    //wire final_display = border || vball || vpaddle1 || vpaddle2 || ball_trace || paddle1_trace || paddle2_trace;
    wire game_display = border || vball || vpaddle1 || vpaddle2;
    
    // define title display
    wire letter_p = (x >= 130) && (x <= 140) && (y >= 100) && (y <= 220) ||
                    (x >= 141) && (x <= 175) && (y >= 100) && (y <= 110) ||
                    (x >= 166) && (x <= 210) && (y >= 111) && (y <= 121) ||
                    (x >= 200) && (x <= 210) && (y >= 122) && (y <= 165) ||
                    (x >= 141) && (x <= 199) && (y >= 155) && (y <= 165) ;
    
    wire letter_i = (x >= 240) && (x <= 250) && (y >= 100) && (y <= 220);
    
    wire letter_n = (x >= 280) && (x <= 290) && (y >= 100) && (y <= 220) ||
                    (x >= 291) && (x <= 310) && (y >= 105) && (y <= 115) ||
                    (x >= 300) && (x <= 310) && (y >= 116) && (y <= 138) ||
                    (x >= 311) && (x <= 330) && (y >= 128) && (y <= 138) ||
                    (x >= 320) && (x <= 330) && (y >= 139) && (y <= 164) ||
                    (x >= 331) && (x <= 345) && (y >= 154) && (y <= 164) ||
                    (x >= 335) && (x <= 345) && (y >= 165) && (y <= 190) ||
                    (x >= 346) && (x <= 360) && (y >= 180) && (y <= 190) ||
                    (x >= 350) && (x <= 360) && (y >= 191) && (y <= 210) ||
                    (x >= 361) && (x <= 379) && (y >= 200) && (y <= 210) ||
                    (x >= 380) && (x <= 390) && (y >= 100) && (y <= 220);
    
    wire letter_g = (x >= 420) && (x <= 500) && (y >= 100) && (y <= 110) ||
                    (x >= 420) && (x <= 430) && (y >= 111) && (y <= 220) ||
                    (x >= 431) && (x <= 500) && (y >= 210) && (y <= 220) ||
                    (x >= 490) && (x <= 500) && (y >= 165) && (y <= 209) ||
                    (x >= 460) && (x <= 489) && (y >= 165) && (y <= 175);
    
    wire title_display = border || letter_p || letter_i || letter_n || letter_g;
    
    
    // define gameover display
    wire letter_g_2 = (x >= 100) && (x <= 180) && (y >= 100) && (y <= 110) ||
                      (x >= 100) && (x <= 110) && (y >= 111) && (y <= 220) ||
                      (x >= 111) && (x <= 180) && (y >= 210) && (y <= 220) ||
                      (x >= 170) && (x <= 180) && (y >= 165) && (y <= 209) ||
                      (x >= 140) && (x <= 169) && (y >= 165) && (y <= 175);
    
    wire letter_a = (x >= 220) && (x <= 230) && (y >= 100) && (y <= 220) ||
                    (x >= 231) && (x <= 300) && (y >= 100) && (y <= 110) ||
                    (x >= 290) && (x <= 300) && (y >= 111) && (y <= 220) ||
                    (x >= 231) && (x <= 289) && (y >= 150) && (y <= 160);
    
    wire letter_m = (x >= 340) && (x <= 350) && (y >= 100) && (y <= 220) ||
                    (x >= 351) && (x <= 365) && (y >= 100) && (y <= 110) ||
                    (x >= 360) && (x <= 375) && (y >= 111) && (y <= 120) ||
                    (x >= 375) && (x <= 385) && (y >= 121) && (y <= 190) ||
                    (x >= 385) && (x <= 400) && (y >= 111) && (y <= 120) ||
                    (x >= 395) && (x <= 409) && (y >= 100) && (y <= 110) ||
                    (x >= 410) && (x <= 420) && (y >= 100) && (y <= 220);
    
    wire letter_e = (x >= 460) && (x <= 540) && (y >= 100) && (y <= 110) ||
                    (x >= 460) && (x <= 470) && (y >= 111) && (y <= 220) ||
                    (x >= 471) && (x <= 540) && (y >= 210) && (y <= 220) ||
                    (x >= 471) && (x <= 515) && (y >= 155) && (y <= 165);
    
    wire letter_o = (x >= 110) && (x <= 170) && (y >= 260) && (y <= 270) ||
                    (x >= 100) && (x <= 110) && (y >= 270) && (y <= 370) ||
                    (x >= 110) && (x <= 170) && (y >= 370) && (y <= 380) ||
                    (x >= 170) && (x <= 180) && (y >= 270) && (y <= 370);
    
    wire letter_v = (x >= 220) && (x <= 230) && (y >= 260) && (y <= 320) ||
                    (x >= 230) && (x <= 240) && (y >= 320) && (y <= 360) ||
                    (x >= 240) && (x <= 250) && (y >= 360) && (y <= 370) ||
                    (x >= 250) && (x <= 270) && (y >= 370) && (y <= 380) ||
                    (x >= 270) && (x <= 280) && (y >= 360) && (y <= 370) ||
                    (x >= 280) && (x <= 290) && (y >= 320) && (y <= 360) ||
                    (x >= 290) && (x <= 300) && (y >= 260) && (y <= 320);
    
    wire letter_e_2 = (x >= 340) && (x <= 420) && (y >= 260) && (y <= 270) ||
                      (x >= 340) && (x <= 350) && (y >= 271) && (y <= 380) ||
                      (x >= 351) && (x <= 420) && (y >= 370) && (y <= 380) ||
                      (x >= 351) && (x <= 395) && (y >= 315) && (y <= 325);
    
    wire letter_r = (x >= 460) && (x <= 470) && (y >= 260) && (y <= 380) ||
                    (x >= 471) && (x <= 530) && (y >= 260) && (y <= 270) ||
                    (x >= 530) && (x <= 540) && (y >= 270) && (y <= 320) ||
                    (x >= 471) && (x <= 530) && (y >= 320) && (y <= 330) ||
                    (x >= 510) && (x <= 520) && (y >= 330) && (y <= 345) ||
                    (x >= 520) && (x <= 530) && (y >= 345) && (y <= 360) ||
                    (x >= 530) && (x <= 540) && (y >= 360) && (y <= 380);
    
    wire over_display = border || letter_g_2 || letter_a || letter_m || letter_e || letter_o || letter_v || letter_e_2 || letter_r;
    
    // reset and state transition
    always @(posedge clk_25MHz or negedge resetn) begin
        if (~resetn)
            game_state <= TITLE_SCREEN;
        else begin
            case (game_state)
                TITLE_SCREEN: if (startgame) game_state <= GAMEPLAY;
                GAMEPLAY: if (gameover) game_state <= GAMEOVER;
                // GAMEOVER: no restart flag as of yet, just let reset button be reset
            endcase
        end
    end
    
    // change final display depending on game state
    wire final_display = (game_state == TITLE_SCREEN) ? title_display :
                         (game_state == GAMEPLAY) ? game_display :
                         (game_state == GAMEOVER) ? over_display : 1'b0;
    
    reg video;
    always @(posedge clk_25MHz) begin
        video <= final_display && active;  // Base condition: Only draw within the active display area
    end

    // Assign the same B&W signal to all color channels
    assign vga_r = video ? 4'b1111 : 4'b0000;
    assign vga_g = video ? 4'b1111 : 4'b0000;
    assign vga_b = video ? 4'b1111 : 4'b0000;
endmodule
