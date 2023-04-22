#include "details.h"
#include <avr/io.h>

namespace rnd_buzzer {

    /**
     * @brief Seed the xorshift random number generator with the ADC floating pin noise.
     * @return The seed value.
     */
    uint16_t xorshift_adc_seed() {
        // internal 1.1v reference
        ADMUX = bit_mask(REFS1);

        // clear settings
        ADCSRA = 0;

        // enable adc converter
        bit_set (ADCSRA, ADEN);

        uint16_t seed = 0;
        auto * seed_byte_ptr = reinterpret_cast < uint8_t * > (&seed);

        // start conversion
        bit_set (ADCSRA, ADSC);
        // wait for the conversion to complete
        loop_until_bit_is_set(ADCSRA, ADIF);

        seed_byte_ptr [0] = ADCL;
        seed_byte_ptr [1] = ADCH;

        // clear settings and disable
        ADCSRA = 0;

        return seed;
    }

    namespace {
        uint16_t xorshift_state = 1;
    }

    /**
     * @brief Generate a random number using the xorshift algorithm.
     * @return The random number.
     */
    uint16_t xorshift (){
        xorshift_state ^= xorshift_state << 7;
        xorshift_state ^= xorshift_state >> 9;
        xorshift_state ^= xorshift_state << 13;

        return xorshift_state;
    }

}