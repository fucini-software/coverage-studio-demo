#!/usr/bin/env sh
# @file generate.sh
# @brief Regenerate the condition-coverage report. Runs in the lab image (target `c-gcc14`).
# @author Mario Fucini
# @copyright Copyright (c) 2026 Fucini Consulting. Released under the MIT
#            License; see the LICENSE file in the repository root.
#
#   coverage/alarm.gcov.json.gz   gcov's JSON for src/alarm.c, from a build with
#                                 -fcondition-coverage (gcc 14 or newer): per
#                                 decision, which operand was never seen true
#                                 and which never false
set -eu
cd "$(dirname "$0")"

rm -rf build coverage
mkdir -p build coverage

# Compiled file by file so each .gcno and .gcda lands in build beside its
# object, where --object-directory finds it.
gcc -O0 -g --coverage -fcondition-coverage -c src/alarm.c -o build/alarm.o
gcc -O0 -g --coverage -fcondition-coverage -c tests/test_alarm.c -o build/test_alarm.o
gcc --coverage build/alarm.o build/test_alarm.o -o build/test_alarm
./build/test_alarm

# --branch-probabilities puts the decision arms into the JSON and --conditions the
# condition outcomes; gcov names the file after the source and writes it where
# it runs.
gcov --json-format --branch-probabilities --conditions --object-directory build src/alarm.c
mv alarm.gcov.json.gz coverage/

echo "- $(gcc --version | head -n 1)" > coverage/VERSIONS.txt

echo "Wrote coverage/alarm.gcov.json.gz (gcov JSON with condition coverage)."
