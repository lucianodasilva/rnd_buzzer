#include "config.h"
#include "details.h"

namespace rnd_buzzer {

    uint16_t trigger_ticks {0};

    uint16_t xorshift();

    uint8_t next_wait_time() {
        constexpr uint16_t wait_range{WAIT_TICKS_UPPER - WAIT_TICKS_LOWER + 1};
        return static_cast < uint8_t > (xorshift() % wait_range) + WAIT_TICKS_LOWER;
    }

    void play_buzz_sequence() {
//        for (int i = 0; i < BUZZER_REPS; ++i) {
//            if (i != 0) {
//                _delay_ms(BUZZER_DURATION_MS);
//            }
//
//            bit_clear(BUZZER_PORT, BUZZER_PIN);
//            _delay_ms(BUZZER_DURATION_MS);
//            bit_set(BUZZER_PORT, BUZZER_PIN);
//        }
        bit_set(BUZZER_PORT, BUZZER_PIN);
        _delay_ms(BUZZER_DURATION_MS);
        bit_clear(BUZZER_PORT, BUZZER_PIN);
    }

    void next_tick_sequence() {
        trigger_ticks = next_wait_time();
        set_ticks_to_overflow();
    }
}

// use timer 0 overflow as "ticker"
ISR(TIM0_OVF_vect) {
    using namespace rnd_buzzer;
    --trigger_ticks;

    // trigger not reached yet
    if (trigger_ticks > 0) {
        set_ticks_to_overflow();
        return;
    }

    // disable interrupts, just in case
    cli ();
    play_buzz_sequence();
    next_tick_sequence();
    sei ();
}

int main () {
    using namespace rnd_buzzer;

    init_clk();
    init_gpio();
    init_timer();
    init_lowpower();

    next_tick_sequence();

    while(true) {
        rnd_buzzer::sleep();
    }
}