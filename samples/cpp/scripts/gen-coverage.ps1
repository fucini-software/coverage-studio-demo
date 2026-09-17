<#
.SYNOPSIS
  Regenerate the C++ sample's llvm-cov report (Windows).

.DESCRIPTION
    .\scripts\gen-coverage.ps1         # -> coverage\coverage.json (llvm-cov JSON:
                                       #    functions, lines, regions, branches,
                                       #    MC/DC and template instantiations)

  Works from any directory: it moves to the sample's root itself. Requires
  LLVM/Clang 18 or newer on PATH (MC/DC needs -fcoverage-mcdc). The sources
  include no standard-library header, so a bare compiler is enough.

.NOTES
  Author:    Mario Fucini
  Copyright: Copyright (c) 2026 Fucini Consulting. Released under the MIT
             License; see the LICENSE file in the repository root.
#>
$ErrorActionPreference = 'Stop'
Set-Location (Join-Path $PSScriptRoot '..')
New-Item -ItemType Directory -Force -Path build, coverage | Out-Null

clang++ -std=c++17 -O0 -g -fprofile-instr-generate -fcoverage-mapping -fcoverage-mcdc `
        src/gearbox.cpp src/gearbox_test.cpp -o build/gearbox.exe
$env:LLVM_PROFILE_FILE = 'build/gearbox.profraw'
& ./build/gearbox.exe
if ($LASTEXITCODE -ne 0) { throw "gearbox_test failed its check on line $LASTEXITCODE" }
llvm-profdata merge -sparse 'build\gearbox.profraw' -o 'build\gearbox.profdata'

# `--format=text` is what emits JSON; see the C sample's generator.
& llvm-cov export 'build\gearbox.exe' --instr-profile 'build\gearbox.profdata' --format=text `
      | Out-File -Encoding utf8 coverage/coverage.json

Write-Host 'Wrote coverage/coverage.json (llvm-cov, incl. MC/DC and instantiations).'
