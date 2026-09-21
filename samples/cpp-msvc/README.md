# C++ sample, built by MSVC

A room thermostat, built by the Microsoft compiler and measured by Microsoft's
own collector: the C++ most people have in Visual Studio. This is the sample
for **what a binary-instrumenting collector can and cannot say**. It knows
nothing of decisions, conditions or MC/DC; it counts blocks of machine code and
says of every line whether it ran, ran by half, or never did.

[`samples/cpp`](../cpp) is the same kind of code measured by clang and
llvm-cov, which can say everything. Open both.

| Where | What the tests leave behind | What shows it |
| --- | --- | --- |
| `thermostat.cpp`, `plausible` | nothing: inside, below and above the range | 100%, all green |
| `thermostat.cpp`, `decide` | the room never gets cold enough for frost protection | `return Demand::Frost;` in red |
| `thermostat.cpp`, `decide`, line 31 | nobody ever leaves the house, so `occupied` is never shown to matter | **nothing**: every block of the line ran, and it is green. Only MC/DC shows this, and this collector has none |
| `thermostat.cpp`, `scheduled_setpoint`, line 42 | only ever a weekday | the ternary is **partially covered**: amber, branch 1/2. In the Cobertura export of the same run it is green |
| `thermostat.cpp`, `max_burn_minutes` | `Frost` and `Fault` never asked about | two red `return`s in a `switch` |
| `thermostat.cpp`, `factory_reset` | never called | 0% lens, dead-code warning |

Every function carries a documentation comment saying what its tests leave
out, and the file headers name the author and the copyright holder.

## The reports

- `coverage/coverage.xml`: the collector's own XML, loaded by default. Blocks
  per function, and a state per line: covered, partially covered, not covered.
- `coverage/coverage.cobertura.xml`: the same run as Cobertura. A partially
  covered line is a covered line there.

Neither has a hit count: the collector records that a block ran, not how
often.

## For a project of your own

Two things make a native binary measurable, and both are in
[`CMakeLists.txt`](CMakeLists.txt): full debug information (`/Zi`,
`/DEBUG:FULL`) and the linker's **`/PROFILE`** (in a `.vcxproj`: Linker >
Advanced > Profile). Without `/PROFILE` the collector runs your tests and
reports nothing, without saying why. Then:

```powershell
Microsoft.CodeCoverage.Console collect -f xml -o coverage\coverage.xml build\your_tests.exe
```

`Microsoft.CodeCoverage.Console` comes with Visual Studio 2022 17.x and 2026,
in every edition; `dotnet tool install -g dotnet-coverage` is the same
collector for a machine without Visual Studio.

## Regenerating

```powershell
.\scripts\gen-coverage.ps1
```

Windows only, as the compiler is: needs the *Desktop development with C++*
workload. There is no lab image for this sample for the same reason.
