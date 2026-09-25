/**
 * @file test_bits.c
 * @brief The one test suite, built twice: once with clang, once with GCC.
 *
 * @author Mario Fucini
 * @copyright Copyright (c) 2026 Fucini Consulting. Released under the MIT
 *            License; see the LICENSE file in the repository root.
 */
#include <stdio.h>

#include "../src/bits.h"

static int failures = 0;

static void expect(int ok, const char *what) {
    if (!ok) {
        printf("FAIL: %s\n", what);
        failures++;
    }
}

int main(void) {
    expect(bits_popcount(0u) == 0u, "popcount(0)");
    expect(bits_popcount(0xFFu) == 8u, "popcount(0xFF)");
    expect(bits_popcount(0x80000001u) == 2u, "popcount(0x80000001)");
    expect(bits_even_parity(3u) == 1, "parity(3)");
    expect(bits_even_parity(7u) == 0, "parity(7)");
    printf("%s (%s build)\n", failures == 0 ? "ok" : "FAILED", bits_fast_path() ? "fast-path" : "portable");
    return failures == 0 ? 0 : 1;
}
