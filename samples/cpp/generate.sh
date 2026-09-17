#!/usr/bin/env sh
# @file generate.sh
# @brief Regenerate the C++ sample's llvm-cov report. Runs in the lab image (target `c`).
# @author Mario Fucini
# @copyright Copyright (c) 2026 Fucini Consulting. Released under the MIT
#            License; see the LICENSE file in the repository root.
#
#   coverage/coverage.json   llvm-cov JSON: functions, lines, regions, branches,
#                            MC/DC and template instantiations
#
# The three reports merged onto it (trace32-call.xml, trace32-object.xml,
# mutation.json) are not produced here: see the README for what they are.
set -eu
cd "$(dirname "$0")"
mkdir -p build coverage

clang++ -std=c++17 -O0 -g -fprofile-instr-generate -fcoverage-mapping -fcoverage-mcdc \
        src/gearbox.cpp src/gearbox_test.cpp -o build/gearbox
LLVM_PROFILE_FILE=build/gearbox.profraw ./build/gearbox
llvm-profdata merge -sparse build/gearbox.profraw -o build/gearbox.profdata
llvm-cov export ./build/gearbox -instr-profile=build/gearbox.profdata --format=text \
        > coverage/coverage.json

echo "- $(clang++ --version | head -n 1)" > coverage/VERSIONS.txt
echo "Wrote coverage/coverage.json (llvm-cov, incl. MC/DC and instantiations)."
