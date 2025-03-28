#include "xgpio.h"
#include "xparameters.h"
#include "xil_io.h"
#include <unistd.h>
#include <stdint.h>
#include "wav_data.h"  // New high-quality audio header

#define GPIO_DEVICE_ID XPAR_AXI_GPIO_0_DEVICE_ID
#define PWM_PIN_MASK 0x01
#define SAMPLE_RATE_HZ 32000
#define SAMPLE_DELAY_US (1000000 / SAMPLE_RATE_HZ)

XGpio gpio;

void pwm_write(uint8_t duty) {
    for (int i = 0; i < 256; i++) {
        if (i < duty)
            XGpio_DiscreteWrite(&gpio, 1, PWM_PIN_MASK);  // HIGH
        else
            XGpio_DiscreteWrite(&gpio, 1, 0);              // LOW
    }
}

int main() {
    XGpio_Initialize(&gpio, GPIO_DEVICE_ID);
    XGpio_SetDataDirection(&gpio, 1, 0x00);  // Output

    while (1) {
        for (int i = 0; i < WAV_DATA_LEN; i++) {
            pwm_write(wav_data[i]);
            usleep(SAMPLE_DELAY_US);  // ~32 kHz sample rate
        }

        usleep(2000000); // Wait 2 seconds before repeating
    }

    return 0;
}
