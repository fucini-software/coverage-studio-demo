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

### Why `buffer_can_write` is the one to look at

Its decision — `(b->count < b->capacity && !b->locked) || force` — is only ever
reached with `force` set. So the line runs, the decision is taken, and line
coverage reports it as covered. MC/DC reports **0 of 3 conditions**, because
none of them was ever shown to change the outcome on its own.

That gap is invisible to every other metric, and it is the reason ISO 26262
asks for MC/DC at ASIL C/D and IEC 61508 at SIL 3/4. `gate` in `calc.c` is the
same shape of decision tested properly, so the report shows one of each.

## Open it

1. Install **Fucini Coverage Studio Pro**, if you haven't already.
2. Open this folder (or `coverage-studio-demo.code-workspace`) in VS Code.
3. Coverage loads automatically from [`samples/c/coverage/coverage.json`](samples/c/coverage/coverage.json)
   (watch mode is on). If not, run **`Fucini Coverage: Load Coverage`**.
4. Open [`samples/c/src/calc.c`](samples/c/src/calc.c) or [`samples/c/src/buffer.c`](samples/c/src/buffer.c) — gutters,
   CodeLens and the status bar appear right away, no build step needed.
   The demo's [`.vscode/settings.json`](.vscode/settings.json) switches the
   gutter to its heatmap and puts the hit count after each line; out of the
   box the gutter shows only findings, and the colour-coded view of a file is
   **Open Annotated Source**.

From there, try opening `gate`'s decision on line 23 to see the MC/DC hover
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
- `samples/c/coverage/coverage.xml` — Cobertura. Point `fuciniCoverage.coverageFile.paths`
  at more than one to see a deterministic **merge** of formats into one run.
- `samples/c/coverage/per-test.info` — LCOV with one section per test: the calc half and
  the buffer half of `samples/c/src/calc_test.c`, each built and run on its own
  (`TN:calc`, `TN:buffer`). Point `fuciniCoverage.coverageFile.paths` at it to
  filter coverage **by test** in VS Code's Test Coverage view, or load it
  beside `lcov.info` to see which report covered each line.

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
so the two never drift apart. The per-test option builds the test program twice
more, once per half of the suite, so each `TN:` section is a real run of that
half rather than numbers split out of the combined one.
