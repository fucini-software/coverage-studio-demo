# Build the same tests twice — clang and GCC — and write one coverage report per build:
#
#   coverage\clang.json                     llvm-cov export, with MC/DC
#   coverage\gcc\bits.gcov.json.gz          gcov --json-format
#
# Run from the sample's folder, with LLVM/Clang and MinGW GCC on PATH:
#
#   .\scripts\gen-coverage.ps1
#
# clang on Windows links its profile runtime against the MSVC libraries, so the
# Visual C++ build tools must be installed; their environment is taken from
# vcvars64.bat when the shell has not set it up already.
$ErrorActionPreference = 'Stop'
Set-Location (Split-Path -Parent $PSScriptRoot)
foreach ($dir in 'build\clang', 'build\gcc', 'coverage\gcc') { New-Item -ItemType Directory -Force $dir | Out-Null }

if (-not $env:INCLUDE) {
    $vs = & "${env:ProgramFiles(x86)}\Microsoft Visual Studio\Installer\vswhere.exe" -latest -products * -requires Microsoft.VisualStudio.Component.VC.Tools.x86.x64 -property installationPath
    $vcvars = Join-Path $vs 'VC\Auxiliary\Build\vcvars64.bat'
    if (-not (Test-Path $vcvars)) { throw 'clang needs the Visual C++ build tools (vcvars64.bat not found)' }
    foreach ($line in cmd /c "`"$vcvars`" >nul 2>nul && set") {
        if ($line -match '^(INCLUDE|LIB|LIBPATH)=(.*)$') { Set-Item "env:$($Matches[1])" $Matches[2] }
    }
}

# clang: source-based coverage, MC/DC included.
clang -O0 -g -fprofile-instr-generate -fcoverage-mapping -fcoverage-mcdc src\bits.c tests\test_bits.c -o build\clang\test_bits.exe
$env:LLVM_PROFILE_FILE = 'build\clang\bits.profraw'
& .\build\clang\test_bits.exe
if ($LASTEXITCODE -ne 0) { throw 'the clang build failed its tests' }
llvm-profdata merge -sparse build\clang\bits.profraw -o build\clang\bits.profdata
llvm-cov export build\clang\test_bits.exe --instr-profile build\clang\bits.profdata --format=text --ignore-filename-regex='tests' |
    Set-Content -Encoding utf8 coverage\clang.json

# GCC: gcov's own JSON, one file per translation unit. Counters add up across
# runs, so the ones from a previous run go first.
Get-ChildItem build\gcc -Filter '*.gcda' | Remove-Item
# Absolute source paths, so gcov names bits.c as llvm-cov does and the two
# reports are seen to measure one file.
gcc -O0 -g --coverage (Resolve-Path src\bits.c).Path (Resolve-Path tests\test_bits.c).Path -o build\gcc\test_bits.exe
& .\build\gcc\test_bits.exe
if ($LASTEXITCODE -ne 0) { throw 'the GCC build failed its tests' }
Push-Location coverage\gcc
try {
    # GCC names the object after the executable: test_bits-bits.gcda is bits.c's.
    gcov --json-format --object-file ..\..\build\gcc\test_bits-bits.gcda ..\..\src\bits.c | Out-Null
    if ($LASTEXITCODE -ne 0) { throw 'gcov failed' }
} finally { Pop-Location }
Get-ChildItem coverage -Recurse -File | ForEach-Object { '{0,-40} {1,8:N0} bytes' -f $_.FullName.Substring((Get-Location).Path.Length + 1), $_.Length }
