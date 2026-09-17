/**
 * @file gearbox.hpp
 * @brief Gear selection for the C++ coverage sample: one file, every metric.
 *
 * This is the file to open when you want to see what Coverage Studio does with
 * everything a toolchain can say about a piece of code. Four reports describe
 * it and merge into one record: llvm-cov measures its functions, lines,
 * regions, branches, MC/DC and template instantiations; a call-coverage and an
 * object-code export add how much of its call sites and of its built binary
 * ran; a mutation report adds how many deliberate faults its tests noticed.
 * The README beside this sample says which of those reports are real.
 *
 * @author Mario Fucini
 * @copyright Copyright (c) 2026 Fucini Consulting. Released under the MIT
 *            License; see the LICENSE file in the repository root.
 */
#ifndef GEARBOX_HPP
#define GEARBOX_HPP

/** @brief Highest gear of the gearbox. */
constexpr int TOP_GEAR = 6;

/**
 * @brief Whether to shift up: <tt>(rpm > 3000 && throttle > 50) || manual</tt>.
 * @param rpm      Engine speed in revolutions per minute.
 * @param throttle Throttle position in percent.
 * @param manual   True while the driver has asked for the shift.
 * @retval true  Shift up.
 * @retval false Hold the gear.
 * @note MC/DC 2 of 3, on purpose: the suite shows @p rpm and @p throttle each
 *       deciding the outcome alone, and never shifts manually.
 */
bool should_shift_up(int rpm, int throttle, bool manual);

/**
 * @brief The gear to be in after a shift request.
 * @param current The gear engaged now, 1 to #TOP_GEAR.
 * @param up      True to shift up, false to shift down.
 * @return The new gear, never outside 1 to #TOP_GEAR.
 * @note The suite never shifts down, so that branch is half taken.
 */
int next_gear(int current, bool up);

/**
 * @brief Fuel cut ratio for a given gear, as a fraction of full flow.
 * @param gear The engaged gear.
 * @return A ratio from 0.0 to 1.0.
 * @note The only caller of the @c double instantiation of the clamp_to()
 *       template in gearbox.cpp, and never called by any test.
 */
double fuel_ratio(int gear);

/**
 * @brief Fall back to a safe gear after a fault.
 * @return Always gear 3.
 * @note Never called by any test, on purpose: the dead-code entry.
 */
int limp_home();

#endif /* GEARBOX_HPP */
