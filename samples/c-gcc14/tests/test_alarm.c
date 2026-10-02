/**
 * @file test_alarm.c
 * @brief The alarm's tests: every decision both ways, not every condition.
 * @author Mario Fucini
 * @copyright Copyright (c) 2026 Fucini Consulting. Released under the MIT
 *            License; see the LICENSE file in the repository root.
 */
#include <stdio.h>
#include "../src/alarm.h"

static int failures = 0;

static void expect(const char *what, int got, int want)
{
    if (got != want) {
        printf("FAIL %s: got %d, want %d\n", what, got, want);
        failures++;
    }
}

int main(void)
{
    /* alarm_should_sound: sounds on smoke while armed, on a test, not on a quiet night. */
    expect("smoke while armed", alarm_should_sound(1, 1, 0), 1);
    expect("a test", alarm_should_sound(0, 0, 1), 1);
    expect("a quiet night", alarm_should_sound(0, 0, 0), 0);

    /* alarm_escalate: sustained smoke, heat, and neither. */
    expect("sustained smoke", alarm_escalate(1, 0, 0), 1);
    expect("heat", alarm_escalate(0, 1, 0), 1);
    expect("neither", alarm_escalate(0, 0, 0), 0);

    printf("%d failure(s)\n", failures);
    return failures == 0 ? 0 : 1;
}
