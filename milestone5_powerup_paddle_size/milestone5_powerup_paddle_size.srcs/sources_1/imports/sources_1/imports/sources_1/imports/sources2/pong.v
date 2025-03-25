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
    parameter GAME_UPDATE_DELAY = 3333333, // 30fps // 4166667, // 24 frames per second with a 100MHz clock
    parameter PADDLE_DISTANCE_FROM_EDGE = 20,
    parameter GAME_BORDER = 2
)(
    input clk,
    input resetn,
    input [1:0] user_dir,
    input [1:0] user_dir2,
    input [1:0] game_state,
    output reg [9:0] paddle1_x,
    output reg [9:0] paddle1_y,
    output reg [9:0] paddle2_x,
    output reg [9:0] paddle2_y,
    output reg [9:0] ball_x,
    output reg [9:0] ball_y,
    output wire [5:0] paddle1_height,
    output wire [5:0] paddle2_height,
    output wire [9:0] powerup_paddle_x,
    output wire [9:0] powerup_paddle_y,
    output wire powerup_paddle_spawn,
    output reg [9:0] score1,
    output reg [9:0] score2,
    output reg [1:0] player_won,
    output reg [31:0] update_game_counter,
    output reg update_game // expose how often the game is being updated for testing
    );
    
    
    // game state
    reg paddle1_ydir;
    reg paddle2_ydir;
    reg [9:0] ball_xspeed; // from 0 to +/- 7 where - is left, + is right
    reg [9:0] ball_yspeed; // from 0 to +/- 7 where - is up, + is down
    reg [9:0] paddle1_speed;
    reg [9:0] paddle2_speed;

    wire [9:0] ball_xspeed_abs; // manually 2's complement for some calculations
    assign ball_xspeed_abs = (ball_xspeed[9] == 1) ? (~ball_xspeed + 1) : ball_xspeed;
    
    
    powerup_paddle #(
        .GAME_WIDTH(GAME_WIDTH),
        .GAME_HEIGHT(GAME_HEIGHT),
        .PADDLE_WIDTH(PADDLE_WIDTH),
        .DEFAULT_PADDLE_HEIGHT(PADDLE_HEIGHT),
        .BALL_SIZE(BALL_SIZE),
        .PADDLE_DISTANCE_FROM_EDGE(PADDLE_DISTANCE_FROM_EDGE),
        .POWERUP_DURATION(480)
    ) powerup_paddle (
        .clk(clk),
        .resetn(resetn),
        .update_game(update_game),
        .ball_x(ball_x),
        .ball_y(ball_y),
        .ball_xspeed(ball_xspeed),
        .paddle1_height(paddle1_height),
        .paddle2_height(paddle2_height),
        .powerup_x(powerup_paddle_x),
        .powerup_y(powerup_paddle_y),
        .powerup_spawn(powerup_paddle_spawn)
    );
    
    
    // game update counter
    always@(posedge clk) begin
        if (!resetn) begin
            update_game_counter <= GAME_UPDATE_DELAY;
            update_game <= 0;
        end
        else if (game_state == 2'b01) begin
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
    
    // check if player won
    always@(posedge clk) begin
        if (!resetn) begin
            player_won <= 2'b00;
        end
        else begin
            if (score1 == 7) begin
                player_won <= 2'b01;
            end
            else if (score2 == 7) begin
                player_won <= 2'b10;
            end
        end
    end
    
    // paddle speed
    always@(posedge clk) begin
        if (!resetn) begin
            paddle1_speed <= 3;
            paddle2_speed <= 3;
        end
    end
    
    // update ball position and score
    always@(posedge clk) begin
        if (!resetn) begin
            ball_xspeed <= 4;
            ball_yspeed <= 1;
            ball_x <= GAME_WIDTH / 2;
            ball_y <= GAME_HEIGHT / 2;
            score1 <= 4;
            score2 <= 4;
        end
        else begin
            if (update_game) begin
                // x collision
                    // left wall
                if (ball_x <= 0 + GAME_BORDER) begin
                    score2 <= score2 + 1;
                    // reset ball after score
                    ball_xspeed <= ball_xspeed * -1;
                    ball_x <= paddle1_x + PADDLE_WIDTH + 2*BALL_SIZE; // reset on the left side going right
                    ball_y <= GAME_HEIGHT / 2;
                    ball_yspeed <= (ball_y[0] ? 1 : -1); // use this bit for pseudo-random
                end
                    // right wall
                else if (ball_x + BALL_SIZE >= GAME_WIDTH - 1 - GAME_BORDER) begin
                    score1 <= score1 + 1;
                    // reset ball after score
                    ball_xspeed <= ball_xspeed * -1;
                    ball_x <= paddle2_x - BALL_SIZE - 2*BALL_SIZE; // reset on the right side going left
                    ball_y <= GAME_HEIGHT / 2;
                    ball_yspeed <= (ball_y[0] ? 1 : -1); // use this bit for pseudo-random
                end
                    // left paddle
                else if ((ball_x < PADDLE_DISTANCE_FROM_EDGE + PADDLE_WIDTH)
                    && (ball_x >= PADDLE_DISTANCE_FROM_EDGE + PADDLE_WIDTH - ball_xspeed_abs) // because ball_xspeed negative here
                    && (ball_y + BALL_SIZE >= paddle1_y)
                    && (ball_y < paddle1_y + PADDLE_HEIGHT)) begin
                        ball_xspeed <= ball_xspeed * -1;
                        ball_x <= ball_x - ball_xspeed; // get away from paddle
                        // yspeed: which part of the paddle?
                        if (ball_y < paddle1_y - BALL_SIZE + (PADDLE_HEIGHT + BALL_SIZE)*1/8) begin
                            ball_yspeed <= -4;
                            ball_y <= ball_y - 4;
                        end
                        else if (ball_y < paddle1_y - BALL_SIZE + (PADDLE_HEIGHT + BALL_SIZE)*2/8) begin
                            ball_yspeed <= -3;
                            ball_y <= ball_y - 3;
                        end
                        else if (ball_y < paddle1_y - BALL_SIZE + (PADDLE_HEIGHT + BALL_SIZE)*3/8) begin
                            ball_yspeed <= -2;
                            ball_y <= ball_y - 2;
                        end
                        else if (ball_y < paddle1_y - BALL_SIZE + (PADDLE_HEIGHT + BALL_SIZE)*4/8) begin
                            ball_yspeed <= -1;
                            ball_y <= ball_y - 1;
                        end
                        else if (ball_y < paddle1_y - BALL_SIZE + (PADDLE_HEIGHT + BALL_SIZE)*5/8) begin
                            ball_yspeed <= 1;
                            ball_y <= ball_y + 1;
                        end
                        else if (ball_y < paddle1_y - BALL_SIZE + (PADDLE_HEIGHT + BALL_SIZE)*6/8) begin
                            ball_yspeed <= 2;
                            ball_y <= ball_y + 2;
                        end
                        else if (ball_y < paddle1_y - BALL_SIZE + (PADDLE_HEIGHT + BALL_SIZE)*7/8) begin
                            ball_yspeed <= 3;
                            ball_y <= ball_y + 3;
                        end
                        else if (ball_y < paddle1_y - BALL_SIZE + (PADDLE_HEIGHT + BALL_SIZE)*8/8) begin
                            ball_yspeed <= 4;
                            ball_y <= ball_y + 4;
                        end
                    end
                    // right paddle
                else if ((ball_x + BALL_SIZE >= GAME_WIDTH - 1 - (PADDLE_DISTANCE_FROM_EDGE + PADDLE_WIDTH))
                    && (ball_x + BALL_SIZE < GAME_WIDTH - 1 - (PADDLE_DISTANCE_FROM_EDGE + PADDLE_WIDTH) + ball_xspeed)
                    && (ball_y + BALL_SIZE >= paddle2_y)
                    && (ball_y < paddle2_y + PADDLE_HEIGHT)) begin
                        ball_xspeed <= ball_xspeed * -1;
                        ball_x <= ball_x - ball_xspeed; // get away from paddle
                        // yspeed: which part of the paddle?
                        if (ball_y < paddle2_y - BALL_SIZE + (PADDLE_HEIGHT + BALL_SIZE)*1/8) begin
                            ball_yspeed <= -4;
                            ball_y <= ball_y - 4;
                        end
                        else if (ball_y < paddle2_y - BALL_SIZE + (PADDLE_HEIGHT + BALL_SIZE)*2/8) begin
                            ball_yspeed <= -3;
                            ball_y <= ball_y - 3;
                        end
                        else if (ball_y < paddle2_y - BALL_SIZE + (PADDLE_HEIGHT + BALL_SIZE)*3/8) begin
                            ball_yspeed <= -2;
                            ball_y <= ball_y - 2;
                        end
                        else if (ball_y < paddle2_y - BALL_SIZE + (PADDLE_HEIGHT + BALL_SIZE)*4/8) begin
                            ball_yspeed <= -1;
                            ball_y <= ball_y - 1;
                        end
                        else if (ball_y < paddle2_y - BALL_SIZE + (PADDLE_HEIGHT + BALL_SIZE)*5/8) begin
                            ball_yspeed <= 1;
                            ball_y <= ball_y + 1;
                        end
                        else if (ball_y < paddle2_y - BALL_SIZE + (PADDLE_HEIGHT + BALL_SIZE)*6/8) begin
                            ball_yspeed <= 2;
                            ball_y <= ball_y + 2;
                        end
                        else if (ball_y < paddle2_y - BALL_SIZE + (PADDLE_HEIGHT + BALL_SIZE)*7/8) begin
                            ball_yspeed <= 3;
                            ball_y <= ball_y + 3;
                        end
                        else if (ball_y < paddle2_y - BALL_SIZE + (PADDLE_HEIGHT + BALL_SIZE)*8/8) begin
                            ball_yspeed <= 4;
                            ball_y <= ball_y + 4;
                        end
                    end
                else begin
                    ball_x <= ball_x + ball_xspeed;
                    // y collision
                        // top / bottom wall
                    if (ball_y + BALL_SIZE >= GAME_HEIGHT - 1 - GAME_BORDER || ball_y <= 0 + GAME_BORDER) begin
                        ball_yspeed <= ball_yspeed * -1;
                        ball_y <= ball_y - ball_yspeed;
                    end else begin
                        ball_y <= ball_y + ball_yspeed;
                    end
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
                        paddle1_y <= paddle1_y - paddle1_speed;
                    end
                end
                if (user_dir == 2'b01) begin // user wants to move down
                    // move if able
                    if (paddle1_y + PADDLE_HEIGHT < GAME_HEIGHT - 1) begin
                        paddle1_y <= paddle1_y + paddle1_speed;
                    end
                end
                
                // paddle 2
                if (user_dir2 == 2'b10) begin // user wants to move up
                    // move if able
                    if (paddle2_y > 0) begin
                        paddle2_y <= paddle2_y - paddle2_speed;
                    end
                end
                if (user_dir2 == 2'b01) begin // user wants to move down
                    // move if able
                    if (paddle2_y + PADDLE_HEIGHT < GAME_HEIGHT - 1) begin
                        paddle2_y <= paddle2_y + paddle2_speed;
                    end
                end
                
            end
        end
    end

    
endmodule
