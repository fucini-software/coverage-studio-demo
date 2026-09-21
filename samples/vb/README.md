# Visual Basic sample

Overtime rules with an xunit suite, measured by Coverlet. This is the sample
for **what is Visual Basic's own**: operators that look alike in the source and
are not alike to a coverage tool. The tests of each pair below are the same
tests; the difference in the report is the language's.

| Where | What the tests leave behind | What shows it |
| --- | --- | --- |
| `Timesheet.vb`, `OvertimeHours` | nothing: over, under and exactly on the contract | 100%, branch 2/2 |
| `Timesheet.vb`, `Multiplier` | never a Sunday, a holiday or a night | a `Select Case` over ranges inside a `Select Case`: three red `Return`s, lens `complexity 12` |
| line 81, `IsNightShift` | only ever a shift that starts late | **`OrElse`** stops at the first operand that decides and compiles to a branch: 1/2, amber |
| line 94, `IsNightShiftEager` | the same | **`Or`** evaluates both operands always and compiles to no branch: green, complexity 1. Nothing was tested better; there is less for a tool to see |
| line 105, `MealAllowance` | only ever a long shift | the **`If()`** operator is a branch: 1/2, amber |
| line 116, `MealAllowanceEager` | the same | **`IIf`** is a function, and both results are computed before it chooses: green |
| `Timesheet.vb`, `Gross` | nobody is paid a negative wage | two red `Throw`s, guards half taken |
| `Timesheet.vb`, `ExportLine` | never called | 0% lens, dead-code warning |

Every type and member carries XML documentation comments, and the file header
names the author and the copyright holder.

## Open it

In Visual Studio, open [`Payroll.sln`](Payroll.sln) rather than the folder:
only a project gives the file its language service and its CodeLens. In VS
Code, open the folder.

## The reports

- `coverage/coverage.opencover.xml`: Coverlet in OpenCover format, loaded by
  default. Per-arm branch counts and cyclomatic complexity per method.
- `coverage/coverage.cobertura.xml`: the same run as Cobertura. Complexity
  survives; which arm of a branch was taken does not.

## Regenerating

```sh
docker run --rm -v "$PWD:/work" coverage-studio-lab:dotnet samples/vb/generate.sh
```

Or on Windows, with the .NET 10 SDK and nothing else:

```powershell
.\scripts\gen-coverage.ps1
```
