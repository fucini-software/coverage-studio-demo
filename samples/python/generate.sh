#!/usr/bin/env sh
# Regenerate this sample's coverage reports. Runs in the lab image (target `python`).
#
#   coverage/coverage.json            coverage.py JSON, with branches and exclusions
#   coverage/coverage.xml             the same run as Cobertura
#   coverage/lcov.info                ... as LCOV
#   coverage/posting/coverage.json    the PostingTests suite alone
#   coverage/closing/coverage.json    the ClosingTests suite alone
#
# No --source on purpose: with it, coverage.py lists ledger/archive.py at 0%.
# Without it the file is simply absent, which is what "no test loaded this"
# looks like in most real reports, and what the unmeasured setting is about.
set -eu
cd "$(dirname "$0")"
export PYTHONDONTWRITEBYTECODE=1

rm -rf coverage
mkdir -p coverage/posting coverage/closing

run() { # <data file> <json out> [test class]
  COVERAGE_FILE="$1" python -m coverage run --branch run_tests.py ${3:-}
  COVERAGE_FILE="$1" python -m coverage json --include 'ledger/*' -o "$2"
}

run /tmp/posting.cov coverage/posting/coverage.json PostingTests
run /tmp/closing.cov coverage/closing/coverage.json ClosingTests
run /tmp/all.cov     coverage/coverage.json
COVERAGE_FILE=/tmp/all.cov python -m coverage xml  --include 'ledger/*' -o coverage/coverage.xml
COVERAGE_FILE=/tmp/all.cov python -m coverage lcov --include 'ledger/*' -o coverage/lcov.info

{
  echo "- $(python --version)"
  echo "- $(python -m coverage --version | head -n 1)"
} > coverage/VERSIONS.txt

echo "Wrote coverage/ (coverage.py JSON, Cobertura, LCOV) and the two per-suite reports."
