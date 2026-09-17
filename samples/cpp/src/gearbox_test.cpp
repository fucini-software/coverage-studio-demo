/**
 * @file gearbox_test.cpp
 * @brief The test suite of the C++ sample: one main() of checks.
 *
 * No test framework and no standard-library include, so the sample builds with
 * a bare compiler. What the suite leaves untested is deliberate, and is
 * documented on the function it belongs to, in gearbox.hpp.
 *
 * @author Mario Fucini
 * @copyright Copyright (c) 2026 Fucini Consulting. Released under the MIT
 *            License; see the LICENSE file in the repository root.
 */
#include "gearbox.hpp"

/** @brief Fail the run, naming the line, when a check does not hold. */
#define CHECK(condition) \
    do {                 \
        if (!(condition)) return __LINE__; \
    } while (false)

/**
 * @brief Run every check.
 * @return 0 when all hold, otherwise the line of the first that does not.
 */
int main() {
    /* rpm and throttle are each shown to decide the outcome alone; the driver
       never asks for a shift, so `manual` is never shown to matter. */
    CHECK(should_shift_up(3500, 80, false));   /* both high: shift        */
    CHECK(!should_shift_up(2000, 80, false));  /* rpm alone flips it      */
    CHECK(!should_shift_up(3500, 20, false));  /* throttle alone flips it */

    /* Only ever up, and once into the limiter: TOP_GEAR stays TOP_GEAR. */
    CHECK(next_gear(2, true) == 3);
    CHECK(next_gear(TOP_GEAR, true) == TOP_GEAR);

    return 0;
}
