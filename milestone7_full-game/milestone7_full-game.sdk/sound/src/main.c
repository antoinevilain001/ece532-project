#include "xparameters.h"
#include "xgpio.h"
#include "xtmrctr.h"

#define GPIO_DEVICE_ID XPAR_AXI_GPIO_0_DEVICE_ID
#define TIMER_DEVICE_ID XPAR_AXI_TIMER_0_DEVICE_ID
#define PWM_GPIO_CHANNEL 1
#define AMP_GPIO_BIT 1

#define HALF_PERIOD_US 3500  // Half of 600Hz = ~833 microseconds

XGpio Gpio;
XTmrCtr Timer;

void delay_us(u32 us) {
    XTmrCtr_Reset(&Timer, 0);
    while (XTmrCtr_GetValue(&Timer, 0) < us * (XPAR_AXI_TIMER_0_CLOCK_FREQ_HZ / 1000000));
}

int main() {
    // Initialize GPIO and Timer
    XGpio_Initialize(&Gpio, GPIO_DEVICE_ID);
    XGpio_SetDataDirection(&Gpio, PWM_GPIO_CHANNEL, ~0x3); // lower 2 bits as output

    XTmrCtr_Initialize(&Timer, TIMER_DEVICE_ID);
    XTmrCtr_SetOptions(&Timer, 0, XTC_AUTO_RELOAD_OPTION);
    XTmrCtr_SetResetValue(&Timer, 0, 0);
    XTmrCtr_Start(&Timer, 0);

    // Enable amplifier
    XGpio_DiscreteWrite(&Gpio, PWM_GPIO_CHANNEL, (1 << AMP_GPIO_BIT));

    while (1) {
        // Toggle HIGH
        XGpio_DiscreteWrite(&Gpio, PWM_GPIO_CHANNEL, (1 << 0) | (1 << AMP_GPIO_BIT));
        delay_us(HALF_PERIOD_US);

        // Toggle LOW
        XGpio_DiscreteWrite(&Gpio, PWM_GPIO_CHANNEL, (0 << 0) | (1 << AMP_GPIO_BIT));
        delay_us(HALF_PERIOD_US);
    }

    return 0;
}
