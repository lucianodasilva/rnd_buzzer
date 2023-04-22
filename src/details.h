#pragma once
#ifndef RND_BUZZER_DETAILS_H
#define RND_BUZZER_DETAILS_H

#include <inttypes.h>

namespace rnd_buzzer {

	template  < typename _t = uint8_t, typename ... _bits_tv >
	inline constexpr _t bit_mask (_bits_tv ... bits) {
		return ((_t{1} << (bits)) +...);
	}

	template < typename _t, typename ... _bits_tv >
	inline constexpr void bit_set (_t & var, _bits_tv ... bits) {
		((var = var | bit_mask < _t > (bits...)));
	}

	template < typename _t, typename ... _bits_tv >
	inline constexpr void bit_clear (_t & var, _bits_tv ... bits) {
		((var = var & (~bit_mask < _t > (bits...))));
	}

	template < typename _t, typename ... _bits_tv >
	inline constexpr void bit_toggle (_t & var, _bits_tv ... bits) {
		((var = var ^ (bit_mask < _t > (bits...))));
	}

	template < typename _t >
	inline constexpr bool bit_state (_t & var, uint8_t bit) {
		return var & bit_mask < _t > (bit);
	}

	template < typename _t >
	inline constexpr void bit_state_set (_t & var, uint8_t bit, bool state) {
		var = (var & ~bit_mask < _t > (bit)) | (state << bit);
	}

}

#endif
