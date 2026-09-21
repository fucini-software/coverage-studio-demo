/**
 * @file How the TypeScript sample is tested and measured.
 *
 * Istanbul rather than V8: it instruments the code, so it knows a statement's
 * columns and what kind of branch each branch is, and says so in
 * coverage-final.json. The instrumented code is the JavaScript that esbuild
 * made of the TypeScript; the source maps carry every position back, so the
 * reports speak of the .ts files and of nothing else.
 *
 * No `coverage.include`: with one, vitest also reports the files no test
 * loaded, as 0 % covered. Leaving it out keeps src/legacy-import.ts out of the
 * report altogether, which is the case the sample wants to show.
 *
 * @author Mario Fucini
 * @copyright Copyright (c) 2026 Fucini Consulting. Released under the MIT
 *            License; see the LICENSE file in the repository root.
 * @license MIT
 */
import { defineConfig } from 'vitest/config';

export default defineConfig({
  test: {
    include: ['test/**/*.test.ts'],
    coverage: {
      provider: 'istanbul',
      clean: true,
    },
  },
});