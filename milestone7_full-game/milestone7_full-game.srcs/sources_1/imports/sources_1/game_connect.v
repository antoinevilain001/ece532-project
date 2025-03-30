`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
//
// connects the pong game and vga output to the joystick input
// 
//////////////////////////////////////////////////////////////////////////////////


module game_connect (
    input clk,
    input SW0,
    input CALIBRATE,    // Calibration button for joystick
    output hsync,       // for VGA
    output vsync,       // for VGA
    output [3:0] vga_r,
    output [3:0] vga_g,
    output [3:0] vga_b,
    input MISO,         // SPI MISO from joystick
    output chip_select, // SPI Chip Select
    output MOSI,        // SPI MOSI
    output SCLK,        // SPI Clock
    input MISO2,
    output chip_select2,
    output MOSI2,
    output SCLK2,
    input pclk,         // USB port
    input pdata,        // USB port
    output [11:0] LED,  // LEDs
    output [7:0] AN,    // 7-segment anodes
    output [6:0] SEG,    // 7-segment cathodes
    input buttonD,      // secondary reset
    output [1:0]GPIO_0_tri_o, // sound
    input startgame,     // currently connected to down button, will potentially change
    input gameover      // currently connected to middle button, will connect to game over logic module later
);
    wire [1:0] user_dir;  // Direction output from joystick
    wire [1:0] user_dir_inverted;
    wire [1:0] user_dir2;
    wire [9:0] score1;
    wire [9:0] score2;
    wire [1:0] game_state;
    wire ball_x_dir;
    wire powerup_paddle_spawn;
    
    assign LED[9] = 1'b1;
    assign LED[11:10] = user_dir;
    assign LED[8:7] = user_dir2;
    
    assign user_dir = (user_dir_inverted == 2'b10 ? 2'b01 : user_dir_inverted == 2'b01 ? 2'b10 : 2'b00);
    
    wire spacebar_pressed;
    assign LED[6] = spacebar_pressed;
    wire r_pressed;
    assign LED[5] = r_pressed;
    
    wire resetn = !buttonD && !r_pressed;


    // Instantiate the joystick module
    joystick joystick_inst (
        .CLK(clk),
        .RST(!resetn), // uses active-high reset?
        .MISO(MISO),
        .chip_select(chip_select),
        .MOSI(MOSI),
        .SCLK(SCLK),
        .CALIBRATE(CALIBRATE),
        .user_dir(user_dir2)
    );
    
    joystick joystick_inst2 (
        .CLK(clk),
        .RST(!resetn), // uses active-high reset?
        .MISO(MISO2),
        .chip_select(chip_select2),
        .MOSI(MOSI2),
        .SCLK(SCLK2),
        .CALIBRATE(CALIBRATE),
        .user_dir(user_dir_inverted)
    );

    // Instantiate the game logic (top) module
    top #(
        .GAME_WIDTH(640),
        .GAME_HEIGHT(480),
        .PADDLE_WIDTH(10),
        .PADDLE_HEIGHT(50),
        .BALL_SIZE(10),
        .GAME_UPDATE_DELAY(4166667), // 24 FPS with 100MHz clock
        .PADDLE_DISTANCE_FROM_EDGE(100)
    ) top_inst (
        .clk(clk),
        .resetn(resetn),
        .user_dir(user_dir),
        .user_dir2(user_dir2),
        .hsync(hsync),
        .vsync(vsync),
        .vga_r(vga_r),
        .vga_g(vga_g),
        .vga_b(vga_b),
        .score1(score1),
        .score2(score2),
        .startgame(startgame || spacebar_pressed),
        .gameover(gameover),
        .powerup_paddle_spawn(powerup_paddle_spawn),
        .game_state(game_state),
        .ball_x_dir(ball_x_dir)
    );
    
    wire [9:0] disp_left = score1;
    wire [9:0] disp_right = score2;
    // Instantiate scoreboard
    seven_seg_disp scoreboard(
        .CLK(clk),
        .RST(!resetn),
        .x_pos(disp_left),
        .y_pos(disp_right),
        .AN(AN),
        .SEG(SEG)
    );
    
    keyboard keyboard_inst(
        .CLK(clk),
        .resetn(resetn),
        .pclk(pclk),
        .pdata(pdata),
        .spacebar_pressed(spacebar_pressed),
        .r_pressed(r_pressed)
    );
    
    
    //wire [1:0]GPIO_0_tri_o;
    wire [31:0]microblaze_input_tri_i;
    wire [15:0]microblaze_output_tri_o;
    wire reset;
    wire sys_clock;
    
    assign microblaze_input_tri_i[31] = SW0;
    assign microblaze_input_tri_i[0] = score1[0];
    assign microblaze_input_tri_i[1] = score2[0];
    assign microblaze_input_tri_i[3:2] = game_state;
    assign microblaze_input_tri_i[4] = ball_x_dir;
    assign microblaze_input_tri_i[5] = powerup_paddle_spawn;
    assign microblaze_input_tri_i[30:6] = 0;
    
    assign LED[0] = microblaze_output_tri_o[0];
    assign LED[1] = microblaze_output_tri_o[1];
    assign LED[3] = powerup_paddle_spawn;

    sound_wrapper sound_wrapper_inst(
        .GPIO_0_tri_o(GPIO_0_tri_o),
        .microblaze_input_tri_i(microblaze_input_tri_i),
        .microblaze_output_tri_o(microblaze_output_tri_o),
        .reset(!resetn),
        .sys_clock(clk)
    );

endmodule

