/**
 * @file Regenerate the TypeScript sample's coverage reports. Any platform, Node 20 or newer.
 *
 *   coverage/coverage-final.json   Istanbul JSON: statement columns, named branch types
 *   coverage/lcov.info             the same run as LCOV
 *   coverage/clover.xml            ... as Clover
 *   coverage/cobertura-coverage.xml ... as Cobertura
 *   coverage/unit/coverage-final.json         the unit suite alone
 *   coverage/integration/coverage-final.json  the integration suite alone
 *
 * The per-suite reports are real runs of each suite, not numbers split out of
 * the combined one.
 *
 * Every report is then made to speak of /work/samples/ts/..., which is where
 * the lab image mounts this repository, whatever machine wrote it: the reports
 * are committed, and somebody's home directory has no business in them. The
 * sample's .vscode/settings.json maps that prefix back to wherever the
 * repository is checked out. `--local` leaves the paths as they came.
 *
 * @author Mario Fucini
 * @copyright Copyright (c) 2026 Fucini Consulting. Released under the MIT
 *            License; see the LICENSE file in the repository root.
 * @license MIT
 */
import { execFileSync } from 'node:child_process';
import { existsSync, readFileSync, readdirSync, rmSync, statSync, writeFileSync } from 'node:fs';
import { dirname, join, resolve } from 'node:path';
import { fileURLToPath } from 'node:url';

const root = resolve(dirname(fileURLToPath(import.meta.url)), '..');
const PORTABLE_ROOT = '/work/samples/ts';
const local = process.argv.includes('--local');

process.chdir(root);
rmSync('coverage', { recursive: true, force: true });

const vitest = join(root, 'node_modules', 'vitest', 'vitest.mjs');
if (!existsSync(vitest)) {
  throw new Error('vitest is not installed: run `npm ci` in samples/ts first.');
}

/**
 * One measured run of vitest.
 *
 * @param {string[]} files The test files to run; none means all of them.
 * @param {string} directory Where the reports go.
 * @param {string[]} reporters Which Istanbul reporters write them.
 */
function measure(files, directory, reporters) {
  const args = [vitest, 'run', ...files, '--coverage.enabled', `--coverage.reportsDirectory=${directory}`];
  for (const reporter of reporters) {
    args.push(`--coverage.reporter=${reporter}`);
  }
  execFileSync(process.execPath, args, { stdio: 'inherit' });
}

// The combined run first: each run empties the folder it writes to, and the
// two suites' folders are inside this one.
measure([], 'coverage', ['json', 'lcovonly', 'clover', 'cobertura']);
measure(['test/unit.test.ts'], 'coverage/unit', ['json']);
measure(['test/integration.test.ts'], 'coverage/integration', ['json']);

/**
 * A path as the lab image would have written it.
 *
 * @param {string} path A path from a report, absolute or relative, either slash.
 * @returns {string} The same place under /work/samples/ts, with forward slashes.
 */
function portable(path) {
  const forward = path.replace(/\\/g, '/');
  const here = root.replace(/\\/g, '/');
  return forward.toLowerCase().startsWith(here.toLowerCase()) ? PORTABLE_ROOT + forward.slice(here.length) : forward;
}

/** @param {string} file An Istanbul JSON report: the paths are its keys and each entry's `path`. */
function portableJson(file) {
  const report = JSON.parse(readFileSync(file, 'utf8'));
  const rewritten = {};
  for (const entry of Object.values(report)) {
    entry.path = portable(entry.path);
    rewritten[entry.path] = entry;
  }
  writeFileSync(file, JSON.stringify(rewritten));
}

/** @param {string} file LCOV, Clover or Cobertura: the paths are where these four markers say. */
function portableText(file) {
  const text = readFileSync(file, 'utf8');
  writeFileSync(
    file,
    text.replace(/(SF:|\bpath="|\bfilename="|<source>)([^"<\r\n]*)/g, (_, marker, path) => marker + portable(path)),
  );
}

/** @param {string} directory Walked for every report under it. */
function walk(directory) {
  for (const name of readdirSync(directory)) {
    const file = join(directory, name);
    if (statSync(file).isDirectory()) {
      walk(file);
    } else if (name.endsWith('.json')) {
      portableJson(file);
    } else if (name.endsWith('.info') || name.endsWith('.xml')) {
      portableText(file);
    }
  }
}

if (!local) {
  walk('coverage');
}

const version = (name) => JSON.parse(readFileSync(join(root, 'node_modules', name, 'package.json'), 'utf8')).version;
writeFileSync(
  join('coverage', 'VERSIONS.txt'),
  [`- node ${process.version}`, `- vitest ${version('vitest')}`, `- @vitest/coverage-istanbul ${version('@vitest/coverage-istanbul')}`, `- typescript ${version('typescript')}`, ''].join('\n'),
);

console.log('Wrote coverage/ (Istanbul JSON, LCOV, Clover, Cobertura) and the two per-suite reports.');
