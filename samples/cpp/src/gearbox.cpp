/**
 * @file gearbox.cpp
 * @brief Implementation of the gear selection declared in gearbox.hpp.
 *
 * @author Mario Fucini
 * @copyright Copyright (c) 2026 Fucini Consulting. Released under the MIT
 *            License; see the LICENSE file in the repository root.
 */
#include "gearbox.hpp"

/**
 * @brief Limit a value to a range.
 * @tparam T Any type with @c < and @c >.
 * @param value The value to limit.
 * @param lo    Smallest allowed result.
 * @param hi    Largest allowed result.
 * @return @p value, or the bound it exceeded.
 * @note Instantiated twice, for @c int and for @c double. Only the @c int one
 *       ever runs, so instantiation coverage is 1 of 2: the template looks
 *       covered line by line, and one of the two functions the compiler made
 *       from it was never executed. Defined here rather than in the header so
 *       that its figures belong to this file, with all the others.
 */
template <typename T>
static T clamp_to(T value, T lo, T hi) {
    if (value < lo) {
        return lo;
    }
    return value > hi ? hi : value;
}

/* MC/DC 2 of 3: `manual` is never shown to matter. */
bool should_shift_up(int rpm, int throttle, bool manual) {
    if ((rpm > 3000 && throttle > 50) || manual) {
        return true;
    }
    return false;
}

/* Half-taken branch: the suite only ever shifts up. */
int next_gear(int current, bool up) {
    int wanted = up ? current + 1 : current - 1;
    return clamp_to<int>(wanted, 1, TOP_GEAR);
}

/* Never called: the double instantiation of clamp_to() never runs either. */
double fuel_ratio(int gear) {
    return clamp_to<double>(1.0 - gear * 0.12, 0.0, 1.0);
}

/* Dead code. */
int limp_home() {
    return 3;
}
