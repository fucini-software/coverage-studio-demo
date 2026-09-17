/**
 * @file sensor.c
 * @brief Implementation of the sensor conditioning functions in sensor.h.
 *
 * @author Mario Fucini
 * @copyright Copyright (c) 2026 Fucini Consulting. Released under the MIT
 *            License; see the LICENSE file in the repository root.
 */
#include "sensor.h"

/* Covered line, uncovered region: the `hi` arm never runs. */
int sensor_clamp(int value, int lo, int hi) {
    return value < lo ? lo : (value > hi ? hi : value);
}

/* A defensive guard that never fires, then the hot loop. */
int sensor_average(const int *samples, int count) {
    if (samples == 0 || count <= 0) {
        return 0;
    }
    long sum = 0;
    for (int i = 0; i < count; i++) {
        sum += samples[i];
    }
    return (int)(sum / count);
}

/* The default is the path nobody tests. */
sensor_state_t sensor_state(int code) {
    switch (code) {
        case 0:
            return SENSOR_OK;
        case 1:
            return SENSOR_WARMUP;
        case 2:
            return SENSOR_DEGRADED;
        default:
            return SENSOR_FAULT;
    }
}

/* MC/DC 2 of 3: `override` is never shown to matter. */
int sensor_alarm(int temp, int pressure, int override) {
    if ((temp > 90 || pressure > 8) && !override) {
        return 1;
    }
    return 0;
}

/* Called, but never with anything queued: the loop body never runs. */
int sensor_flush(int pending) {
    int discarded = 0;
    for (int i = 0; i < pending; i++) {
        discarded++;
    }
    return discarded;
}
