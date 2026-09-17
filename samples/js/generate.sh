#!/usr/bin/env sh
# Regenerate this sample's coverage reports.
#
#   coverage/coverage-final.json   Istanbul JSON: statement columns, named branch types
#   coverage/lcov.info             the same run as LCOV
#   coverage/clover.xml            ... as Clover
#   coverage/cobertura-coverage.xml ... as Cobertura
#   coverage/unit/coverage-final.json         the unit suite alone
#   coverage/integration/coverage-final.json  the integration suite alone
#
# The per-suite reports are real runs of each suite, not numbers split out of
# the combined one. Load the two together to see a merge, or one at a time to
# see what each suite is worth on its own.
#
# Meant to run inside the lab image (docker/Dockerfile, target `js`), where the
# repository is mounted at /work: the paths inside the reports then read
# /work/samples/js/..., and the sample's .vscode/settings.json maps that prefix
# back to wherever the repository is checked out.
set -eu
cd "$(dirname "$0")"

npm ci --no-audit --no-fund
rm -rf coverage .nyc_output

for suite in unit integration; do
  npx nyc --silent --temp-dir ".nyc_output/$suite" node "test/$suite.test.js"
  npx nyc report --temp-dir ".nyc_output/$suite" --report-dir "coverage/$suite" --reporter=json
done

npx nyc --silent --temp-dir .nyc_output/all sh -c 'node test/unit.test.js && node test/integration.test.js'
npx nyc report --temp-dir .nyc_output/all --report-dir coverage \
  --reporter=json --reporter=lcovonly --reporter=clover --reporter=cobertura

echo "Wrote coverage/ (Istanbul JSON, LCOV, Clover, Cobertura) and the two per-suite reports."
