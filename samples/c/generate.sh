#!/usr/bin/env sh
# Regenerate every report of the C sample. Runs in the lab image (target `c`).
#
# Two real builds of the same sources:
#
#   clang  -> coverage/coverage.json   llvm-cov JSON: regions, branches, MC/DC
#             coverage/lcov.info       the same run as LCOV
#             coverage/per-test.info   one LCOV section per half of the suite
#   gcc    -> coverage/gcovr/*         one gcov run written six ways by gcovr:
#             Cobertura, SonarQube generic, Coveralls, Clover, JaCoCo XML, JSON
#
# The six gcovr files describe identical numbers, which is the point: load any
# two and what differs is what the format can say, not what was measured.
set -eu
cd "$(dirname "$0")"

bash scripts/gen-coverage.sh clang --per-test

# Compiled file by file so each .gcno and .gcda lands in build/gcc beside its
# object, where --object-directory finds it, whatever gcc's naming rule for a
# multi-source link happens to be in this version.
rm -rf build/gcc coverage/gcovr
mkdir -p build/gcc coverage/gcovr
for unit in calc buffer sensor calc_test; do
  gcc -O0 -g --coverage -c "src/$unit.c" -o "build/gcc/$unit.o"
done
gcc --coverage build/gcc/*.o -o build/gcc/calc
./build/gcc/calc

gcovr --root . --object-directory build/gcc \
  --cobertura coverage/gcovr/cobertura.xml \
  --sonarqube coverage/gcovr/sonarqube.xml \
  --coveralls coverage/gcovr/coveralls.json \
  --clover    coverage/gcovr/clover.xml \
  --jacoco    coverage/gcovr/jacoco.xml \
  --json      coverage/gcovr/gcovr.json

{
  echo "- $(clang --version | head -n 1)"
  echo "- $(gcc --version | head -n 1)"
  echo "- $(lcov --version)"
  echo "- $(gcovr --version | head -n 1)"
} > coverage/VERSIONS.txt

echo "Wrote coverage/ (llvm-cov JSON, LCOV, per-test LCOV) and coverage/gcovr/ (six formats)."
