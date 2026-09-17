/**
 * @file sensor.h
 * @brief Sensor conditioning: five functions, five different coverage findings.
 *
 * calc.h and buffer.h show the states a report can be in. This module shows
 * the findings that hide inside code every metric but one calls healthy: an
 * arm of a ternary that never ran on a line that did, a defensive guard that
 * never fired, a loop that was never entered, a @c switch nobody tested the
 * fallback of, and a decision whose MC/DC is two thirds proven.
 *
 * @author Mario Fucini
 * @copyright Copyright (c) 2026 Fucini Consulting. Released under the MIT
 *            License; see the LICENSE file in the repository root.
 */
#ifndef SENSOR_H
#define SENSOR_H

/** @brief Operating state reported for a raw status code. */
typedef enum {
    SENSOR_OK = 0,      /**< Normal operation. */
    SENSOR_WARMUP = 1,  /**< Powered, not yet stable. */
    SENSOR_DEGRADED = 2,/**< Working outside its calibrated range. */
    SENSOR_FAULT = 3    /**< Unknown or failed; the safe assumption. */
} sensor_state_t;

/**
 * @brief Limit a reading to a range.
 * @param value The raw reading.
 * @param lo    Smallest allowed result.
 * @param hi    Largest allowed result.
 * @return @p value, or the bound it exceeded.
 * @note One line, three outcomes. The suite passes a value inside the range
 *       and one below it, never one above: the line is covered, and the
 *       @p hi arm of the inner ternary is a region that never ran. Only a
 *       format with columns (llvm-cov JSON) can show that.
 */
int sensor_clamp(int value, int lo, int hi);

/**
 * @brief Mean of a series of readings.
 * @param samples The readings; may be null.
 * @param count   How many readings @p samples holds.
 * @return The integer mean, or 0 when there is nothing to average.
 * @note The guard for a null or empty series never fires in the suite, so its
 *       @c return is uncovered and its decision half taken. The loop is the
 *       hot one: look at its hit count.
 */
int sensor_average(const int *samples, int count);

/**
 * @brief Translate a raw status code into an operating state.
 * @param code Status code as the device reports it.
 * @return The matching state, or #SENSOR_FAULT for a code this driver does not know.
 * @note Two of the three cases are tested, and the @c default never is: the
 *       fallback for unknown codes is exactly the path nobody thinks to test.
 */
sensor_state_t sensor_state(int code);

/**
 * @brief Whether to raise the alarm: <tt>(temp > 90 || pressure > 8) && !override</tt>.
 * @param temp     Temperature in degrees Celsius.
 * @param pressure Pressure in bar.
 * @param override Non-zero while an operator has silenced the alarm.
 * @retval 1 Raise the alarm.
 * @retval 0 Stay quiet.
 * @note MC/DC 2 of 3, on purpose. The suite shows @p temp and @p pressure each
 *       deciding the outcome alone, and never silences the alarm, so
 *       @p override is not proven to matter. Compare gate() (3 of 3) and
 *       buffer_can_write() (0 of 3).
 */
int sensor_alarm(int temp, int pressure, int override);

/**
 * @brief Discard readings that are still queued.
 * @param pending How many readings are queued.
 * @return How many were discarded.
 * @note Called, and covered at function level, but only ever with an empty
 *       queue: the loop body never runs.
 */
int sensor_flush(int pending);

#endif /* SENSOR_H */
