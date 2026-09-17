#!/usr/bin/env bash
# @file gen-coverage.sh
# @brief Regenerate authentic coverage tracefiles for the C sample (macOS/Linux).
# @author Mario Fucini
# @copyright Copyright (c) 2026 Fucini Consulting. Released under the MIT
#            License; see the LICENSE file in the repository root.
#
#   ./scripts/gen-coverage.sh clang   # llvm-cov JSON with MC/DC  -> coverage/coverage.json
#                                     #   (+ coverage/lcov.info from the same run)
#   ./scripts/gen-coverage.sh gcc     # lcov.info via gcov         -> coverage/lcov.info
#
#   ./scripts/gen-coverage.sh clang --per-test
#                                     # also coverage/per-test.info: the calc, buffer
#                                     #   and sensor parts of the suite run separately,
#                                     #   as lcov TN:calc / TN:buffer / TN:sensor
#
# Works from any directory: it moves to the sample's root itself. Requires the
# matching toolchain on PATH.
set -euo pipefail
cd "$(dirname "$0")/.."
mkdir -p build coverage
MODE="${1:-clang}"
PER_TEST="${2:-}"
SOURCES="src/calc.c src/buffer.c src/sensor.c src/calc_test.c"

if [ "$MODE" = "clang" ]; then
  # shellcheck disable=SC2086  # SOURCES is a list on purpose
  clang -O0 -g -fprofile-instr-generate -fcoverage-mapping -fcoverage-mcdc \
        $SOURCES -o build/calc
  LLVM_PROFILE_FILE=build/calc.profraw ./build/calc
  llvm-profdata merge -sparse build/calc.profraw -o build/calc.profdata

  # `--format=text` is what emits JSON. `--format=json` is not a valid value and
  # llvm-cov rejects it outright ("Cannot find option named 'json'"), which is
  # what this script used to pass.
  llvm-cov export ./build/calc -instr-profile=build/calc.profdata --format=text \
        > coverage/coverage.json

  # The same run exported as LCOV, so both tracefiles in coverage/ describe the
  # same build rather than drifting apart. LCOV cannot carry MC/DC or regions —
  # which is exactly why coverage.json is the interesting one.
  llvm-cov export ./build/calc -instr-profile=build/calc.profdata --format=lcov \
        > coverage/lcov.info

  echo "Wrote coverage/coverage.json (llvm-cov, incl. MC/DC) and coverage/lcov.info."
elif [ "$MODE" = "gcc" ]; then
  # shellcheck disable=SC2086
  gcc -O0 -g --coverage $SOURCES -o build/calc
  ./build/calc
  lcov --capture --directory . --output-file coverage/lcov.info --rc branch_coverage=1
  echo "Wrote coverage/lcov.info (gcov/lcov)."
else
  echo "Usage: $0 [clang|gcc] [--per-test]" >&2
  exit 2
fi

if [ "$PER_TEST" = "--per-test" ]; then
  # One coverage record per part of the suite, as lcov TN: sections — what the
  # Test Coverage view's filter by test reads. Each part is a real run: the same
  # sources built with TEST_CALC_ONLY, TEST_BUFFER_ONLY or TEST_SENSOR_ONLY (see
  # src/calc_test.c), never numbers split out of the combined run.
  : > coverage/per-test.info
  for test in calc buffer sensor; do
    define="-DTEST_$(echo "$test" | tr '[:lower:]' '[:upper:]')_ONLY"
    echo "TN:$test" >> coverage/per-test.info
    if [ "$MODE" = "clang" ]; then
      # shellcheck disable=SC2086
      clang -O0 -g -fprofile-instr-generate -fcoverage-mapping "$define" \
            $SOURCES -o "build/$test"
      LLVM_PROFILE_FILE="build/$test.profraw" "./build/$test"
      llvm-profdata merge -sparse "build/$test.profraw" -o "build/$test.profdata"
      llvm-cov export "./build/$test" -instr-profile="build/$test.profdata" --format=lcov \
            >> coverage/per-test.info
    else
      # The previous part's counters must not leak into this one.
      find . -name '*.gcda' -delete
      # shellcheck disable=SC2086
      gcc -O0 -g --coverage "$define" $SOURCES -o "build/$test"
      "./build/$test"
      lcov --capture --directory . --output-file "build/$test.info" --rc branch_coverage=1
      grep -v '^TN:' "build/$test.info" >> coverage/per-test.info
    fi
  done
  echo "Wrote coverage/per-test.info (TN:calc, TN:buffer and TN:sensor)."
fi
