/**
 * @file thermostat.hpp
 * @brief A room thermostat for the MSVC coverage sample.
 *
 * This is the sample for the most common C++ in Visual Studio: built by the
 * Microsoft compiler and measured by Microsoft's own collector. That collector
 * instruments the finished binary, so it knows nothing of decisions,
 * conditions or MC/DC. It counts blocks of machine code, and says of each line
 * whether all of its blocks ran, some, or none: enough to show a line that ran
 * only by half, and not enough to show a condition that never mattered. The
 * clang sample next door (samples/cpp) is the same kind of code measured by a
 * toolchain that can say everything; open both to see what each can tell you.
 *
 * @author Mario Fucini
 * @copyright Copyright (c) 2026 Fucini Consulting. Released under the MIT
 *            License; see the LICENSE file in the repository root.
 */
#ifndef THERMOSTAT_HPP
#define THERMOSTAT_HPP

/** @brief What the thermostat asks of the boiler. */
enum class Demand {
    Off,    /**< Nothing to do. */
    Heat,   /**< Burner on. */
    Frost,  /**< Burner on whatever the schedule says: the pipes come first. */
    Fault   /**< The reading cannot be trusted. */
};

/** @brief Lowest reading, in tenths of a degree Celsius, a working sensor gives. */
constexpr int SENSOR_MIN = -400;
/** @brief Highest reading, in tenths of a degree Celsius, a working sensor gives. */
constexpr int SENSOR_MAX = 850;
/** @brief Below this, in tenths of a degree Celsius, frost protection takes over. */
constexpr int FROST_LIMIT = 50;

/**
 * @brief Whether a reading can be believed.
 * @param tenths The reading, in tenths of a degree Celsius.
 * @retval true  Inside the sensor's range.
 * @retval false A broken wire or a short.
 * @note Fully covered: the suite gives it a reading inside, one below and one
 *       above.
 */
bool plausible(int tenths);

/**
 * @brief What to ask of the boiler.
 * @param tenths   The room's temperature, in tenths of a degree Celsius.
 * @param setpoint The temperature asked for, in the same unit.
 * @param occupied True while somebody is home.
 * @return The demand.
 * @note The suite never lets the room get cold enough for frost protection,
 *       so that arm is red. It also never leaves the house, so @p occupied is
 *       never shown to matter, and this report cannot say so: every block of
 *       that line ran, and the line is green. That is what MC/DC is for, and
 *       what the gearbox in samples/cpp shows.
 */
Demand decide(int tenths, int setpoint, bool occupied);

/**
 * @brief The setpoint for an hour of the day.
 * @param hour    0 to 23.
 * @param weekend True on Saturday and Sunday.
 * @return Tenths of a degree Celsius.
 * @note Only ever asked about weekdays: the weekend arm of the ternary never
 *       runs, and the collector calls the line partially covered. Its
 *       Cobertura export of the same run calls it covered.
 */
int scheduled_setpoint(int hour, bool weekend);

/**
 * @brief How long the burner may stay on without a pause, in minutes.
 * @param demand What is being asked of the boiler.
 * @return Minutes; 0 for a demand that needs no burner.
 * @note A switch half tested: Heat and Off are asked about, Frost and Fault
 *       never.
 */
int max_burn_minutes(Demand demand);

/**
 * @brief Put the thermostat back to what it left the factory with.
 * @return The factory setpoint, in tenths of a degree Celsius.
 * @note Never called by any test, on purpose: the dead-code entry.
 */
int factory_reset();

#endif /* THERMOSTAT_HPP */
