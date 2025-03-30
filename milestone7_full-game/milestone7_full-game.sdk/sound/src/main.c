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
            int val = XGpio_DiscreteRead(&Gpio1, 1);
            if (val == 0)
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
        int gpio_val = XGpio_DiscreteRead(&Gpio1, 1);
        XGpio_DiscreteWrite(&Gpio2, 1, gpio_val);

        if (gpio_val == 0b0001) {
            play_melody(theme_melody, theme_durations, sizeof(theme_melody)/sizeof(int), 1);
        }
        else if (gpio_val == 0b0010) {
            play_melody(score_melody, score_durations, sizeof(score_melody)/sizeof(int), 0);
        }
        else if (gpio_val == 0b0100) {
            play_melody(go_melody, go_durations, sizeof(go_melody)/sizeof(int), 0);
        }
        else if (gpio_val == 0b1000) {
            play_melody(bounce_melody, bounce_durations, sizeof(bounce_melody)/sizeof(int), 0);
        }

        delay_us(1e6);
    }

    return 0;
}
