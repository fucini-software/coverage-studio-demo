/**
 * @file bits.h
 * @brief Bit counting and a parity check, with a fast path that depends on the
 *        compiler — the kind of code a cross-compiler coverage check exists for.
 *
 * @author Mario Fucini
 * @copyright Copyright (c) 2026 Fucini Consulting. Released under the MIT
 *            License; see the LICENSE file in the repository root.
 */
#ifndef BITS_H
#define BITS_H

#include <stdint.h>

/** Whether this build takes the builtin path — decided by the compiler, not by the caller. */
int bits_fast_path(void);

/** Number of set bits in @p x. */
uint32_t bits_popcount(uint32_t x);

/** 1 when @p x has an even number of set bits, else 0. */
int bits_even_parity(uint32_t x);

#endif /* BITS_H */
