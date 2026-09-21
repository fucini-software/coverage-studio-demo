/**
 * @file thermostat.cpp
 * @brief Implementation of the thermostat declared in thermostat.hpp.
 *
 * @author Mario Fucini
 * @copyright Copyright (c) 2026 Fucini Consulting. Released under the MIT
 *            License; see the LICENSE file in the repository root.
 */
#include "thermostat.hpp"

/* Fully covered: inside, below and above. */
bool plausible(int tenths) {
    if (tenths < SENSOR_MIN) {
        return false;
    }
    if (tenths > SENSOR_MAX) {
        return false;
    }
    return true;
}

/* The frost arm never runs. Nobody ever leaves the house either, and no line
   here can show it: see thermostat.hpp. */
Demand decide(int tenths, int setpoint, bool occupied) {
    if (!plausible(tenths)) {
        return Demand::Fault;
    }
    if (tenths < FROST_LIMIT) {
        return Demand::Frost;
    }
    if (tenths >= setpoint || !occupied) {
        return Demand::Off;
    }
    return Demand::Heat;
}

/* Weekdays only: the last line is partially covered. */
int scheduled_setpoint(int hour, bool weekend) {
    if (hour < 6 || hour >= 22) {
        return 160;
    }
    return weekend ? 210 : 195;
}

/* A switch half tested. */
int max_burn_minutes(Demand demand) {
    switch (demand) {
    case Demand::Heat:
        return 45;
    case Demand::Frost:
        return 120;
    case Demand::Fault:
        return 0;
    default:
        return 0;
    }
}

/* Dead code. */
int factory_reset() {
    return 200;
}
