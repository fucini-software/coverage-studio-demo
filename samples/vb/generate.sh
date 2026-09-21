#!/usr/bin/env sh
# @file generate.sh
# @brief Regenerate the Visual Basic sample's coverage reports. Runs in the lab image (target `dotnet`).
# @author Mario Fucini
# @copyright Copyright (c) 2026 Fucini Consulting. Released under the MIT
#            License; see the LICENSE file in the repository root.
#
#   coverage/coverage.opencover.xml   Coverlet, OpenCover format: per-arm branch
#                                     counts and cyclomatic complexity per method
#   coverage/coverage.cobertura.xml   the same run as Cobertura
#
# On Windows, without the image: scripts/gen-coverage.ps1.
set -eu
cd "$(dirname "$0")"

rm -rf coverage
mkdir -p coverage

dotnet test test/Payroll.Tests \
  -p:CollectCoverage=true \
  "-p:CoverletOutputFormat=opencover%2ccobertura" \
  "-p:CoverletOutput=$(pwd)/coverage/"

{
  echo "- dotnet $(dotnet --version)"
  echo "- coverlet.msbuild $(sed -n 's/.*coverlet.msbuild" Version="\([^"]*\)".*/\1/p' test/Payroll.Tests/Payroll.Tests.vbproj)"
} > coverage/VERSIONS.txt

echo "Wrote coverage/ (OpenCover, Cobertura)."
