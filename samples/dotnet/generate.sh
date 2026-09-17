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

{
  echo "- dotnet $(dotnet --version)"
  echo "- $(dotnet-coverage --version | head -n 1)"
  echo "- coverlet.msbuild $(sed -n 's/.*coverlet.msbuild" Version="\([^"]*\)".*/\1/p' test/Pricing.Tests/Pricing.Tests.csproj)"
} > coverage/VERSIONS.txt

echo "Wrote coverage/ (OpenCover, Cobertura, dotnet-coverage XML)."
