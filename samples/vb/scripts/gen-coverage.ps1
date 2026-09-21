<#
.SYNOPSIS
  Regenerate the Visual Basic sample's reports (Windows, .NET 10 SDK).

.DESCRIPTION
    .\scripts\gen-coverage.ps1         # -> coverage\coverage.opencover.xml  Coverlet, OpenCover format
                                       #    coverage\coverage.cobertura.xml  the same run as Cobertura

  Works from any directory: it moves to the sample's root itself.

  Every report is then made to speak of /work/samples/vb/..., which is where
  the lab image mounts this repository and what generate.sh writes there: the
  reports are committed, and somebody's drive letter has no business in them.
  The sample's .vscode/settings.json maps that prefix back to wherever the
  repository is checked out. -Local leaves the paths as they came.

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
if (Test-Path coverage) { Get-ChildItem coverage -File | ForEach-Object { [IO.File]::Delete($_.FullName) } }
New-Item -ItemType Directory -Force -Path coverage | Out-Null

dotnet test test\Payroll.Tests -p:CollectCoverage=true "-p:CoverletOutputFormat=opencover%2ccobertura" "-p:CoverletOutput=$root\coverage\"
if ($LASTEXITCODE -ne 0) { throw 'The tests failed.' }

if (-not $Local) {
    foreach ($report in 'coverage\coverage.opencover.xml', 'coverage\coverage.cobertura.xml') {
        $file = Join-Path $root $report
        $text = [IO.File]::ReadAllText($file)
        # The absolute paths first, then Cobertura's file names, which are
        # relative to its <source> and keep the backslashes of where they were written.
        $text = [regex]::Replace($text, [regex]::Escape($root) + '([^"<]*)', {
            param($found) '/work/samples/vb' + $found.Groups[1].Value.Replace('\', '/')
        }, 'IgnoreCase')
        $text = [regex]::Replace($text, 'filename="([^"]*)"', { param($found) 'filename="' + $found.Groups[1].Value.Replace('\', '/') + '"' })
        # Coverlet's Cobertura names the drive as the source and the rest of
        # the way as part of every file name.
        $below = $root.Substring([IO.Path]::GetPathRoot($root).Length).Replace('\', '/')
        $text = $text.Replace('<source>' + [IO.Path]::GetPathRoot($root) + '</source>', '<source>/work/samples/vb/</source>')
        $text = $text.Replace('filename="' + $below + '/', 'filename="')
        [IO.File]::WriteAllText($file, $text, (New-Object Text.UTF8Encoding $false))
    }
}

$coverlet = ([xml](Get-Content test\Payroll.Tests\Payroll.Tests.vbproj)).Project.ItemGroup.PackageReference | Where-Object Include -eq 'coverlet.msbuild'
@(
    "- dotnet $(dotnet --version)"
    "- coverlet.msbuild $($coverlet.Version)"
) | Set-Content -Encoding utf8 coverage\VERSIONS.txt

Write-Host 'Wrote coverage/ (OpenCover, Cobertura).'
