# .NET console app

A console app with no tests at all: the sample for **Run App with
Coverage…**, which measures what a person reaches by running the program
rather than what a suite reaches. Started as it is, `Shop` prices three orders
and exits.

| Where | What a plain run leaves behind | What shows it |
| --- | --- | --- |
| `Program.cs`, `Main` | three orders of 40, 75 and 99 | green, `×1`; the loop body `×3` |
| `Program.cs`, `Price` | none of the three is above a hundred | the discount's `return` is red; the `if` amber, taken one way |
| `Program.cs`, `Refund` | never called | 0% CodeLens, dead-code warning |

## What opening it shows

`.vscode/settings.json` loads `coverage/app/coverage.cobertura.xml`, one plain
run of the app under Microsoft's `dotnet-coverage`, and maps the lab's
`/work/samples/dotnet-app` back to the clone. Open `src/Shop/Program.cs`: the
run's reach is in the gutter from the first open.

Then run **Run App with Coverage…** (in Visual Studio, *Tools → Coverage
Studio*; `Shop.sln` is the solution to open). The app starts in a console
window of its own under the collector:

```text
dotnet-coverage collect -f cobertura -o "coverage/app/coverage.cobertura.xml" dotnet run --project "src/Shop/Shop.csproj"
```

When it exits the report is written over the committed one and the editor
reloads it. Change `Main` to price an order of 120 and run again: the
discount turns green and the file's percentage moves — coverage of what you
did, not of what a test did.

## The report

- `coverage/app/coverage.cobertura.xml`: Microsoft's collector, Cobertura
  format, with a column range per statement.

## Regenerating

```sh
docker buildx bake -f docker/docker-bake.hcl dotnet    # once, from the repository root
docker run --rm -v "$PWD:/work" coverage-studio-lab:dotnet-app samples/dotnet-app/generate.sh
```

Or without the image, with the .NET 10 SDK and
`dotnet tool install -g dotnet-coverage`: `sh generate.sh`.
