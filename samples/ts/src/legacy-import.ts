/**
 * @file The importer for the card index the library had before 2009.
 *
 * Imported by nothing and tested by nothing, so no coverage report mentions
 * it: not 0 % covered, but absent. With `fuciniCoverage.unmeasured.mode` set
 * to `list` it is shown as not measured instead of being left out in silence,
 * which is the difference between "untested" and "unknown".
 *
 * @author Mario Fucini
 * @copyright Copyright (c) 2026 Fucini Consulting. Released under the MIT
 *            License; see the LICENSE file in the repository root.
 * @license MIT
 */
import type { Item } from './loan';

/**
 * Read one card of the old index.
 *
 * @param card A line such as `B;Moby-Dick;635`.
 * @returns The item, or `undefined` for a card nobody can read any more.
 */
export function fromCard(card: string): Item | undefined {
  const [kind, title, size] = card.split(';');
  const amount = Number(size);
  if (!title || Number.isNaN(amount)) {
    return undefined;
  }
  if (kind === 'B') {
    return { kind: 'book', title, pages: amount };
  }
  if (kind === 'V') {
    return { kind: 'dvd', title, minutes: amount };
  }
  return undefined;
}
