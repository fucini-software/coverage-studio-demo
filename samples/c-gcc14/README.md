# C sample, gcc 14 condition coverage

A smoke alarm's two decisions, built with gcc's `-fcondition-coverage`: the
sample for **condition coverage**, the measure between branch coverage and
MC/DC that gcc 14 added and that gcov writes with `--conditions`.

Branch coverage asks whether each decision went both ways. Condition coverage
asks more: whether each *operand* of the decision was seen true and seen
false. The suite in `tests/test_alarm.c` takes both decisions both ways, so
every branch is covered, and still leaves one outcome of one operand unseen in
each:

| Where | What the tests leave behind | What shows it |
| --- | --- | --- |
| `alarm.c`, `alarm_should_sound` | `(smoke && armed) \|\| testing`: the alarm is never armed without smoke | a mark on the `if`, the hover: `C2 false: not taken` — `armed` never seen false |
| `alarm.c`, `alarm_escalate` | `(sustained \|\| hot) && !silenced`: nobody ever silences it | the hover: `C3 true: not taken` — `silenced` never seen true |

Both functions read 100% by lines and 100% by branches. The Coverage view's
*Conditions* column, the function CodeLens and *Check Coverage Thresholds*
(`fuciniCoverage.threshold.conditions`) are where the shortfall shows; a
report without condition data leaves that gate unjudged.

## What opening it shows

`.vscode/settings.json` loads `coverage/*.gcov.json.gz` — gcov writes one JSON
per translation unit, named after the source — and maps the lab's
`/work/samples/c-gcc14` back to the clone. Open `src/alarm.c`: the gutter is
green on every line, and each decision line carries the condition mark; hover
it for the operand and the outcome never seen.

## The report

- `coverage/alarm.gcov.json.gz`: gcov's JSON (`--json-format --conditions`)
  for `src/alarm.c`. Beside each decision, `conditions` says how many outcomes
  there are, how many were seen, and which operands were never true or never
  false. gcov's text format (`alarm.c.gcov`, with `--conditions`) says the
  same in prose and is read too.

## Regenerating

```sh
docker buildx bake -f docker/docker-bake.hcl c    # once, from the repository root
docker run --rm -v "$PWD:/work" coverage-studio-lab:c-gcc14 samples/c-gcc14/generate.sh
```

Or without the image, with gcc 14 or newer and its gcov on PATH: `sh
generate.sh`. On Windows a MinGW-w64 gcc of that age does it as well; the
committed report was first written that way, and the lab rewrites it with
Debian's gcc 14.
