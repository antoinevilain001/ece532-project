`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/09/2025 02:54:11 PM
// Design Name: 
// Module Name: pong
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module pong #(
    parameter GAME_WIDTH = 210,
    parameter GAME_HEIGHT = 160,
    parameter PADDLE_WIDTH = 5,
    parameter PADDLE_HEIGHT = 10,
    parameter BALL_SIZE = 5,
    parameter GAME_UPDATE_DELAY = 4166667, // 24 frames per second with a 100MHz clock
    parameter PADDLE_DISTANCE_FROM_EDGE = 20
)(
    input clk,
    input resetn,
    input [1:0] user_dir,
    output reg [7:0] paddle1_x,
    output reg [7:0] paddle1_y,
    output reg [7:0] paddle2_x,
    output reg [7:0] paddle2_y,
    output reg [7:0] ball_x,
    output reg [7:0] ball_y,
    output reg [31:0] update_game_counter,
    output reg update_game // expose how often the game is being updated for testing
    );
    
    // game state
    reg paddle1_ydir;
    reg paddle2_ydir;
    reg [4:0] ball_xspeed; // from 0 to +/- 7 where - is left, + is right
    reg [4:0] ball_yspeed; // from 0 to +/- 7 where - is up, + is down
    //reg [31:0] update_game_counter;
    
    // game update counter
    always@(posedge clk) begin
        if (!resetn) begin
            update_game_counter <= GAME_UPDATE_DELAY;
            update_game <= 0;
        end
        else begin
            if (update_game_counter == 0) begin
                update_game_counter <= GAME_UPDATE_DELAY;
                update_game <= 1;
            end
            else begin
                update_game_counter <= update_game_counter - 1;
                update_game <= 0;
            end
        end
    end
    
    // update ball position
    always@(posedge clk) begin
        if (!resetn) begin
            ball_xspeed <= 1;
            ball_yspeed <= 0;
            ball_x <= GAME_WIDTH / 2;
            ball_y <= GAME_HEIGHT / 2;
        end
        else begin
            if (update_game) begin
                // collision detection
                if (ball_x > GAME_WIDTH || ball_x < 0) begin
                    ball_xspeed <= ball_xspeed * -1;
                end
                if (ball_y > GAME_HEIGHT || ball_y < 0) begin
                    ball_yspeed <= ball_yspeed * -1;
                end
                
                // update position
                ball_x <= ball_x + ball_xspeed;
                ball_y <= ball_y + ball_yspeed;
            end
        end
    end
    
    // update paddle position
    always@(posedge clk) begin
        if (!resetn) begin
            paddle1_x <= PADDLE_DISTANCE_FROM_EDGE;
            paddle2_x <= GAME_WIDTH - PADDLE_DISTANCE_FROM_EDGE;
            paddle1_y <= GAME_HEIGHT / 2;
            paddle2_y <= GAME_HEIGHT / 2;
        end
        else begin
            if (update_game) begin
                // paddle 1
                if (user_dir == 3) begin // user wants to move up
                    // move if able
                    if (paddle1_y > 0) begin
                        paddle1_y <= paddle1_y - 1;
                    end
                end
                if (user_dir == 1) begin // user wants to move down
                    // move if able
                    if (paddle1_y < GAME_HEIGHT) begin
                        paddle1_y <= paddle1_y + 1;
                    end
                end
                
                // paddle 2, perfect AI for the moment (center of paddle tracks ball)
                paddle2_y <= ball_y;
                
            end
        end
    end
    
endmodule
