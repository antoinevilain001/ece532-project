`timescale 1ns / 1ps

module pong_tb;

    // Parameters
    parameter GAME_WIDTH = 210;
    parameter GAME_HEIGHT = 160;
    parameter PADDLE_WIDTH = 5;
    parameter PADDLE_HEIGHT = 10;
    parameter BALL_SIZE = 5;
    parameter GAME_UPDATE_DELAY = 4; // testbench can update more frequently than visual game
    parameter PADDLE_DISTANCE_FROM_EDGE = 20;

    // Testbench signals
    reg clk;
    reg resetn;
    reg [1:0] user_dir;  // Direction for paddle movement (example: 1 for up, 0 for down)
    wire [7:0] paddle1_x;
    wire [7:0] paddle1_y;
    wire [7:0] paddle2_x;
    wire [7:0] paddle2_y;
    wire [7:0] ball_x;
    wire [7:0] ball_y;
    wire update_game;
    wire [31:0] update_game_counter;

    // Instantiate the pong module
    pong #(
        .GAME_WIDTH(GAME_WIDTH),
        .GAME_HEIGHT(GAME_HEIGHT),
        .PADDLE_WIDTH(PADDLE_WIDTH),
        .PADDLE_HEIGHT(PADDLE_HEIGHT),
        .BALL_SIZE(BALL_SIZE),
        .GAME_UPDATE_DELAY(GAME_UPDATE_DELAY),
        .PADDLE_DISTANCE_FROM_EDGE(PADDLE_DISTANCE_FROM_EDGE)
    ) uut (
        .clk(clk),
        .resetn(resetn),
        .user_dir(user_dir),
        .paddle1_x(paddle1_x),
        .paddle1_y(paddle1_y),
        .paddle2_x(paddle2_x),
        .paddle2_y(paddle2_y),
        .ball_x(ball_x),
        .ball_y(ball_y),
        .update_game(update_game),
        .update_game_counter(update_game_counter)
    );

    // Clock generation (100 MHz clock)
    always begin
        #5 clk = ~clk;  // Toggle clock every 5 ns to get 100 MHz
    end

    // Stimulus block
    initial begin
        // Initialize signals
        clk = 0;
        resetn = 1;
        user_dir = 0;  // Start with user moving down

        // Apply reset
        $display("Applying reset...");
        #10 resetn = 0;  // Release reset after 10 ns
        #10 resetn = 1;  // Assert reset after 10 ns to see reset behavior

        // Simulate some game updates
        #20 user_dir = 1;  // Move paddle 1 down (simulate user input)
        #50 user_dir = 0;  // Don't move paddle 1
        #100 user_dir = 1; // Move paddle 1 down again
        #50 user_dir = -1; // Move paddle 1 up

        // Wait for a few more clock cycles
        #200;

        // You can add further stimulus here to test different parts of the game
        $stop;  // Stop the simulation
    end

    // Monitor outputs for debugging
    initial begin
        $monitor("Time=%0t, paddle1_x=%d, paddle1_y=%d, paddle2_x=%d, paddle2_y=%d, ball_x=%d, ball_y=%d", 
                 $time, paddle1_x, paddle1_y, paddle2_x, paddle2_y, ball_x, ball_y);
    end

endmodule
