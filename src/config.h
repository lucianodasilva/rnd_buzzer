#pragma once
#ifndef RND_BUZZER_CONFIG_H
#define RND_BUZZER_CONFIG_H

/* default prescaler is /8 therefore 8MHz becomes 1MHz */
#define F_CPU 1000000UL

#define BUZZER_DDR  DDRA
#define BUZZER_PORT PORTA
#define BUZZER_PIN  PA5

#include <inttypes.h>
#include <avr/io.h>
#include <avr/interrupt.h>
#include <util/delay.h>

#include "details.h"

namespace rnd_buzzer {

    constexpr uint32_t  CPU_CYCLES_PER_MS       (F_CPU / 1000);
    constexpr uint8_t   CPU_PRESCALER_BITS      (0b00000011); // default prescaler value (8)
    constexpr uint8_t   CPU_MAIN_CLOCK          (0); // main clock

    constexpr uint32_t  TIMER_PRESCALE_FACTOR   (1024);
    constexpr uint8_t   TIMER_PRESCALE_BITS     (bit_mask(CS00, CS02));

    constexpr uint32_t  TICK_DURATION_MS        { 60000 };
    //constexpr uint32_t  TICK_DURATION_MS        { 1000 };

    constexpr uint16_t  BUZZER_DURATION_MS      { 4000 };
    //constexpr uint16_t  BUZZER_DURATION_MS    { 250 };
    constexpr uint8_t   BUZZER_REPS             { 3 };

    constexpr uint8_t   WAIT_TICKS_UPPER        { 10 };
    constexpr uint8_t   WAIT_TICKS_LOWER        { 5 };

    constexpr uint32_t  TICK_DURATION_IN_TICKS  {(CPU_CYCLES_PER_MS * TICK_DURATION_MS) / TIMER_PRESCALE_FACTOR};
    constexpr uint16_t  TICKS_TO_OVERFLOW       { UINT16_MAX - TICK_DURATION_IN_TICKS };

    void init_clk();
    void init_gpio();
    void init_timer();
    void init_lowpower();

    inline void set_ticks_to_overflow() { TCNT0 = TICKS_TO_OVERFLOW; }
    void sleep();
}

#endif
