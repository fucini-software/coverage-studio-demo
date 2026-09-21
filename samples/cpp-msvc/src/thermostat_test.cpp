/**
 * @file thermostat_test.cpp
 * @brief The test suite of the MSVC sample: one main() of checks.
 *
 * No test framework and no standard-library include, as in the clang sample:
 * the report is then about this code and nothing else. What the suite leaves
 * untested is deliberate, and is documented on the function it belongs to, in
 * thermostat.hpp.
 *
 * @author Mario Fucini
 * @copyright Copyright (c) 2026 Fucini Consulting. Released under the MIT
 *            License; see the LICENSE file in the repository root.
 */
#include "thermostat.hpp"

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
    /* Inside the range, below it, above it. */
    CHECK(plausible(205));
    CHECK(!plausible(-900));
    CHECK(!plausible(1200));

    /* A broken sensor, a cold room, a warm one. Never a freezing one, and
       always with somebody home. */
    CHECK(decide(-900, 200, true) == Demand::Fault);
    CHECK(decide(180, 200, true) == Demand::Heat);
    CHECK(decide(215, 200, true) == Demand::Off);

    /* Night and day, and only ever on a weekday. */
    CHECK(scheduled_setpoint(3, false) == 160);
    CHECK(scheduled_setpoint(23, false) == 160);
    CHECK(scheduled_setpoint(12, false) == 195);

    /* What the suite above can produce, and nothing else. */
    CHECK(max_burn_minutes(Demand::Heat) == 45);
    CHECK(max_burn_minutes(Demand::Off) == 0);

    return 0;
}
