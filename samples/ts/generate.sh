#!/usr/bin/env sh
# @file generate.sh
# @brief Regenerate the TypeScript sample's coverage reports. Runs in the lab image (target `js`).
# @author Mario Fucini
# @copyright Copyright (c) 2026 Fucini Consulting. Released under the MIT
#            License; see the LICENSE file in the repository root.
#
# The work is scripts/gen-coverage.mjs, which says what it writes and runs the
# same on any platform; this is the entry point the other samples have too.
set -eu
cd "$(dirname "$0")"

npm ci --no-audit --no-fund
node scripts/gen-coverage.mjs