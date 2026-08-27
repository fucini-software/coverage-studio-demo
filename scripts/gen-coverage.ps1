<#
  Regenerate authentic coverage tracefiles for the demo (Windows).

    .\scripts\gen-coverage.ps1 clang   # llvm-cov JSON with MC/DC -> coverage\coverage.json
                                       #   (+ coverage\lcov.info from the same run)
    .\scripts\gen-coverage.ps1 gcc     # lcov.info via gcov        -> coverage\lcov.info

  Run from the demo\ root. Requires the matching toolchain on PATH
  (LLVM/Clang for 'clang'; MinGW gcc + lcov for 'gcc').
#>
param([ValidateSet('clang','gcc')][string]$Mode = 'clang')

$ErrorActionPreference = 'Stop'
Set-Location (Join-Path $PSScriptRoot '..')
New-Item -ItemType Directory -Force -Path build, coverage | Out-Null

if ($Mode -eq 'clang') {
    clang -O0 -g -fprofile-instr-generate -fcoverage-mapping -fcoverage-mcdc `
          src/calc.c src/buffer.c src/calc_test.c -o build/calc.exe
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
    gcc -O0 -g --coverage src/calc.c src/buffer.c src/calc_test.c -o build/calc.exe
    & ./build/calc.exe
    lcov --capture --directory . --output-file coverage/lcov.info --rc branch_coverage=1
    Write-Host 'Wrote coverage/lcov.info (gcov/lcov).'
}
