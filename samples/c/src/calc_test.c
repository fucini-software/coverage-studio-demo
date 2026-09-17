/**
 * @file calc_test.c
 * @brief The whole test suite of the C sample: one main() of assertions.
 *
 * What it leaves untested is deliberate, and is what the sample demonstrates;
 * each gap is documented on the function it belongs to, in calc.h, buffer.h
 * and sensor.h.
 *
 * Built whole by default. The generator's per-test option builds it three
 * more times, with TEST_CALC_ONLY, TEST_BUFFER_ONLY or TEST_SENSOR_ONLY
 * defined, so each part of the suite gets a coverage record of its own
 * (lcov @c TN:calc, @c TN:buffer and @c TN:sensor).
 *
 * @author Mario Fucini
 * @copyright Copyright (c) 2026 Fucini Consulting. Released under the MIT
 *            License; see the LICENSE file in the repository root.
 */
#include "calc.h"
#include "buffer.h"
#include "sensor.h"
#include <assert.h>

#if defined(TEST_CALC_ONLY) || defined(TEST_BUFFER_ONLY) || defined(TEST_SENSOR_ONLY)
/** @brief Defined when the build asked for one part of the suite only. */
#define TEST_ONE_PART 1
#endif

/**
 * @brief Run the suite, or the one part of it the build selected.
 * @return 0; a failed assertion aborts instead.
 */
int main(void) {
#if !defined(TEST_ONE_PART) || defined(TEST_CALC_ONLY)
    assert(add(2, 3) == 5);
    assert(subtract(5, 2) == 3);
    assert(classify(10) == 1);   /* only the positive path is exercised */
    /* Enough vectors to satisfy MC/DC for `(a && b) || c`: each condition is
       shown to change the outcome on its own, holding the others fixed. */
    assert(gate(1, 1, 0) == 1);  /* baseline true  */
    assert(gate(0, 1, 0) == 0);  /* a alone flips it */
    assert(gate(1, 0, 0) == 0);  /* b alone flips it */
    assert(gate(0, 0, 1) == 1);  /* c alone flips it */
    assert(gate(0, 0, 0) == 0);  /* all false       */
#endif

#if !defined(TEST_ONE_PART) || defined(TEST_BUFFER_ONLY)
    buffer_t b;
    buffer_init(&b, 2);
    assert(buffer_push(&b, 10) == 1);
    assert(buffer_push(&b, 20) == 1);
    assert(buffer_push(&b, 30) == 0);      /* refused: buffer full */
    assert(buffer_can_write(&b, 1) == 1);  /* only ever reached with force set */
#endif

#if !defined(TEST_ONE_PART) || defined(TEST_SENSOR_ONLY)
    assert(sensor_clamp(50, 0, 100) == 50);  /* inside the range */
    assert(sensor_clamp(-7, 0, 100) == 0);   /* below it; never above */

    int samples[1000];
    for (int i = 0; i < 1000; i++) {
        samples[i] = 20 + (i % 5);
    }
    assert(sensor_average(samples, 1000) == 22);  /* never null, never empty */

    assert(sensor_state(0) == SENSOR_OK);
    assert(sensor_state(1) == SENSOR_WARMUP);     /* never 2, never unknown */

    /* temp and pressure are each shown to decide the outcome alone; the
       alarm is never silenced, so `override` is never shown to matter. */
    assert(sensor_alarm(95, 1, 0) == 1);  /* temp alone raises it     */
    assert(sensor_alarm(20, 1, 0) == 0);  /* nothing raises it        */
    assert(sensor_alarm(20, 9, 0) == 1);  /* pressure alone raises it */

    assert(sensor_flush(0) == 0);         /* the queue is always empty */
#endif
    return 0;
}
