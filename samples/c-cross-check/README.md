# C sample, built by two compilers

The same source and the same tests, built once with clang and once with GCC:
the sample for **combining two reports of one file** rather than letting one
of them win.

`bits_popcount()` has a fast path the compiler decides: the clang build counts
bits with `__builtin_popcount`, the GCC build with the portable loop. Both
builds pass the same tests, and each report says the other half of the
function never ran. Neither is wrong about its own build; neither is the
whole story. Real code has the same shape wherever a toolchain picks an
intrinsic, an assembler routine or a vendor library beside a fallback.

| Report | What it says of `bits.c` |
| --- | --- |
| `coverage/clang.json` (llvm-cov, with MC/DC) | line 30 ran, the loop on lines 32–36 never did; line 22 is code, line 24 is not |
| `coverage/gcc/bits.gcov.json.gz` (gcov JSON) | the loop ran, line 30 never did; line 24 is code, line 22 is not |

## What opening it shows

`.vscode/settings.json` loads both and combines them for `src/**`:

```jsonc
"fuciniCoverage.coverageFile.sources": [
  { "files": "src/**", "report": "{clang.json,bits.gcov.json.gz}", "combine": "agree" }
]
```

- **agree** (set here): a line is covered only where *both* builds ran it.
  Line 30 and the loop (lines 32, 35 and 36) are not covered, and they are
  marked in **teal**: the reports disagree there. Lines 22 and 24 are each
  measured by one build only, and count as that build says. This is the question a cross-compiler check asks —
  what did every build I ship actually exercise?
- **union**: a line is covered where *either* build ran it, so `bits.c`
  comes out fully covered. This is the question for several test suites of
  one build — unit, integration, hardware-in-the-loop — whose reports add up.
- **No `combine`**: the rule gives the file to the one report it names.

In the Coverage view the row of `bits.c` names both reports and the mode, with
`≠ 4` for the lines they disagree on; its menu has **Choose Coverage Source…**
to switch between clang, GCC, agree and union without editing the settings.
The status bar's hover card and the Annotated Source say the same, per file
and for the run.

Choosing or combining sources is part of the paid plans. On Community the
newest report wins each file, as it does with no rule at all.

## Regenerating

```powershell
.\scripts\gen-coverage.ps1
```

Needs LLVM/Clang and MinGW-w64 GCC on `PATH`, and on Windows the Visual C++
build tools, which clang's profile runtime links against. `gcov --json-format`
is used rather than LCOV so no Perl is needed.
