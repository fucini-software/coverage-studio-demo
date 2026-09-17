# Python sample

A small double-entry ledger with three test classes, measured by coverage.py with
branch coverage on: 81% of `ledger.py` and 72% of `reconcile.py` by the tool's own count.

coverage.py records *whether* a line ran, never how often. The extension knows
that about this format: the hover says **Covered**, not "1 hit", and the
annotated source shows `✓` where other formats show a count.

| Where | What the tests leave behind | What shows it |
| --- | --- | --- |
| `ledger.py` line 40, `post` | nothing is ever posted to a closed ledger | uncovered line, half-taken `if` on line 39 |
| line 73, `classify` | no amount reaches the last band | the final `return` uncovered |
| line 83, `close` | an unbalanced ledger is never closed | the exception path uncovered |
| lines 105 to 108, `export_csv` | never called | 0% CodeLens, dead-code warning |
| `debug_dump` | `# pragma: no cover` | grey `excl` rows in the annotated source |
| `reconcile.py` lines 26 to 27, `parse_amount` | every amount is well formed | an `except` that never fires |
| line 44, `find_entry` | the search always succeeds | the `else` of a `for` loop never runs |
| lines 58 to 59, `settle` | the ledger already balances | a `while` that is never entered |
| lines 73 and 78, `unmatched` | never an empty statement, never a miss | a guard and a result nobody triggers |
| `archive.py` | imported by nothing | not in the report at all: unmeasured, not uncovered |

Every file carries a Doxygen header, and every class, method and function is
documented with `@param`, `@return` and a note on why its gap is deliberate;
doxygen runs over the sample without a warning.

## The reports

> Not committed yet: they are written by the first run of the lab image, so
> that the paths inside them are the image's `/work/...` and not somebody's
> home directory. Until then, `sh generate.sh` produces them locally.

- `coverage/coverage.json`: coverage.py JSON, loaded by default. Written with
  `--show-contexts`, and [`.coveragerc`](.coveragerc) sets
  `dynamic_context = test_function`, so the report says for every line which
  tests ran it. Hover a line's hit count in `ledger/ledger.py` (Coverage Studio
  0.2026.83): **Tests that ran this line:** `ClosingTests.test_a_balanced_ledger_closes`,
  `PostingTests.test_post_and_balance`.
- `coverage/coverage.xml`, `coverage/lcov.info`: the same run as Cobertura and LCOV.
- `coverage/posting/`, `coverage/closing/` and `coverage/reconcile/`: each test
  class on its own. Only `ClosingTests` reaches `close` and `memo_index`, and
  only `ReconcileTests` loads `reconcile.py` at all.

## Regenerating

```sh
docker buildx bake -f docker/docker-bake.hcl python    # once, from the repository root
docker run --rm -v "$PWD:/work" coverage-studio-lab:python samples/python/generate.sh
```

Or without the image: `pip install coverage`, then `sh generate.sh`.
