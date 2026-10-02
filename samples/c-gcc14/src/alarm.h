/**
 * @file alarm.h
 * @brief A smoke alarm's two decisions, for GCC 14's condition coverage.
 * @author Mario Fucini
 * @copyright Copyright (c) 2026 Fucini Consulting. Released under the MIT
 *            License; see the LICENSE file in the repository root.
 */
#ifndef ALARM_H
#define ALARM_H

/** Whether the alarm sounds: smoke while armed, or a test in progress. */
int alarm_should_sound(int smoke, int armed, int testing);

/** Whether the brigade is called: sustained smoke or heat, unless silenced. */
int alarm_escalate(int sustained, int hot, int silenced);

#endif
