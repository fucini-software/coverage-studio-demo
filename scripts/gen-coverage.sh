#!/usr/bin/env bash
# Regenerate authentic coverage tracefiles for the demo.
#
#   ./scripts/gen-coverage.sh clang   # llvm-cov JSON with MC/DC  -> coverage/coverage.json
#                                     #   (+ coverage/lcov.info from the same run)
#   ./scripts/gen-coverage.sh gcc     # lcov.info via gcov         -> coverage/lcov.info
#
#   ./scripts/gen-coverage.sh clang --per-test
#                                     # also coverage/per-test.info: the calc and
#                                     #   buffer halves of the suite run separately,
#                                     #   as lcov TN:calc / TN:buffer
#
# Run from the demo/ root. Requires the matching toolchain on PATH.
set -euo pipefail
cd "$(dirname "$0")/.."
mkdir -p build coverage
MODE="${1:-clang}"
PER_TEST="${2:-}"

if [ "$MODE" = "clang" ]; then
  clang -O0 -g -fprofile-instr-generate -fcoverage-mapping -fcoverage-mcdc \
        src/calc.c src/buffer.c src/calc_test.c -o build/calc
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
  gcc -O0 -g --coverage src/calc.c src/buffer.c src/calc_test.c -o build/calc
  ./build/calc
  lcov --capture --directory . --output-file coverage/lcov.info --rc branch_coverage=1
  echo "Wrote coverage/lcov.info (gcov/lcov)."
else
  echo "Usage: $0 [clang|gcc] [--per-test]" >&2
  exit 2
fi

if [ "$PER_TEST" = "--per-test" ]; then
  # One coverage record per half of the suite, as lcov TN: sections — what the
  # Test Coverage view's filter by test reads. Each half is a real run: the same
  # sources built with TEST_CALC_ONLY or TEST_BUFFER_ONLY (see src/calc_test.c),
  # never numbers split out of the combined run.
  : > coverage/per-test.info
  for test in calc buffer; do
    define="-DTEST_CALC_ONLY"
    [ "$test" = "buffer" ] && define="-DTEST_BUFFER_ONLY"
    echo "TN:$test" >> coverage/per-test.info
    if [ "$MODE" = "clang" ]; then
      clang -O0 -g -fprofile-instr-generate -fcoverage-mapping "$define" \
            src/calc.c src/buffer.c src/calc_test.c -o "build/$test"
      LLVM_PROFILE_FILE="build/$test.profraw" "./build/$test"
      llvm-profdata merge -sparse "build/$test.profraw" -o "build/$test.profdata"
      llvm-cov export "./build/$test" -instr-profile="build/$test.profdata" --format=lcov \
            >> coverage/per-test.info
    else
      # The previous half's counters must not leak into this one.
      find . -name '*.gcda' -delete
      gcc -O0 -g --coverage "$define" src/calc.c src/buffer.c src/calc_test.c -o "build/$test"
      "./build/$test"
      lcov --capture --directory . --output-file "build/$test.info" --rc branch_coverage=1
      grep -v '^TN:' "build/$test.info" >> coverage/per-test.info
    fi
  done
  echo "Wrote coverage/per-test.info (TN:calc and TN:buffer)."
fi
