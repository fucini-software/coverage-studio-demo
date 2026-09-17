# C coverage sample: build file.
# Author: Mario Fucini
# Copyright (c) 2026 Fucini Consulting. Released under the MIT License; see the
# LICENSE file in the repository root.

cmake_minimum_required(VERSION 3.16)
project(coverage_studio_demo C)

set(CMAKE_C_STANDARD 11)

# Build the tiny test binary. Coverage flags are added by the gen-coverage
# scripts rather than hard-coded here, so the same tree builds cleanly with
# either GCC (gcov/lcov) or Clang (llvm-cov, incl. MC/DC).
add_executable(calc src/calc.c src/buffer.c src/sensor.c src/calc_test.c)
enable_testing()
add_test(NAME calc COMMAND calc)
