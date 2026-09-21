/**
 * @file The catalogue, for the TypeScript coverage sample.
 *
 * A class, because classes have places for untested code that functions do
 * not: a getter that looks like data, a static factory, a `catch` that exists
 * only on paper, a generic that is only ever one type.
 *
 * @author Mario Fucini
 * @copyright Copyright (c) 2026 Fucini Consulting. Released under the MIT
 *            License; see the LICENSE file in the repository root.
 * @license MIT
 */
import type { Item } from './loan';

/** Whoever delivers new copies. */
export interface Supplier {
  order(title: string, copies: number): Promise<number>;
}

/** How many copies of each title are on the shelf. */
export class Catalogue {
  private readonly copies = new Map<string, number>();

  /**
   * @param items What the library owns.
   * @param perTitle Copies of each. Every test says how many, so the default
   *   value is a branch nobody takes.
   */
  constructor(items: Item[], perTitle = 1) {
    for (const item of items) {
      this.copies.set(item.title, perTitle);
    }
  }

  /**
   * Copies on the shelf.
   *
   * @param title The title asked for.
   * @returns The count. The tests only ask for titles the library has, so the
   *   fallback after `??` is never needed.
   */
  available(title: string): number {
    return this.copies.get(title) ?? 0;
  }

  /**
   * Take one copy off the shelf.
   *
   * @param title The title to hand over.
   * @returns Whether there was one. There always is in the tests: the refusal
   *   is uncovered.
   */
  take(title: string): boolean {
    const left = this.available(title);
    if (left === 0) {
      return false;
    }
    this.copies.set(title, left - 1);
    return true;
  }

  /**
   * Order more copies.
   *
   * @param title The title to restock.
   * @param supplier Who delivers. The test's supplier always answers, so the
   *   `catch` has never once run.
   * @returns How many copies arrived; 0 when the supplier failed.
   */
  async restock(title: string, supplier: Supplier): Promise<number> {
    try {
      const arrived = await supplier.order(title, 5);
      this.copies.set(title, this.available(title) + arrived);
      return arrived;
    } catch {
      return 0;
    }
  }

  /** Titles with nothing left. A getter nobody reads: it looks like data and is a function. */
  get outOfStock(): string[] {
    return [...this.copies].filter(([, count]) => count === 0).map(([title]) => title);
  }

  /**
   * Rebuild a catalogue from its saved form.
   *
   * @param saved Title and count pairs.
   * @returns The catalogue. A static method nobody calls.
   */
  static fromJSON(saved: Array<[string, number]>): Catalogue {
    const catalogue = new Catalogue([]);
    for (const [title, count] of saved) {
      catalogue.copies.set(title, count);
    }
    return catalogue;
  }
}

/**
 * The first element a test accepts.
 *
 * @param values Where to look.
 * @param accept The test.
 * @returns The element, or `undefined`. Generic, and only ever used with
 *   strings that are found: the loop always ends early, and the last line is
 *   never reached.
 */
export function pick<T>(values: readonly T[], accept: (value: T) => boolean): T | undefined {
  for (const value of values) {
    if (accept(value)) {
      return value;
    }
  }
  return undefined;
}
