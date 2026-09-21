<#
.SYNOPSIS
  Regenerate the MSVC sample's reports (Windows, Visual Studio 2022 or 2026).

.DESCRIPTION
    .\scripts\gen-coverage.ps1         # -> coverage\coverage.xml            Microsoft's collector, its own XML:
                                       #                                     blocks per function, and of every
                                       #                                     line whether it ran, by half, or not
                                       #    coverage\coverage.cobertura.xml  the same run as Cobertura, which
                                       #                                     has no word for "by half"

  Works from any directory: it moves to the sample's root itself. Needs the
  "Desktop development with C++" workload, and the collector that comes with
  Visual Studio (Microsoft.CodeCoverage.Console) or, where that is missing,
  `dotnet tool install -g dotnet-coverage`, which is the same collector.

  The binary is linked with /PROFILE: that is what lets the collector
  instrument native code, and the one thing to remember for a project of your
  own (Linker > Advanced > Profile in the project's properties).

  Every report is then made to speak of /work/samples/cpp-msvc/..., as the
  other samples' reports do: they are committed, and somebody's drive letter
  has no business in them. The sample's .vscode/settings.json maps that prefix
  back to wherever the repository is checked out. -Local leaves the paths as
  they came.

.NOTES
  Author:    Mario Fucini
  Copyright: Copyright (c) 2026 Fucini Consulting. Released under the MIT
             License; see the LICENSE file in the repository root.
#>
[CmdletBinding()]
param([switch] $Local)

$ErrorActionPreference = 'Stop'
$root = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
Set-Location $root
New-Item -ItemType Directory -Force -Path build, coverage | Out-Null

$vswhere = Join-Path ${env:ProgramFiles(x86)} 'Microsoft Visual Studio\Installer\vswhere.exe'
if (-not (Test-Path $vswhere)) { throw 'No Visual Studio installer found.' }
$install = & $vswhere -latest -requires Microsoft.VisualStudio.Component.VC.Tools.x86.x64 -property installationPath | Select-Object -First 1
if (-not $install) { throw 'No Visual Studio with the C++ tools found (workload "Desktop development with C++").' }
$vcvars = Join-Path $install 'VC\Auxiliary\Build\vcvars64.bat'

# /Od so that a line is a line, /Zi and /DEBUG:FULL for the line table the
# collector reads, /PROFILE so that it may instrument the binary at all.
$compile = 'cl /nologo /std:c++17 /Od /Zi /EHsc /Fo:build\ /Fd:build\thermostat.pdb ' +
           'src\thermostat.cpp src\thermostat_test.cpp /Fe:build\thermostat.exe /link /PROFILE /DEBUG:FULL'
cmd /c "`"$vcvars`" >nul 2>&1 && $compile"
if ($LASTEXITCODE -ne 0) { throw 'The build failed.' }

$collector = Join-Path $install 'Common7\IDE\Extensions\Microsoft\CodeCoverage.Console\Microsoft.CodeCoverage.Console.exe'
if (-not (Test-Path $collector)) {
    $tool = Get-Command dotnet-coverage -ErrorAction SilentlyContinue
    if (-not $tool) { throw 'No collector: neither Microsoft.CodeCoverage.Console nor dotnet-coverage.' }
    $collector = $tool.Source
}

# One measured run for each format: the collector writes one at a time.
foreach ($report in @(@{ Format = 'xml'; File = 'coverage\coverage.xml' }, @{ Format = 'cobertura'; File = 'coverage\coverage.cobertura.xml' })) {
    & $collector collect --nologo --disable-console-output -f $report.Format -o $report.File build\thermostat.exe
    if ($LASTEXITCODE -ne 0) { throw "thermostat_test failed its check on line $LASTEXITCODE" }
    if (-not $Local) {
        $text = [IO.File]::ReadAllText((Join-Path $root $report.File))
        $text = [regex]::Replace($text, [regex]::Escape($root) + '([^"<]*)', {
            param($found) '/work/samples/cpp-msvc' + $found.Groups[1].Value.Replace('\', '/')
        }, 'IgnoreCase')
        [IO.File]::WriteAllText((Join-Path $root $report.File), $text, (New-Object Text.UTF8Encoding $false))
    }
}

$cl = (cmd /c "`"$vcvars`" >nul 2>&1 && cl 2>&1" | Select-Object -First 1) -replace '^.*Version\s+([\d.]+).*$', '$1'
@(
    "- MSVC $cl"
    "- $(Split-Path -Leaf $collector) $((Get-Item $collector).VersionInfo.ProductVersion)"
) | Set-Content -Encoding utf8 coverage\VERSIONS.txt

Write-Host 'Wrote coverage/ (Microsoft collector: XML and Cobertura).'
