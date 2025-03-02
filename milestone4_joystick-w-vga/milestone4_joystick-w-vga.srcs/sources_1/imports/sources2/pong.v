`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
//
// defines the game logic for the pong game
// updates the game only once every GAME_UPDATE_DELAY clock cycles
// 
//////////////////////////////////////////////////////////////////////////////////


module pong #(
    parameter GAME_WIDTH = 640,
    parameter GAME_HEIGHT = 480,
    parameter PADDLE_WIDTH = 5,
    parameter PADDLE_HEIGHT = 10,
    parameter BALL_SIZE = 5,
    parameter GAME_UPDATE_DELAY = 4166667, // 24 frames per second with a 100MHz clock
    parameter PADDLE_DISTANCE_FROM_EDGE = 20,
    parameter GAME_BORDER = 2
)(
    input clk,
    input resetn,
    input [1:0] user_dir,
    output reg [9:0] paddle1_x,
    output reg [9:0] paddle1_y,
    output reg [9:0] paddle2_x,
    output reg [9:0] paddle2_y,
    output reg [9:0] ball_x,
    output reg [9:0] ball_y,
    output reg [9:0] score1,
    output reg [9:0] score2,
    output reg [31:0] update_game_counter,
    output reg update_game // expose how often the game is being updated for testing
    );
    
    // game state
    reg paddle1_ydir;
    reg paddle2_ydir;
    reg [9:0] ball_xspeed; // from 0 to +/- 7 where - is left, + is right
    reg [9:0] ball_yspeed; // from 0 to +/- 7 where - is up, + is down
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
            ball_xspeed <= 2;
            ball_yspeed <= 1;
            ball_x <= GAME_WIDTH / 2;
            ball_y <= GAME_HEIGHT / 2;
        end
        else begin
            if (update_game) begin
                // x collision
                    // left / right wall
                if (ball_x + BALL_SIZE >= GAME_WIDTH - 1 - GAME_BORDER || ball_x <= 0 + GAME_BORDER) begin
                    ball_xspeed <= ball_xspeed * -1;
                    ball_x <= ball_x - ball_xspeed; // get away from border
                end
                    // left paddle
                else if ((ball_x < PADDLE_DISTANCE_FROM_EDGE + PADDLE_WIDTH)
                    && (ball_x >= PADDLE_DISTANCE_FROM_EDGE)
                    && (ball_y + BALL_SIZE >= paddle1_y)
                    && (ball_y < paddle1_y + PADDLE_HEIGHT)) begin
                        ball_xspeed <= ball_xspeed * -1;
                        ball_x <= ball_x - ball_xspeed; // get away from paddle
                    end
                    // right paddle
                else if ((ball_x + BALL_SIZE >= GAME_WIDTH - 1 - (PADDLE_DISTANCE_FROM_EDGE + PADDLE_WIDTH))
                    && (ball_x + BALL_SIZE < GAME_WIDTH - 1 - PADDLE_DISTANCE_FROM_EDGE)
                    && (ball_y + BALL_SIZE >= paddle2_y)
                    && (ball_y < paddle2_y + PADDLE_HEIGHT)) begin
                        ball_xspeed <= ball_xspeed * -1;
                        ball_x <= ball_x - ball_xspeed; // get away from paddle
                    end
                else begin
                    ball_x <= ball_x + ball_xspeed;
                end
                
                
                // y collision
                    // top / bottom wall
                if (ball_y + BALL_SIZE >= GAME_HEIGHT - 1 - GAME_BORDER || ball_y <= 0 + GAME_BORDER) begin
                    ball_yspeed <= ball_yspeed * -1;
                    ball_y <= ball_y - ball_yspeed;
                end
                else begin
                    ball_y <= ball_y + ball_yspeed;
                end
                
            end
        end
    end
    
    // update paddle position
    always@(posedge clk) begin
        if (!resetn) begin
            paddle1_x <= PADDLE_DISTANCE_FROM_EDGE;
            paddle2_x <= GAME_WIDTH - PADDLE_DISTANCE_FROM_EDGE - PADDLE_WIDTH;
            paddle1_y <= GAME_HEIGHT / 2;
            paddle2_y <= GAME_HEIGHT / 2;
        end
        else begin
            if (update_game) begin
                // paddle 1
                if (user_dir == 2'b10) begin // user wants to move up
                    // move if able
                    if (paddle1_y > 0) begin
                        paddle1_y <= paddle1_y - 1;
                    end
                end
                if (user_dir == 2'b01) begin // user wants to move down
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
    
    // score counter
    always @(posedge clk) begin
        if (!resetn) begin
            score1 <= 0;
            score2 <= 0;
        end else begin
            score1 <= ball_x;
            score2 <= ball_y;
        end
    end
    
endmodule
