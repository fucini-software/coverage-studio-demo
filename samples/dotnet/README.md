# .NET sample

A pricing library with an xunit suite, measured by Coverlet. This is the sample
for **complexity and CRAP**: OpenCover and Cobertura carry a cyclomatic
complexity per method, and the extension computes a CRAP score from it
(`c² · (1 − coverage)³ + c`).

| Where | What the tests leave behind | What shows it |
| --- | --- | --- |
| `Quote.cs`, `Price` | complexity 22, walked through exactly one way | CodeLens `complexity 22, CRAP 142.2`; first row of **Riskiest Methods** in the HTML report |
| `Quote.cs`, `Shipping` | complexity 12, every case and both weight bands tested | `complexity 12, CRAP 12.0`: as complex, and no risk |
| `Quote.cs`, `WithVat` | only ever Switzerland | the second arm of its ternary never runs: branch 1/2, a partially covered line |
| `Quote.cs` line 149, `AtLeast` | never a price below the minimum | Coverlet calls it 4 of 4 lines; with `dotnet-coverage.xml` the `return minimum;` is red inside the covered line |
| `Quote.cs`, `InvoiceNumber` | never called | 0% CodeLens, dead-code warning |
| `Quote.cs`, `DebugDump` | `[ExcludeFromCodeCoverage]` | Coverlet leaves it out of the report entirely |
| `Currencies.generated.cs` | a generated table nobody tests: 0 of 28 lines | left out of every total by `fuciniCoverage.ignore.generated` (on by default); turn it off in `fucini-coverage.json` and the solution's line coverage drops from 55% to 35% |

Every type and member carries XML documentation comments, and the file header
names the author and the copyright holder.

## In Visual Studio

Open `Pricing.sln`. `fucini-coverage.json` beside it is read after
`.vscode/settings.json` — the file for a team that would rather not keep a
`.vscode` folder in a .NET repository; the VS Code edition reads it too. Then
either:

- *Tools → Coverage Studio → Collect Coverage in Test Explorer…* writes a
  `.runsettings` with Microsoft's Cobertura collector beside the solution; from
  then on every Test Explorer run writes `TestResults/<run>/*.cobertura.xml`
  under the test project, which is loaded the moment it appears — nothing hooks
  Test Explorer; or
- *Run Tests with Coverage*, which runs `dotnet test` in the Output window.
  This project references `coverlet.msbuild`, not `coverlet.collector`, so the
  run uses the collector the test SDK ships,
  `--collect:"Code Coverage;Format=cobertura"`, and nothing needs installing.

Under the tree of the Coverage window, **Risk hotspots** names `Price` first.

## The reports

> Not committed yet: they are written by the first run of the lab image, so
> that the paths inside them are the image's `/work/...` and not somebody's
> home directory. Until then, `sh generate.sh` produces them locally.

- `coverage/coverage.opencover.xml`: Coverlet in OpenCover format, loaded by
  default. Per-arm branch counts and complexity.
- `coverage/coverage.cobertura.xml`: the same run as Cobertura. Complexity
  survives; which arm of a branch was taken does not.
- `coverage/dotnet-coverage.xml`: Microsoft's collector. No complexity, but a
  column range per statement.

Coverlet's OpenCover file writes a placeholder column (`sc="1" ec="2"`) on
every point, so the extension deliberately paints no sub-line spans from it.
Load `dotnet-coverage.xml` to see those.

## Regenerating

```sh
docker buildx bake -f docker/docker-bake.hcl dotnet    # once, from the repository root
docker run --rm -v "$PWD:/work" coverage-studio-lab:dotnet samples/dotnet/generate.sh
```

Or without the image, with the .NET 10 SDK and
`dotnet tool install -g dotnet-coverage`: `sh generate.sh`.
