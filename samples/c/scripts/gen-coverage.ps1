<#
.SYNOPSIS
  Regenerate authentic coverage tracefiles for the C sample (Windows).

.DESCRIPTION
    .\scripts\gen-coverage.ps1 clang   # llvm-cov JSON with MC/DC -> coverage\coverage.json
                                       #   (+ coverage\lcov.info from the same run)
    .\scripts\gen-coverage.ps1 gcc     # lcov.info via gcov        -> coverage\lcov.info

    .\scripts\gen-coverage.ps1 clang -PerTest
                                       # also coverage\per-test.info: the calc, buffer
                                       #   and sensor parts of the suite run separately,
                                       #   as lcov TN:calc / TN:buffer / TN:sensor

  Works from any directory: it moves to the sample's root itself. Requires the
  matching toolchain on PATH (LLVM/Clang for 'clang'; MinGW gcc + lcov for 'gcc').

.NOTES
  Author:    Mario Fucini
  Copyright: Copyright (c) 2026 Fucini Consulting. Released under the MIT
             License; see the LICENSE file in the repository root.
#>
param([ValidateSet('clang','gcc')][string]$Mode = 'clang', [switch]$PerTest)

$ErrorActionPreference = 'Stop'
Set-Location (Join-Path $PSScriptRoot '..')
New-Item -ItemType Directory -Force -Path build, coverage | Out-Null
$sources = 'src/calc.c', 'src/buffer.c', 'src/sensor.c', 'src/calc_test.c'

if ($Mode -eq 'clang') {
    clang -O0 -g -fprofile-instr-generate -fcoverage-mapping -fcoverage-mcdc `
          @sources -o build/calc.exe
    $env:LLVM_PROFILE_FILE = 'build/calc.profraw'
    & ./build/calc.exe
    # Pass the profile as a separate argument. The `-instr-profile=<path>` form
    # is split by PowerShell before llvm-cov sees it, and the tool then reports
    # a missing source file and an unreadable profile instead of the real
    # problem.
    llvm-profdata merge -sparse 'build\calc.profraw' -o 'build\calc.profdata'

    # `--format=text` is what emits JSON. `--format=json` is not a valid value
    # and llvm-cov rejects it outright ("Cannot find option named 'json'"),
    # which is what this script used to pass.
    & llvm-cov export 'build\calc.exe' --instr-profile 'build\calc.profdata' --format=text `
          | Out-File -Encoding utf8 coverage/coverage.json

    # The same run, exported as LCOV, so both tracefiles in coverage/ describe
    # the same build rather than drifting apart. LCOV cannot carry MC/DC or
    # regions — that is exactly why coverage.json is the interesting one.
    & llvm-cov export 'build\calc.exe' --instr-profile 'build\calc.profdata' --format=lcov `
          | Out-File -Encoding utf8 coverage/lcov.info

    Write-Host 'Wrote coverage/coverage.json (llvm-cov, incl. MC/DC) and coverage/lcov.info.'
}
else {
    gcc -O0 -g --coverage @sources -o build/calc.exe
    & ./build/calc.exe
    lcov --capture --directory . --output-file coverage/lcov.info --rc branch_coverage=1
    Write-Host 'Wrote coverage/lcov.info (gcov/lcov).'
}

if ($PerTest) {
    # One coverage record per part of the suite, as lcov TN: sections — what
    # the Test Coverage view's filter by test reads. Each part is a real run:
    # the same sources built with TEST_CALC_ONLY, TEST_BUFFER_ONLY or
    # TEST_SENSOR_ONLY (see src/calc_test.c), never numbers split out of the
    # combined run.
    $sections = @()
    foreach ($test in 'calc', 'buffer', 'sensor') {
        $define = "-DTEST_$($test.ToUpper())_ONLY"
        if ($Mode -eq 'clang') {
            clang -O0 -g -fprofile-instr-generate -fcoverage-mapping $define `
                  @sources -o "build/$test.exe"
            $env:LLVM_PROFILE_FILE = "build/$test.profraw"
            & "./build/$test.exe"
            llvm-profdata merge -sparse "build\$test.profraw" -o "build\$test.profdata"
            $lcov = & llvm-cov export "build\$test.exe" --instr-profile "build\$test.profdata" --format=lcov
        }
        else {
            # The previous part's counters must not leak into this one.
            Get-ChildItem -Recurse -Filter *.gcda | Remove-Item -Force
            gcc -O0 -g --coverage $define @sources -o "build/$test.exe"
            & "./build/$test.exe"
            lcov --capture --directory . --output-file "build/$test.info" --rc branch_coverage=1
            $lcov = Get-Content "build/$test.info" | Where-Object { $_ -notmatch '^TN:' }
        }
        $sections += "TN:$test"
        $sections += $lcov
    }
    $sections | Out-File -Encoding utf8 coverage/per-test.info
    Write-Host 'Wrote coverage/per-test.info (TN:calc, TN:buffer and TN:sensor).'
}
