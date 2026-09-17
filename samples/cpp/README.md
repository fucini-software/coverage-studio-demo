# C++ sample: one file, every metric

Open [`src/gearbox.cpp`](src/gearbox.cpp) and hover the coverage item in the
status bar. It lists **nine** metrics for this one file, because four reports
describe it and Coverage Studio merges them into one record:

| Metric | Value | From | What the tests leave behind |
| --- | --- | --- | --- |
| Functions | 3 / 6 | llvm-cov | `fuel_ratio` and `limp_home` never called, and one template instantiation never run |
| Lines | 14 / 22 | llvm-cov | the bodies of those, and the low clamp |
| Regions | 17 / 21 | llvm-cov | the `current - 1` arm of the ternary on line 42, a line that ran |
| Branches | 4 / 10 | llvm-cov | `next_gear` only ever shifts up |
| MC/DC | 2 / 3 | llvm-cov | line 34: `manual` is never shown to matter |
| Instantiations | 3 / 6 | llvm-cov | `clamp_to<double>` is compiled and never executed |
| Function calls | 1 / 2 | TRACE32 call export | the call in `fuel_ratio` is never exercised |
| Object code | 148 / 236 bytes | TRACE32 object export | instruction bytes that never ran |
| Mutation score | 5 / 12 | mutation report | boundary mutants survive: no check sits on a boundary |

The same nine appear in the Coverage view (tooltip, and columns when the panel
is wide), in **Open Annotated Source** (badges), and in both HTML reports
(columns and legend).

## Which of these reports are real

- **`coverage/coverage.json` is real.** `scripts/gen-coverage.ps1` and
  `generate.sh` produce it with clang, `-fcoverage-mcdc` and `llvm-cov export`.
  The six metrics it carries are measurements.
- **`coverage/trace32-call.xml`, `coverage/trace32-object.xml` and
  `coverage/mutation.json` are illustrative.** They are written by hand in the
  real schemas (Lauterbach's `COVerage.EXPORT.ListModule`, and the
  mutation-testing-elements JSON that Stryker and Mull emit), and each says so
  in its first lines. The call count and every mutant's status are reasoned
  from the sources and the tests; the object-code byte counts are plausible and
  were not measured. They exist so that one file can show every metric the
  extension knows. The plan is to replace them with a real TRACE32 simulator
  export and a real Mull run.

Remove any of the three from `fuciniCoverage.coverageFile.paths` in
[`.vscode/settings.json`](.vscode/settings.json) and its row, column and badge
disappear: a metric a report does not carry is never shown.

## Things to try

- The weights of the composite score are written out in the settings. Object
  code and mutation score are `0`, so they are shown and not scored. Set
  `fuciniCoverage.whmWeights.mutation` to `2` and the score of `gearbox.cpp`
  drops.
- TRACE32 names *modules*, not files. The `pathRemap` rule from `gearbox` to
  `src/gearbox.cpp` is what lets its figures land on the source file.

## Regenerating

```powershell
.\scripts\gen-coverage.ps1      # Windows, LLVM/Clang 18+ on PATH
```

```sh
docker buildx bake -f docker/docker-bake.hcl c     # once, from the repository root
docker run --rm -v "$PWD:/work" coverage-studio-lab:c samples/cpp/generate.sh
```

The sources include no standard-library header, so a bare compiler is enough.
