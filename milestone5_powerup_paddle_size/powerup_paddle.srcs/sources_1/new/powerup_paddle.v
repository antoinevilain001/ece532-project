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
    
    // wires and regs for control signals
    reg powerup_active;                 // powerup is in effect
    reg [9:0] powerup_timer;            // timer for how long powerup lasts
    reg [31:0] powerup_delay;           // randomize delay between powerup spawns
    
    // random LSFR, generates pseudo-random numbers
    reg [15:0] lfsr = 16'hACE1;
    always @(posedge clk) begin
        if (!resetn) lfsr <= 16'hACE1;
        else lfsr <= {lfsr[14:0], lfsr[15] ^ lfsr[13] ^ lfsr[5] ^ lfsr[2] ^ lfsr[8]};
    end
    
    // collision detection control signal
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
            powerup_delay <= 240; // + ($random % 240); turns out $random doesnt work, not synthesizable onto FPGA
            powerup_spawn <= 0;
        end
        else begin
            if (!powerup_active && !powerup_spawn) begin
                // state 1: nothing, base game, delay between powerup spawn
                if (powerup_delay == 0) begin
                    // transition to state 2 powerup spawned onto board
                    powerup_x <= lfsr[9:0] % (GAME_WIDTH - POWERUP_SIZE - PADDLE_DISTANCE_FROM_EDGE * 2 - 50);
                    powerup_y <= (lfsr[9:0] >> 1) % (GAME_HEIGHT - POWERUP_SIZE - 50); 
                    // generate powerup location using lfsr, note y is shifted by 1 to avoid x and y correlations
                    powerup_spawn <= 1;
                end 
                else begin
                    // state 1 powerup_delay not yet 0, so count down
                    powerup_delay <= powerup_delay - 1;
                end
            end
            
            if (powerup_spawn && collision) begin
                // transition to state 3 powerup is active
                powerup_active <= 1;
                powerup_spawn <= 0;
                powerup_timer <= 1;
                if (ball_xspeed > 0) begin
                    // ball is moving right, left player gets powerup
                    paddle1_height <= DEFAULT_PADDLE_HEIGHT * 2;
                    paddle2_height <= DEFAULT_PADDLE_HEIGHT / 2;
                end
                else begin
                    // ball is moving left, right player gets powerup
                    paddle1_height <= DEFAULT_PADDLE_HEIGHT / 2;
                    paddle2_height <= DEFAULT_PADDLE_HEIGHT * 2;
                end
            end
            
            if (powerup_active) begin
                if (powerup_timer < POWERUP_DURATION) begin
                    // state 3 powerup active, powerup_timer increasing
                    powerup_timer <= powerup_timer + 1;
                end
                else begin
                    // transition to state 1 reset to base game
                    powerup_active <= 0;
                    // powerup_spawn already set to 0 earlier
                    powerup_timer <= 0;
                    paddle1_height <= DEFAULT_PADDLE_HEIGHT;
                    paddle2_height <= DEFAULT_PADDLE_HEIGHT;
                    powerup_delay <= 240 + (lfsr[8:0] % 240); // 9 bits of LFSR means up to 512
                    // so technically 512 % 240, so powerup spawns will be more frequently 11~12s but thats ok
                end
            end
        end
    end

endmodule
