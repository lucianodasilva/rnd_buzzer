#include "config.h"
#include <avr/io.h>
#include <avr/interrupt.h>
#include <avr/sleep.h>

namespace rnd_buzzer {

    void init_clk() {
        // lift configuration change protection
        // clock select
        CCP = 0xD8;
        CLKMSR = CPU_MAIN_CLOCK;
        // lift configuration change protection
        // set prescaler
        CCP = 0xD8;
        CLKPSR = CPU_PRESCALER_BITS;
    }

    void init_gpio() {
        bit_set (BUZZER_DDR, BUZZER_PIN);
        bit_clear (BUZZER_PUE, BUZZER_PIN);
        bit_clear (BUZZER_PORT, BUZZER_PIN);
    }

    void init_timer() {
        TCCR0A = 0x00; // normal mode
        TCCR0B = TIMER_PRESCALE_BITS;

        // enable timer overflow interrupt
        TIMSK0 = bit_mask (TOIE0);

        set_ticks_to_overflow();

        // enable global interrupts
        sei();
    }

    void init_lowpower() {
        // set sleep mode to power-down and enable
        SMCR = bit_mask (0);

        // shutdown usart, timer/counter module, and adc
        PRR = bit_mask (2, 1);

        // shutdown watchdog
        WDTCSR = 0;
        bit_clear (RSTFLR, 3);

    }

    void sleep() {
        sei ();
        sleep_cpu();
    }

}