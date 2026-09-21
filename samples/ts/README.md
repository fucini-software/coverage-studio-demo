# TypeScript sample

A library's lending desk with two test suites, run by vitest and measured by
Istanbul. By lines `loan.ts` looks nearly finished: 16 of 19. By branches it is
half done, 8 of 16, and that difference is what this sample is for.

The reports speak of the `.ts` files and of nothing else. What was instrumented
is the JavaScript that esbuild made of them; the source maps carry every
position back, so a column in the report is a column in the file you are
looking at.

| Where | What the tests leave behind | What shows it |
| --- | --- | --- |
| `loan.ts` line 47, `assertNever` | the compiler's proof that a `switch` is complete | never called, and rightly: lines 48 and 67 are the red that no test should turn green |
| `loan.ts` line 60, `loanDays` | nobody borrows a tool | `case 3: not taken` (and `case 4`, the `default`), line 65 uncovered inside a covered `switch` |
| `loan.ts` line 79, `dueDate` | every caller passes the days | `default value: not taken` |
| `loan.ts` line 91, `contactOf` | a `??` fallback that is never needed | `operand 2: not taken` |
| `loan.ts` line 105, `canBorrow` | `!a && (b \|\| c)` where `c` is never even evaluated | `operand 3: not taken` |
| `loan.ts` line 116, `renew` | an `if` with no `else`, always taken | `else: not taken`, the implicit arm nobody wrote |
| `loan.ts` line 132, `receipt` | the line runs, the arrow function on it never does | annotated source: `loan.item.title` in red on a covered line |
| `loan.ts` line 144, `checksum` | a loop over the whole catalogue | inline hit counts of 12 000 |
| `loan.ts`, `debugDump` | `/* istanbul ignore next */` | absent from every total |
| `fees.ts`, `lateFee` | a dozen decisions, one path through them | 12 of 21 lines, 11 of 23 branches, and the CRAP score that follows |
| `fees.ts` line 70, `waivable` | `a && (b \|\| c)` where `c` is never even evaluated | `operand 3: not taken` |
| `catalogue.ts` line 29, constructor | a default parameter value nobody relies on | `default value: not taken` |
| `catalogue.ts` line 43, `available` | a `??` fallback that is never needed | `operand 2: not taken` |
| `catalogue.ts` line 56, `take` | the shelf is never empty | the refusal uncovered |
| `catalogue.ts` line 75, `restock` | the supplier always answers | a `catch` that exists only on paper |
| `catalogue.ts` line 81, `outOfStock` | a getter nobody reads | never called: it looks like data and is a function |
| `catalogue.ts` line 91, `fromJSON` | a static method nobody calls | never called |
| `catalogue.ts` line 115, `pick<T>` | a generic that always finds what it looks for | the last line never reached |
| `legacy-import.ts` | imported by nothing | not in the report at all: unmeasured, not uncovered |

What TypeScript adds leaves no trace, and should not: interfaces, type aliases
and `import type` are erased before anything runs, so they are neither covered
nor uncovered. `loan.ts` begins with a member, an item and a loan, none of which
has a mark in the margin; the first is on line 38, the first line that does
anything.

Every source file carries a TSDoc header and documents its parameters and
return values, and says on the function itself why its gap is deliberate.

## The reports

All written by one run of `scripts/gen-coverage.mjs`:

- `coverage/coverage-final.json`: Istanbul JSON, loaded by default. The only
  one here with statement columns and branch types.
- `coverage/lcov.info`, `coverage/clover.xml`,
  `coverage/cobertura-coverage.xml`: the same run in three poorer formats.
- `coverage/unit/` and `coverage/integration/`: each suite on its own. Only the
  integration suite reaches `lateFee`.

Whichever machine writes them, the paths inside read `/work/samples/ts/...`,
which is where the lab image mounts this repository; the `pathRemap` entry in
`.vscode/settings.json` maps that back to wherever it is checked out. The
reports are committed, and somebody's home directory has no business in them.

## Regenerating

With Node 20 or newer, on any platform:

```sh
npm ci
npm run coverage            # add `-- --local` to keep this machine's own paths
```

Or in the lab image, which has Node in its `js` target:

```sh
docker buildx bake -f docker/docker-bake.hcl js    # once, from the repository root
docker run --rm -v "$PWD:/work" coverage-studio-lab:js samples/ts/generate.sh
```

With `fuciniCoverage.watch.enabled` on, as it is here, the editor reloads the
moment the run has finished. Give `loanDays` a test that borrows a tool, run it
again, and watch line 65 change colour.

## In Visual Studio

Open this folder (*File → Open → Folder*). There is no project file to open and
none is needed: Visual Studio's TypeScript support reads `tsconfig.json`, and
the coverage is found through the same `.vscode/settings.json`.
