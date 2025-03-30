#include "xparameters.h"
#include "xgpio.h"
#include "xtmrctr.h"
#include "notes.h"

#define GPIO_DEVICE_ID      XPAR_AXI_GPIO_0_DEVICE_ID
#define GPIO_INPUT_ID       XPAR_AXI_GPIO_1_DEVICE_ID
#define TIMER_DEVICE_ID     XPAR_AXI_TIMER_0_DEVICE_ID
#define PWM_GPIO_CHANNEL    1
#define AMP_GPIO_BIT        1

#define CLOCK_FREQ          XPAR_AXI_TIMER_0_CLOCK_FREQ_HZ
#define AMP_ENABLE_MASK     (1 << AMP_GPIO_BIT)
#define OUTPUT_HIGH_MASK    ((1 << 0) | AMP_ENABLE_MASK)
#define OUTPUT_LOW_MASK     AMP_ENABLE_MASK

XGpio Gpio;
XGpio Gpio1; // input
XGpio Gpio2; // output
XTmrCtr Timer;

/*
assign microblaze_input_tri_i[31] = SW0;
assign microblaze_input_tri_i[0] = score1[0];
assign microblaze_input_tri_i[1] = score2[0];
assign microblaze_input_tri_i[3:2] = game_state;
	localparam TITLE_SCREEN = 2'b00;
    localparam GAMEPLAY = 2'b01;
    localparam GAMEOVER = 2'b10;
assign microblaze_input_tri_i[4] = ball_x_dir;
assign microblaze_input_tri_i[5] = powerup_paddle_spawn;
assign microblaze_input_tri_i[30:6] = 0;
*/
#define SW0_MASK                (1U << 31)
#define SCORES_MASK             (3U << 0)  // Covers both score1[0] (bit 0) and score2[0] (bit 1)
#define GAME_STATE_MASK         (3U << 2)  // 2-bit field at bits [3:2]
#define BALL_X_DIR_MASK         (1U << 4)
#define POWERUP_PADDLE_SPAWN_MASK (1U << 5)

uint8_t sw0_saved;
uint8_t scores_saved;  // Lower 2 bits [1:0]
uint8_t game_state_saved;
uint8_t ball_x_dir_saved;
uint8_t powerup_paddle_spawn_saved;
uint8_t sw0;
uint8_t scores;  // Lower 2 bits [1:0]
uint8_t game_state;
uint8_t ball_x_dir;
uint8_t powerup_paddle_spawn;

// Extracting values from the 32-bit register
void read_register() {
	uint32_t reg = XGpio_DiscreteRead(&Gpio1, 1);
    sw0 = (reg & SW0_MASK) >> 31;
    scores = (reg & SCORES_MASK) >> 0;  // Lower 2 bits [1:0]
    game_state = (reg & GAME_STATE_MASK) >> 2;
    ball_x_dir = (reg & BALL_X_DIR_MASK) >> 4;
    powerup_paddle_spawn = (reg & POWERUP_PADDLE_SPAWN_MASK) >> 5;
}

void delay_us(u32 us) {
    XTmrCtr_Reset(&Timer, 0);
    while (XTmrCtr_GetValue(&Timer, 0) < us * (CLOCK_FREQ / 1000000));
}

void play_note(u32 freq, u32 duration_ms) {
    if (freq == REST) {
        delay_us(duration_ms * 1000);
        return;
    }

    u32 half_period_us = 1000000 / (2 * freq);
    u32 cycles = (duration_ms * 1000) / (2 * half_period_us);

    for (u32 i = 0; i < cycles; i++) {
        XGpio_DiscreteWrite(&Gpio, PWM_GPIO_CHANNEL, OUTPUT_HIGH_MASK);
        delay_us(half_period_us);
        XGpio_DiscreteWrite(&Gpio, PWM_GPIO_CHANNEL, OUTPUT_LOW_MASK);
        delay_us(half_period_us);
    }

    delay_us(1000); // slight gap
}

// ----------------------------
// Melodies
// ----------------------------
int theme_melody[] = {
    G3, G3, AS3, C4, G3, G3, F3, FS3, G3, G3, AS3, C4,
    G3, G3, F3, FS3, AS4, G4, D4, AS4, G4, CS4, AS4, G4, C4, AS3, C4
};
int theme_durations[] = {
    Q, Q, E, Q, Q, Q, Q, Q, Q, Q, E, Q,
    Q, Q, Q, Q, E, E, DH, E, E, DH, E, E, DH, E, Q
};

int score_melody[] = { AS3, C4, D4 };
int score_durations[] = { E, E, Q };

int go_melody[] = { AS4, G4, CS4 };
int go_durations[] = { E, E, H };

int bounce_melody[] = { AS4 };
int bounce_durations[] = { E };

// ----------------------------
// Melody playback
// ----------------------------
void play_melody(const int* melody, const int* durations, int length, int interruptible) {
    for (int i = 0; i < length; i++) {
        // If interruptible, check input
        if (interruptible) {
        	uint32_t reg = XGpio_DiscreteRead(&Gpio1, 1);
        	game_state = (reg & GAME_STATE_MASK) >> 2;
            if (game_state != 0)
                break; // interrupt theme if GPIO goes low
        }
        play_note(melody[i], durations[i]);
    }
}

int main() {
    // Init GPIOs and Timer
    XGpio_Initialize(&Gpio, XPAR_AXI_GPIO_0_DEVICE_ID);
    XGpio_Initialize(&Gpio1, XPAR_AXI_GPIO_1_DEVICE_ID);
    XGpio_Initialize(&Gpio2, XPAR_AXI_GPIO_2_DEVICE_ID);

    XGpio_SetDataDirection(&Gpio, PWM_GPIO_CHANNEL, ~0x3); // outputs
    XGpio_SetDataDirection(&Gpio1, 1, 0xFFFFFFFF);     // inputs
    XGpio_SetDataDirection(&Gpio2, 1, 0x0); // Outputs

    XTmrCtr_Initialize(&Timer, TIMER_DEVICE_ID);
    XTmrCtr_SetOptions(&Timer, 0, XTC_AUTO_RELOAD_OPTION);
    XTmrCtr_SetResetValue(&Timer, 0, 0);
    XTmrCtr_Start(&Timer, 0);

    XGpio_DiscreteWrite(&Gpio, PWM_GPIO_CHANNEL, AMP_ENABLE_MASK);

    while (1) {
        read_register();
        XGpio_DiscreteWrite(&Gpio2, 1, ball_x_dir); // for debugging to make sure it is read

        if (game_state == 0b00) {
            play_melody(theme_melody, theme_durations, sizeof(theme_melody)/sizeof(int), 1);
        }
        else if (game_state != game_state_saved && game_state == 0b10) {
			play_melody(go_melody, go_durations, sizeof(go_melody)/sizeof(int), 0);
		}
        else if (scores != scores_saved) {
            play_melody(score_melody, score_durations, sizeof(score_melody)/sizeof(int), 0);
        }
        else if (ball_x_dir != ball_x_dir_saved) {
            play_melody(bounce_melody, bounce_durations, sizeof(bounce_melody)/sizeof(int), 0);
        }

        sw0_saved = sw0;
        scores_saved = scores;  // Lower 2 bits [1:0]
        game_state_saved = game_state;
        ball_x_dir_saved = ball_x_dir;
        powerup_paddle_spawn_saved = powerup_paddle_spawn;

        delay_us(1e6);
    }

    return 0;
}
