# Fucini Coverage Studio Pro — Demo Workspace

A tiny, self-contained C project that lets you see **Fucini Coverage Studio
Pro** working immediately, with no setup of your own. It ships with
ready-made coverage data covering a mix of states, so you can explore most of
the extension's features in a couple of minutes:

| Function | File | State | Shows off |
| --- | --- | --- | --- |
| `add`, `subtract` | `calc.c` | fully covered | heatmap gutter + inline `×1` hit counts |
| `classify` | `calc.c` | partial | red bar on the untested `else`, amber on the half-taken `if` |
| `gate` | `calc.c` | **MC/DC satisfied** | every condition shown to matter on its own — 3/3 |
| `unused_helper` | `calc.c` | never called | dead-code warning, 0% CodeLens |
| `buffer_init`, `buffer_push` | `buffer.c` | covered, both outcomes | branch coverage on a bounds check |
| `buffer_can_write` | `buffer.c` | **MC/DC 0%** | the interesting one — see below |
| `buffer_drain` | `buffer.c` | never called | second entry in the never-called table |
| `sensor_clamp` | `sensor.c` | covered line, **uncovered region** | the `hi` arm of a ternary in red on a line that ran; only a format with columns can show it |
| `sensor_average` | `sensor.c` | guard never fires | uncovered `return`, half-taken decision, MC/DC 0/2; and the hot loop, ×1 001 |
| `sensor_state` | `sensor.c` | `switch` half tested | `case 2` and the `default` never run |
| `sensor_alarm` | `sensor.c` | **MC/DC 2 of 3** | two conditions proven, `override` never shown to matter |
| `sensor_flush` | `sensor.c` | called, loop never entered | function covered, body uncovered, even the `i++` is a region that never ran |

### Why `buffer_can_write` is the one to look at

Its decision — `(b->count < b->capacity && !b->locked) || force` — is only ever
reached with `force` set. So the line runs, the decision is taken, and line
coverage reports it as covered. MC/DC reports **0 of 3 conditions**, because
none of them was ever shown to change the outcome on its own.

That gap is invisible to every other metric, and it is the reason ISO 26262
asks for MC/DC at ASIL C/D and IEC 61508 at SIL 3/4. `gate` in `calc.c` is the
same shape of decision tested properly, and `sensor_alarm` in `sensor.c` sits
between the two at 2 of 3, so the report shows one of each.

## Open it

1. Install **Fucini Coverage Studio Pro**, if you haven't already.
2. Open this folder (or `coverage-studio-demo.code-workspace`) in VS Code.
3. Coverage loads automatically from [`samples/c/coverage/coverage.json`](samples/c/coverage/coverage.json)
   (watch mode is on). If not, run **`Fucini Coverage: Load Coverage`**.
4. Open [`samples/c/src/calc.c`](samples/c/src/calc.c), [`samples/c/src/buffer.c`](samples/c/src/buffer.c) or
   [`samples/c/src/sensor.c`](samples/c/src/sensor.c) — gutters,
   CodeLens and the status bar appear right away, no build step needed.
   The demo's [`.vscode/settings.json`](.vscode/settings.json) switches the
   gutter to its heatmap and puts the hit count after each line; out of the
   box the gutter shows only findings, and the colour-coded view of a file is
   **Open Annotated Source**.

From there, try opening `gate`'s decision on line 31 of `calc.c` to see the MC/DC hover
breakdown, or run **`Fucini Coverage: Generate Full HTML Report`** to see the
self-rendered report. The overall run is **NON-COMPLIANT** out of the box
(thresholds default to 100%) — lower a threshold in settings
(`fuciniCoverage.threshold.*`) to see it flip to COMPLIANT.

## Ready-made tracefiles

Four tracefiles are included, so everything above works with no compiler
toolchain installed:

- `samples/c/coverage/coverage.json` — llvm-cov JSON (loaded by default). The only one
  of the three that carries regions, instantiations and **MC/DC**.
- `samples/c/coverage/lcov.info` — LCOV, exported from the *same* build, so it describes
  identical code measured by a format that cannot express MC/DC. Switch to it
  to see exactly what those metrics stop telling you.
- `samples/c/coverage/coverage.xml` — Cobertura, written from that same run by
  Coverage Studio's own **Export as Cobertura**. Point `fuciniCoverage.coverageFile.paths`
  at more than one to see a deterministic **merge** of formats into one run.
- `samples/c/coverage/per-test.info` — LCOV with one section per test: the calc, buffer
  and sensor parts of `samples/c/src/calc_test.c`, each built and run on its own
  (`TN:calc`, `TN:buffer`, `TN:sensor`). Point `fuciniCoverage.coverageFile.paths` at it to
  filter coverage **by test** in VS Code's Test Coverage view, or load it
  beside `lcov.info` to see which report covered each line.

[`samples/c-cross-check`](samples/c-cross-check) has two more: the same source
built by clang (`clang.json`) and by GCC (`gcc/bits.gcov.json.gz`), which
disagree about which half of a function ran. Its settings **combine** them —
`agree`, covered only where both builds ran a line, with the disagreements in
teal; or `union`, covered where either did. See its
[README](samples/c-cross-check/README.md) for when to use which.

Three samples are there for one feature each: [`samples/c-gcc14`](samples/c-gcc14)
for gcc 14's **condition coverage** (which operand of a decision was never
seen true or false — gcov's JSON with `--conditions`), [`samples/dotnet`](samples/dotnet)
with a **Stryker.NET mutation report** beside its coverage, which marks the
surviving mutants in `Quote.cs` and is what *Run Mutation Tests Here* writes
for one function, and [`samples/dotnet-app`](samples/dotnet-app), a console app
with no tests, for ***Run App with Coverage…***: what a person reaches by
running the program.

## On the command line

The same reader runs without an editor: `npm install -g fucini-coverage`
(free; Windows, Linux, WSL and macOS). Every sample's `.vscode/settings.json`
is read as the editors read it, so from a sample's folder the reports load by
themselves:

```sh
cd samples/c
fucini-coverage summary                              # the totals and every file
fucini-coverage check --lines 80 --branches 70       # exit 1 below a threshold: the gate for a pipeline
fucini-coverage export --format markdown --stdout    # the summary for a pull request
fucini-coverage compare --baseline coverage/lcov.info coverage/coverage.json
fucini-coverage report --out coverage-report         # the HTML report; open index.html
cd ../dotnet
fucini-coverage check --lines 50 --mutation 40       # the mutation score of the Stryker report is a gate too
fucini-coverage mcp                                  # the six tools for an AI agent, over this run
```

`fucini-coverage help <command>` explains each; the full page is
[fucini-coverage on npm](https://www.npmjs.com/package/fucini-coverage). The
tasks `cli: summary…` and `cli: check…` run the first two on the sample you
pick.
## Regenerating coverage yourself (optional)

If you have a C toolchain installed, you can regenerate the tracefiles from
source instead of using the bundled ones — useful for seeing the richer
llvm-cov output (regions, C++ instantiations and real **MC/DC**):

```bash
# macOS/Linux
./samples/c/scripts/gen-coverage.sh clang   # -> coverage/coverage.json (llvm-cov + MC/DC)
./samples/c/scripts/gen-coverage.sh gcc     # -> coverage/lcov.info
./samples/c/scripts/gen-coverage.sh clang --per-test   # also coverage/per-test.info
```

```powershell
# Windows
.\samples\c\scripts\gen-coverage.ps1 clang
.\samples\c\scripts\gen-coverage.ps1 gcc
.\samples\c\scripts\gen-coverage.ps1 clang -PerTest    # also coverage\per-test.info
```

The clang mode writes `coverage.json` and `lcov.info` together, from one run,
so the two never drift apart. The per-test option builds the test program three
times more, once per part of the suite, so each `TN:` section is a real run of
that part rather than numbers split out of the combined one.

## The tasks, and what they need

[`.vscode/tasks.json`](.vscode/tasks.json) has a task per sample — **Terminal →
Run Task…**, or `Ctrl+Shift+B` for the C sample under clang — plus the test
runs alone and the lab. Each coverage task writes into its sample's `coverage/`
folder, which that sample's settings watch, so the editor reloads by itself.
None of this is needed to *look* at the demo: the reports are committed. It is
needed to regenerate them.

One install of **Visual Studio 2026** covers most of it, any edition, with the
workloads named below. Only the GCC side and Docker come from elsewhere.

| Task | What it runs | Where that comes from |
| --- | --- | --- |
| `coverage: C (clang, …)`, the clang half of `C cross-check`, `C++ (clang++, …)` | `clang`, `llvm-profdata`, `llvm-cov`, and the MSVC libraries clang links its profile runtime against | *Desktop development with C++* with its *C++ Clang Compiler for Windows* component. MC/DC needs clang 18 or newer, which it is. The installer does not put `VC\Tools\Llvm\x64\bin` on PATH; do that yourself. |
| `coverage: C++ MSVC` | `cl`, `link /PROFILE`, Microsoft's code coverage collector | *Desktop development with C++*. The collector ships with the Enterprise edition; on the others the script uses `dotnet tool install -g dotnet-coverage`, the same collector. |
| `coverage: .NET`, `coverage: Visual Basic`, `test: .NET`, `test: Visual Basic` | `dotnet` with the .NET 10 SDK; Coverlet is a package reference of the test projects | *.NET desktop development*. |
| `coverage: .NET console app`, `mutation: .NET` | `dotnet` with the .NET 10 SDK; `dotnet-coverage` for the app, `dotnet-stryker` for the mutation run (`dotnet tool install -g …`); `sh` for the scripts | as above |
| `coverage: C gcc 14` | `gcc` 14 or newer and its `gcov`, with `sh` for `generate.sh` | Not in Visual Studio: MinGW-w64 GCC, as for `coverage: C (gcc)` |
| `coverage: JavaScript`, `coverage: TypeScript`, `test: JavaScript`, `test: TypeScript` | `node` 20 or newer and `npm` | *Node.js development*, or nodejs.org. |
| `coverage: Python`, `test: Python` | `python` 3 with the `coverage` package (`pip install coverage`) | *Python development*, or python.org. |
| `coverage: JavaScript`, `coverage: Python`, `lab: …` | a POSIX `sh` for the `generate.sh` scripts, taken from Git Bash | the *Git for Windows* component, or gitforwindows.org. The tasks expect `C:\Program Files\Git\bin\bash.exe`; four lines in `tasks.json` say where. |
| `coverage: C (gcc)`, the GCC half of `C cross-check` | `gcc` and `gcov`; `lcov` too for the C sample | Not in Visual Studio: MinGW-w64 GCC (MSYS2 or WinLibs) and `lcov` (MSYS2 packages it), both on PATH. |
| `lab: …` | `docker` with BuildKit, and `sh` | Docker Desktop. The images hold every toolchain above, Linux side, so a machine with Docker and Git Bash alone regenerates everything. `docker-bake.hcl` tags no `cpp` or `ts` image: tag the `c` image as `cpp` and the `js` image as `ts` before regenerating those two. |