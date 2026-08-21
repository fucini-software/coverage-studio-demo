#!/usr/bin/env bash
# Regenerate authentic coverage tracefiles for the demo.
#
#   ./scripts/gen-coverage.sh clang   # llvm-cov JSON with MC/DC  -> coverage/coverage.json
#   ./scripts/gen-coverage.sh gcc     # lcov.info via gcov         -> coverage/lcov.info
#
# Run from the demo/ root. Requires the matching toolchain on PATH.
set -euo pipefail
cd "$(dirname "$0")/.."
mkdir -p build coverage
MODE="${1:-clang}"

if [ "$MODE" = "clang" ]; then
  clang -O0 -g -fprofile-instr-generate -fcoverage-mapping -fcoverage-mcdc \
        src/calc.c src/calc_test.c -o build/calc
  LLVM_PROFILE_FILE=build/calc.profraw ./build/calc
  llvm-profdata merge -sparse build/calc.profraw -o build/calc.profdata
  llvm-cov export ./build/calc -instr-profile=build/calc.profdata --format=json \
        > coverage/coverage.json
  echo "Wrote coverage/coverage.json (llvm-cov, incl. MC/DC)."
elif [ "$MODE" = "gcc" ]; then
  gcc -O0 -g --coverage src/calc.c src/calc_test.c -o build/calc
  ./build/calc
  lcov --capture --directory . --output-file coverage/lcov.info --rc branch_coverage=1
  echo "Wrote coverage/lcov.info (gcov/lcov)."
else
  echo "Usage: $0 [clang|gcc]" >&2
  exit 2
fi
