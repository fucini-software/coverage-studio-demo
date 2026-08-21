<#
  Regenerate authentic coverage tracefiles for the demo (Windows).

    .\scripts\gen-coverage.ps1 clang   # llvm-cov JSON with MC/DC -> coverage\coverage.json
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
          src/calc.c src/calc_test.c -o build/calc.exe
    $env:LLVM_PROFILE_FILE = 'build/calc.profraw'
    & ./build/calc.exe
    llvm-profdata merge -sparse build/calc.profraw -o build/calc.profdata
    llvm-cov export ./build/calc.exe -instr-profile=build/calc.profdata --format=json `
          | Out-File -Encoding utf8 coverage/coverage.json
    Write-Host 'Wrote coverage/coverage.json (llvm-cov, incl. MC/DC).'
}
else {
    gcc -O0 -g --coverage src/calc.c src/calc_test.c -o build/calc.exe
    & ./build/calc.exe
    lcov --capture --directory . --output-file coverage/lcov.info --rc branch_coverage=1
    Write-Host 'Wrote coverage/lcov.info (gcov/lcov).'
}
