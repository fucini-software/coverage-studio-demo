/**
 * @file bits.c
 * @brief Implementation of bits.h.
 *
 * The same source, built by two compilers, runs different lines: the clang
 * build counts bits with the compiler's builtin, the GCC build with the
 * portable loop below it. Tested with the same tests, each build's report
 * says the other half of bits_popcount() never ran — which is why the two
 * reports are combined in this sample rather than one of them being picked.
 *
 * @author Mario Fucini
 * @copyright Copyright (c) 2026 Fucini Consulting. Released under the MIT
 *            License; see the LICENSE file in the repository root.
 */
#include "bits.h"

/* Both compilers know __builtin_popcount; the choice stands for the kind of
 * toolchain-specific fast path real code has (an intrinsic, an assembler
 * routine, a vendor library) beside its portable fallback. */
int bits_fast_path(void) {
#if defined(__clang__)
    return 1;
#else
    return 0;
#endif
}

uint32_t bits_popcount(uint32_t x) {
    if (bits_fast_path()) {
        return (uint32_t)__builtin_popcount(x);
    }
    uint32_t n = 0;
    /* One line, so both compilers measure the loop on the same line: a
     * closing brace only one of them counts would be a line only it can speak for. */
    while (x != 0u) { x &= x - 1u; n++; }
    return n;
}

int bits_even_parity(uint32_t x) {
    return (bits_popcount(x) % 2u) == 0u;
}
