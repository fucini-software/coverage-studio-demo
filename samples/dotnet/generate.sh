#!/usr/bin/env sh
# @file generate.sh
# @brief Regenerate the .NET sample's coverage reports. Runs in the lab image (target `dotnet`).
# @author Mario Fucini
# @copyright Copyright (c) 2026 Fucini Consulting. Released under the MIT
#            License; see the LICENSE file in the repository root.
#
#   coverage/coverage.opencover.xml   Coverlet, OpenCover format: per-arm branch
#                                     counts and cyclomatic complexity per method
#   coverage/coverage.cobertura.xml   the same run as Cobertura
#   coverage/dotnet-coverage.xml      Microsoft's own collector: a column range
#                                     per statement, so the untested arm of a
#                                     ternary shows inside a covered line
#
# Two collectors on purpose. They measure the same tests and disagree in what
# they can say: Coverlet has the complexity, dotnet-coverage has the columns.
set -eu
cd "$(dirname "$0")"

rm -rf coverage
mkdir -p coverage

dotnet test test/Pricing.Tests \
  -p:CollectCoverage=true \
  "-p:CoverletOutputFormat=opencover%2ccobertura" \
  "-p:CoverletOutput=$(pwd)/coverage/"

dotnet-coverage collect -f xml -o coverage/dotnet-coverage.xml \
  "dotnet test test/Pricing.Tests --no-build"

# One report per test class, with the collector the test SDK ships — the shape
# Coverage Studio's testRun.perTest writes, so that "Show Tests That Ran This
# Line" can name the class. The collector names its file after the user and
# the machine; it is renamed to what Coverlet would have written.
for class in Pricing.Tests.QuoteTests Pricing.Tests.ShippingTests; do
  dir="coverage/per-test/$class"
  dotnet test test/Pricing.Tests --no-build \
    --collect:"Code Coverage;Format=cobertura" \
    --results-directory "$dir" \
    --filter "FullyQualifiedName~$class"
  report="$(find "$dir" -name '*.cobertura.xml' | head -n 1)"
  mv "$report" "$dir/coverage.cobertura.xml"
  find "$dir" -mindepth 1 -type d -exec rm -rf {} +
done

# Stryker.NET over the library, from the test project that reaches it — the
# run "Run Mutation Tests Here" makes for one function, here for the whole
# file. The report lands under StrykerOutput/<time>/reports and is moved up.
rm -rf StrykerOutput
dotnet stryker --test-project test/Pricing.Tests/Pricing.Tests.csproj --project Pricing.csproj \
  --reporter json --reporter progress
mv StrykerOutput/*/reports/mutation-report.json coverage/mutation-report.json
rm -rf StrykerOutput

{
  echo "- dotnet $(dotnet --version)"
  echo "- $(dotnet-coverage --version | head -n 1)"
  echo "- dotnet-stryker $( (dotnet tool list -g; dotnet tool list --tool-path /opt/dotnet-tools) 2>/dev/null | awk '/^dotnet-stryker/ {print $2; exit}')"
  echo "- coverlet.msbuild $(sed -n 's/.*coverlet.msbuild" Version="\([^"]*\)".*/\1/p' test/Pricing.Tests/Pricing.Tests.csproj)"
} > coverage/VERSIONS.txt

echo "Wrote coverage/ (OpenCover, Cobertura, dotnet-coverage XML, one Cobertura per test class under per-test/, and the mutation report)."
