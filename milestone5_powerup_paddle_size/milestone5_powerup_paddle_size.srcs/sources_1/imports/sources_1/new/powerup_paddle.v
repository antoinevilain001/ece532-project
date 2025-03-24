`timescale 1ns / 1ps


module powerup_paddle #(
    parameter GAME_WIDTH = 640,
    parameter GAME_HEIGHT = 480,
    parameter PADDLE_WIDTH = 5,
    parameter DEFAULT_PADDLE_HEIGHT = 10,
    parameter BALL_SIZE = 5,
    parameter PADDLE_DISTANCE_FROM_EDGE = 20,
    parameter POWERUP_DURATION = 480,       // how long the powerup last for
    parameter POWERUP_SIZE = 3             // how large the powerup is on the game board, will look like a +
)(
    input clk,
    input resetn,
    input update_game,
    input [9:0] ball_x,
    input [9:0] ball_y,
    input [9:0] ball_xspeed,
    output reg [5:0] paddle1_height,
    output reg [5:0] paddle2_height,
    output reg [9:0] powerup_x,
    output reg [9:0] powerup_y,
    output reg powerup_spawn            // powerup is spawned onto board, VGA needs to display
);

    reg powerup_active;                 // powerup is in effect
    reg [9:0] powerup_timer;            // timer for how long powerup lasts
    reg [31:0] powerup_delay;           // randomize delay between powerup spawns
    
    initial begin
        paddle1_height = DEFAULT_PADDLE_HEIGHT;
        paddle2_height = DEFAULT_PADDLE_HEIGHT;
        powerup_active = 0;
        powerup_spawn = 0;
    end
    
    wire x_overlap = (ball_x + BALL_SIZE > powerup_x) && (ball_x < powerup_x + POWERUP_SIZE);
    wire y_overlap = (ball_y + BALL_SIZE > powerup_y) && (ball_y < powerup_y + POWERUP_SIZE);
    wire collision = x_overlap && y_overlap;
    
    // powerup implementation logic
    always @(posedge update_game) begin
        if (!resetn) begin
            powerup_active <= 0;
            powerup_timer <= 0;
            paddle1_height <= DEFAULT_PADDLE_HEIGHT;
            paddle2_height <= DEFAULT_PADDLE_HEIGHT;
            powerup_delay <= 10; //240 + ($random % 240);
        end
        else begin
            if (!powerup_active && !powerup_spawn && !powerup_delay) begin // spawn powerup if not active, not in use, and delay countdown finished 
                powerup_x <= 300; //$random % (GAME_WIDTH - POWERUP_SIZE - PADDLE_DISTANCE_FROM_EDGE - 50);
                powerup_y <= 300; //$random % (GAME_HEIGHT - POWERUP_SIZE - 50);
                powerup_spawn <= 1;
            end
            else if (powerup_spawn && collision) begin // powerup is on board and ball collides
                powerup_active <= 1;
                powerup_spawn <= 0;
                powerup_timer <= 1;
                if (ball_xspeed > 0) begin // ball moving right, so left player gets powerup
                    paddle1_height <= DEFAULT_PADDLE_HEIGHT * 2;
                    paddle2_height <= DEFAULT_PADDLE_HEIGHT / 2;
                end
                else begin // ball moving left, so right player gets powerup
                    paddle2_height <= DEFAULT_PADDLE_HEIGHT * 2;
                    paddle1_height <= DEFAULT_PADDLE_HEIGHT / 2;
                end
            end
        end
    end
    
    // powerup timer logic
    always @(posedge update_game) begin
        if (powerup_timer == POWERUP_DURATION) begin
            powerup_active <= 0;
            powerup_timer <= 0;
            paddle1_height <= DEFAULT_PADDLE_HEIGHT;
            paddle2_height <= DEFAULT_PADDLE_HEIGHT;
            powerup_delay <= 10; //240 + ( $random % 240 );   // wait 10 to 20 seconds before spawning next powerup
            
        end
        else if (powerup_timer > 0 && powerup_timer < POWERUP_DURATION) begin
            powerup_timer <= powerup_timer + 1;
        end
        else begin
            powerup_delay <= powerup_delay - 1;       // if powerup not active, start countdown to spawn next one
        end
    end

endmodule
