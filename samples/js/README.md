# JavaScript sample

A shopping cart with two test suites, measured by Istanbul (`nyc`). By lines it
looks nearly finished: `cart.js` is 95% covered. By branches it is about half
done, and that difference is what this sample is for.

| Where | What the tests leave behind | What shows it |
| --- | --- | --- |
| `cart.js` line 38, `total` | never called with a coupon | branch hover: `then: not taken` |
| `cart.js` line 50, `shippingFor` | the `default` of the `switch` never runs | `case 3: not taken`, line 55 uncovered inside a covered `switch` |
| `cart.js` line 68, `applyVat` | an `if` with no `else`, always taken | `else: not taken`, the implicit arm nobody wrote |
| `cart.js` line 91, `auditTrail` | the line runs, the lambda inside it never does | annotated source: `item.sku` in red on a covered line |
| `cart.js` line 102, `checksum` | a loop over the whole catalogue | inline hit counts near 19 000 |
| `cart.js`, `debugDump` | `/* istanbul ignore next */` | absent from every total |
| `pricing.js`, `quote` | a dozen decisions, one path through them | 55% lines, under half the branches |
| `pricing.js` line 75, `fastTrack` | `a && (b \|\| c)` where `c` never decides | `operand 3: not taken` |
| `inventory.js` lines 25 and 50 | default parameter values nobody relies on | `default value: not taken` |
| `inventory.js` line 38, `available` | a `??` fallback that is never needed | `operand 2: not taken` |
| `inventory.js` lines 52 to 53, `reserve` | never asked for more than there is | the refusal uncovered |
| `inventory.js` lines 74 to 75, `restock` | the supplier always answers | a `catch` that exists only on paper |
| `inventory.js` line 85, `lowStock` | a getter nobody reads | never called: it looks like data and is a function |
| `inventory.js` line 95, `fromJSON` | a static method nobody calls | never called |
| `legacy.js` | required by nothing | not in the report at all: unmeasured, not uncovered |

Every source file carries a JSDoc header and documents its parameters and
return values, and says on the function itself why its gap is deliberate.
## The reports

> Not committed yet: they are written by the first run of the lab image, so
> that the paths inside them are the image's `/work/...` and not somebody's
> home directory. Until then, `npm ci && npm run coverage` produces them locally.

All written by one run of `generate.sh`:

- `coverage/coverage-final.json`: Istanbul JSON, loaded by default. The only
  one here with statement columns and branch types.
- `coverage/lcov.info`, `coverage/clover.xml`,
  `coverage/cobertura-coverage.xml`: the same run in three poorer formats.
- `coverage/unit/` and `coverage/integration/`: each suite on its own. Only the
  integration suite reaches `pricing.js`.

## Regenerating

```sh
docker buildx bake -f docker/docker-bake.hcl js    # once, from the repository root
docker run --rm -v "$PWD:/work" coverage-studio-lab:js samples/js/generate.sh
```

Or without the image, with Node 20 or newer: `npm ci && npm run coverage`. The
paths inside the reports will then be your own, and the `pathRemap` entry in
`.vscode/settings.json` has nothing to do.
