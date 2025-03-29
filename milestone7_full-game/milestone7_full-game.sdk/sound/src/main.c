#include "xparameters.h"
#include "xgpio.h"
#include "xtmrctr.h"
#include "stdio.h"

#define TIMER_DEVICE_ID XPAR_AXI_TIMER_0_DEVICE_ID
#define PWM_GPIO_CHANNEL 1
#define AMP_GPIO_BIT 1

#define AMP_ENABLE_MASK (1 << AMP_GPIO_BIT)
#define OUTPUT_HIGH_MASK (1 << 0) | AMP_ENABLE_MASK
#define OUTPUT_LOW_MASK  AMP_ENABLE_MASK

#define NOTE_DURATION_MS 150  // Quarter note ~120 BPM
#define CLOCK_FREQ XPAR_AXI_TIMER_0_CLOCK_FREQ_HZ

XGpio Gpio;
XGpio Gpio1;
XGpio Gpio2;

XTmrCtr Timer;

void delay_us(u32 us) {
    XTmrCtr_Reset(&Timer, 0);
    while (XTmrCtr_GetValue(&Timer, 0) < us * (CLOCK_FREQ / 1000000));
}

void play_square_wave(u32 frequency_hz, u32 duration_ms) {
    u32 half_period_us = 1000000 / (2 * frequency_hz);
    u32 cycles = (duration_ms * 1000) / (2 * half_period_us);

    for (u32 i = 0; i < cycles; i++) {
        // HIGH
        XGpio_DiscreteWrite(&Gpio, PWM_GPIO_CHANNEL, OUTPUT_HIGH_MASK);
        delay_us(half_period_us);

        // LOW
        XGpio_DiscreteWrite(&Gpio, PWM_GPIO_CHANNEL, OUTPUT_LOW_MASK);
        delay_us(half_period_us);
    }
}

int main() {
    XGpio_Initialize(&Gpio, XPAR_AXI_GPIO_0_DEVICE_ID);
    XGpio_Initialize(&Gpio1, XPAR_AXI_GPIO_1_DEVICE_ID);
    XGpio_Initialize(&Gpio2, XPAR_AXI_GPIO_2_DEVICE_ID);
    XGpio_SetDataDirection(&Gpio2, 1, 0x0); // Outputs
    XGpio_SetDataDirection(&Gpio1, 1, 0x1); // Input
    XGpio_SetDataDirection(&Gpio, PWM_GPIO_CHANNEL, ~0x3); // GPIO[0:1] as outputs

    // Write to lights
    XGpio_DiscreteWrite(&Gpio2, 1, 0x3);

    XTmrCtr_Initialize(&Timer, TIMER_DEVICE_ID);
    XTmrCtr_SetOptions(&Timer, 0, XTC_AUTO_RELOAD_OPTION);
    XTmrCtr_SetResetValue(&Timer, 0, 0);
    XTmrCtr_Start(&Timer, 0);

    // Enable amplifier
    XGpio_DiscreteWrite(&Gpio, PWM_GPIO_CHANNEL, AMP_ENABLE_MASK);

    while (1) {
    		play_square_wave(196, 400);   // G3
    	    play_square_wave(233, 400);   // Bb3
    	    play_square_wave(261, 400);   // C4
    	    play_square_wave(196, 400);   // G3
    	    play_square_wave(233, 400);   // Bb3
    	    play_square_wave(277, 400);   // Db4
    	    play_square_wave(261, 800);   // C4

    	    delay_us(300000); // brief rest (300ms)

    	    play_square_wave(196, 400);   // G3
    	    play_square_wave(233, 400);   // Bb3
    	    play_square_wave(261, 400);   // C4
    	    play_square_wave(233, 400);   // Bb3
    	    play_square_wave(196, 800);   // G3

    	    delay_us(500000); // rest before repeat
    }

    return 0;
}
