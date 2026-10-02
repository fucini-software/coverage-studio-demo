/**
 * @file alarm.c
 * @brief A smoke alarm's two decisions, for GCC 14's condition coverage.
 * @author Mario Fucini
 * @copyright Copyright (c) 2026 Fucini Consulting. Released under the MIT
 *            License; see the LICENSE file in the repository root.
 *
 * Branch coverage asks whether each decision went both ways. Condition
 * coverage, which gcc 14 measures with -fcondition-coverage, asks whether
 * each operand of the decision was seen true and seen false — and names the
 * one that never was. The suite in tests/test_alarm.c takes both decisions
 * both ways and still leaves one outcome of one operand in each unseen.
 */
#include "alarm.h"

int alarm_should_sound(int smoke, int armed, int testing)
{
    /* The tests never arm the alarm without smoke: `armed` is never seen false. */
    if ((smoke && armed) || testing) {
        return 1;
    }
    return 0;
}

int alarm_escalate(int sustained, int hot, int silenced)
{
    /* Nobody ever silences it: `silenced` is never seen true. */
    return (sustained || hot) && !silenced;
}
