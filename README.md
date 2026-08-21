# Fucini Coverage Studio Pro — Demo Workspace

A tiny, self-contained C project that lets you see **Fucini Coverage Studio
Pro** working immediately, with no setup of your own. It ships with
ready-made coverage data covering a mix of states, so you can explore most of
the extension's features in a couple of minutes:

| Function | State | Shows off |
| --- | --- | --- |
| `add`, `subtract` | fully covered | green gutters + hit counts |
| `classify` | partial | red gutter on the untested `else` (line 17) |
| `gate` | partial branch / MC/DC | branch & MC/DC hover, margin gutter |
| `unused_helper` | never called | dead-code warning, 0% CodeLens |

## Open it

1. Install **Fucini Coverage Studio Pro**, if you haven't already.
2. Open this folder (or `coverage-studio-demo.code-workspace`) in VS Code.
3. Coverage loads automatically from [`coverage/lcov.info`](coverage/lcov.info)
   (watch mode is on). If not, run **`Fucini Coverage: Load Coverage`**.
4. Open [`src/calc.c`](src/calc.c) — gutters, CodeLens and the status bar
   appear right away, no build step needed.

From there, try opening `gate`'s decision on line 23 to see the MC/DC hover
breakdown, or run **`Fucini Coverage: Generate Full HTML Report`** to see the
self-rendered report. The overall run is **NON-COMPLIANT** out of the box
(thresholds default to 100%) — lower a threshold in settings
(`fuciniCoverage.threshold.*`) to see it flip to COMPLIANT.

## Ready-made tracefiles

Two formats are included, so everything above works with no compiler toolchain
installed:

- `coverage/lcov.info` — LCOV (loaded by default).
- `coverage/coverage.xml` — Cobertura, over the **same** source. Point
  `fuciniCoverage.coverageFile.paths` at both to see a deterministic
  **merge** of two formats into one run.

## Regenerating coverage yourself (optional)

If you have a C toolchain installed, you can regenerate the tracefiles from
source instead of using the bundled ones — useful for seeing the richer
llvm-cov output (regions, C++ instantiations and real **MC/DC**):

```bash
# macOS/Linux
./scripts/gen-coverage.sh clang   # -> coverage/coverage.json (llvm-cov + MC/DC)
./scripts/gen-coverage.sh gcc     # -> coverage/lcov.info
```

```powershell
# Windows
.\scripts\gen-coverage.ps1 clang
.\scripts\gen-coverage.ps1 gcc
```

Then set `"fuciniCoverage.coverageFile.paths": ["coverage.json"]` to load the
llvm-cov output instead.
