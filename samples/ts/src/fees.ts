/**
 * @file Late fees, for the TypeScript coverage sample.
 *
 * One function with a dozen decisions in it and one test that walks a single
 * path through them: low coverage and high complexity in the same place, which
 * is what a CRAP score is for.
 *
 * @author Mario Fucini
 * @copyright Copyright (c) 2026 Fucini Consulting. Released under the MIT
 *            License; see the LICENSE file in the repository root.
 * @license MIT
 */
import type { Item, Member } from './loan';

/**
 * What a late return costs.
 *
 * @param daysLate Whole days past the due date.
 * @param member Who brought it back.
 * @param item What came back.
 * @returns The fee, never below zero. Deliberately under-tested: only the
 *   integration suite gets here, with a standard member, a book, three days.
 */
export function lateFee(daysLate: number, member: Member, item: Item): number {
  if (daysLate <= 0) {
    return 0;
  }

  let perDay: number;
  if (item.kind === 'book') {
    perDay = 0.5;
  } else if (item.kind === 'dvd') {
    perDay = 1.5;
  } else {
    perDay = 4;
  }

  let fee = perDay * daysLate;

  if (daysLate > 28) {
    fee += 25;
  } else if (daysLate > 14) {
    fee += 10;
  }

  if (member.tier === 'student') {
    fee *= 0.5;
  } else if (member.tier === 'staff') {
    fee = 0;
  }

  if (member.suspended && fee > 0) {
    fee += 5;
  }

  const cap = item.kind === 'tool' ? item.deposit : 30;
  return Math.max(0, Math.min(fee, cap));
}

/**
 * Whether a fee is small enough to waive at the desk.
 *
 * @param fee The fee.
 * @param firstOffence Whether the member has never been late before.
 * @param goodwill Whether the librarian says so. Every late member in the
 *   tests is a first offender, so this operand is never even evaluated.
 * @returns True when the desk may waive it.
 */
export function waivable(fee: number, firstOffence: boolean, goodwill: boolean): boolean {
  return fee < 5 && (firstOffence || goodwill);
}
