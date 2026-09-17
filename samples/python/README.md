# Python sample

A small double-entry ledger with two test classes, measured by coverage.py with
branch coverage on. 81% of `ledger.py` by the tool's own count.

coverage.py records *whether* a line ran, never how often. The extension knows
that about this format: the hover says **Covered**, not "1 hit", and the
annotated source shows `✓` where other formats show a count.

| Where | What the tests leave behind | What shows it |
| --- | --- | --- |
| `ledger.py` line 20, `post` | nothing is ever posted to a closed ledger | uncovered line, half-taken `if` on line 19 |
| line 43, `classify` | no amount reaches the last band | the final `return` uncovered |
| line 48, `close` | an unbalanced ledger is never closed | the exception path uncovered |
| lines 61 to 64, `export_csv` | never called | 0% CodeLens, dead-code warning |
| `debug_dump` | `# pragma: no cover` | grey `excl` rows in the annotated source |
| `archive.py` | imported by nothing | not in the report at all: unmeasured, not uncovered |

## The reports

> Not committed yet: they are written by the first run of the lab image, so
> that the paths inside them are the image's `/work/...` and not somebody's
> home directory. Until then, `sh generate.sh` produces them locally.

- `coverage/coverage.json`: coverage.py JSON, loaded by default.
- `coverage/coverage.xml`, `coverage/lcov.info`: the same run as Cobertura and LCOV.
- `coverage/posting/` and `coverage/closing/`: each test class on its own.
  Only `ClosingTests` reaches `close` and `memo_index`.

## Regenerating

```sh
docker buildx bake -f docker/docker-bake.hcl python    # once, from the repository root
docker run --rm -v "$PWD:/work" coverage-studio-lab:python samples/python/generate.sh
```

Or without the image: `pip install coverage`, then `sh generate.sh`.
