/**
 * @file buffer.h
 * @brief A tiny bounded buffer: the kind of guard embedded code is full of.
 *
 * It is here for one function, buffer_can_write(). Its decision runs, and is
 * taken, so line and branch coverage call it covered; MC/DC reports 0 of 3
 * conditions, because none was ever shown to matter on its own. That gap is
 * the reason branch and MC/DC coverage are worth measuring separately.
 *
 * @author Mario Fucini
 * @copyright Copyright (c) 2026 Fucini Consulting. Released under the MIT
 *            License; see the LICENSE file in the repository root.
 */
#ifndef BUFFER_H
#define BUFFER_H

/** @brief Largest number of values a buffer can hold. */
#define BUFFER_MAX 4

/** @brief A bounded buffer of integers. */
typedef struct {
    int data[BUFFER_MAX]; /**< The stored values, oldest first. */
    int count;            /**< How many values are stored. */
    int capacity;         /**< How many may be stored; at most #BUFFER_MAX. */
    int locked;           /**< Non-zero while writes are refused. */
} buffer_t;

/**
 * @brief Empty a buffer and set its capacity.
 * @param[out] b        The buffer to initialise.
 * @param[in]  capacity Requested capacity; clamped to #BUFFER_MAX.
 */
void buffer_init(buffer_t *b, int capacity);

/**
 * @brief Append a value.
 * @param[in,out] b     The buffer to append to.
 * @param[in]     value The value to store.
 * @retval 1 The value was stored.
 * @retval 0 The buffer is full and the value was refused.
 * @note Both outcomes are exercised by the suite.
 */
int buffer_push(buffer_t *b, int value);

/**
 * @brief Whether a write is allowed: <tt>(count < capacity && !locked) || force</tt>.
 * @param[in] b     The buffer to check.
 * @param[in] force Non-zero to allow the write regardless of the buffer's state.
 * @retval 1 A write is allowed.
 * @retval 0 A write is refused.
 * @note MC/DC 0% on purpose: the suite only ever reaches this with @p force
 *       set, so the decision is taken while no condition is independently
 *       exercised. This is the argument for MC/DC at ASIL C/D and SIL 3/4.
 */
int buffer_can_write(const buffer_t *b, int force);

/**
 * @brief Remove every value.
 * @param[in,out] b The buffer to empty.
 * @return How many values were removed.
 * @note Never called by any test, on purpose.
 */
int buffer_drain(buffer_t *b);

#endif /* BUFFER_H */
