// pdm_serializer.v
// Verilog version of Digilent's PdmSer VHDL module
// Generates PWM audio for Nexys 4 DDR audio output

module pdm_serializer #(
    parameter integer C_NR_OF_BITS = 16,
    parameter integer C_SYS_CLK_FREQ_MHZ = 75,
    parameter integer C_PDM_FREQ_HZ = 2000000
)(
    input wire clk_i,             // System clock
    input wire en_i,              // Enable playback
    input wire [C_NR_OF_BITS-1:0] data_i, // Audio data
    output reg done_o,           // Done signal
    output wire pwm_audio_o      // PWM output to low-pass filter
);

    localparam integer CLK_DIV = (C_SYS_CLK_FREQ_MHZ * 1000000) / C_PDM_FREQ_HZ;

    reg [7:0] cnt_clk = 0;
    reg pdm_clk_rising = 0;
    reg [C_NR_OF_BITS-1:0] pdm_s_tmp = 0;
    reg [$clog2(C_NR_OF_BITS)-1:0] cnt_bits = 0;
    reg en_int = 0;

    // Simple 1-bit PWM: Z for 1, 0 for 0 (open-drain effect)
    assign pwm_audio_o = (pdm_s_tmp[C_NR_OF_BITS-1] == 1'b0) ? 1'b0 : 1'bz;

    // Sync enable input
    always @(posedge clk_i) begin
        en_int <= en_i;
    end

    // PDM Clock Divider
    always @(posedge clk_i) begin
        if (!en_int) begin
            cnt_clk <= 0;
            pdm_clk_rising <= 0;
        end else if (cnt_clk == CLK_DIV - 1) begin
            cnt_clk <= 0;
            pdm_clk_rising <= 1;
        end else begin
            cnt_clk <= cnt_clk + 1;
            pdm_clk_rising <= 0;
        end
    end

    // Bit counter
    always @(posedge clk_i) begin
        if (!en_int) begin
            cnt_bits <= 0;
        end else if (pdm_clk_rising) begin
            if (cnt_bits == C_NR_OF_BITS - 1)
                cnt_bits <= 0;
            else
                cnt_bits <= cnt_bits + 1;
        end
    end

    // Shift register and done signal
    always @(posedge clk_i) begin
        if (pdm_clk_rising) begin
            if (cnt_bits == 0)
                pdm_s_tmp <= data_i;
            else
                pdm_s_tmp <= {pdm_s_tmp[C_NR_OF_BITS-2:0], 1'b0};

            done_o <= (cnt_bits == C_NR_OF_BITS - 1);
        end else begin
            done_o <= 0;
        end
    end

endmodule