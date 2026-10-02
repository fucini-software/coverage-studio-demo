#!/usr/bin/env sh
# @file generate.sh
# @brief Regenerate the console app's coverage. Runs in the lab image (target `dotnet-app`).
# @author Mario Fucini
# @copyright Copyright (c) 2026 Fucini Consulting. Released under the MIT
#            License; see the LICENSE file in the repository root.
#
#   coverage/app/coverage.cobertura.xml   one plain run of the app under
#                                         Microsoft's dotnet-coverage — the
#                                         command "Run App with Coverage…"
#                                         runs, and the file it writes
set -eu
cd "$(dirname "$0")"

rm -rf coverage
mkdir -p coverage/app

dotnet-coverage collect -f cobertura -o coverage/app/coverage.cobertura.xml \
  dotnet run --project src/Shop/Shop.csproj

{
  echo "- dotnet $(dotnet --version)"
  echo "- $(dotnet-coverage --version | head -n 1)"
} > coverage/VERSIONS.txt

echo "Wrote coverage/app/coverage.cobertura.xml (one run of the app)."
