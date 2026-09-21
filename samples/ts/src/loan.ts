/**
 * @file A library's lending desk, for the TypeScript coverage sample.
 *
 * Small on purpose, and written so that each function leaves a different kind
 * of gap behind once the tests have run. ../README.md says which line shows
 * what.
 *
 * @author Mario Fucini
 * @copyright Copyright (c) 2026 Fucini Consulting. Released under the MIT
 *            License; see the LICENSE file in the repository root.
 * @license MIT
 */

/** Somebody with a library card. */
export interface Member {
  id: string;
  tier: 'standard' | 'student' | 'staff';
  /** Set while the card is blocked. */
  suspended?: boolean;
  /** Optional all the way down: a member may have given no contact at all. */
  contact?: { email?: string };
}

/** What can be borrowed. The `kind` decides which other field there is. */
export type Item =
  | { kind: 'book'; title: string; pages: number }
  | { kind: 'dvd'; title: string; minutes: number }
  | { kind: 'tool'; title: string; deposit: number };

/** One item out with one member. */
export interface Loan {
  id: string;
  item: Item;
  due: number;
  renewals: number;
}

const DAY = 24 * 60 * 60 * 1000;

/**
 * The compiler's proof that a `switch` is complete: reaching this is a bug.
 *
 * @param value What should have been impossible.
 * @returns Never: it throws. Never called either, and rightly so: this and the
 *   `default` that calls it are the red that no test should turn green.
 */
function assertNever(value: never): never {
  throw new Error(`Unexpected item: ${JSON.stringify(value)}`);
}

/**
 * How long an item may stay out.
 *
 * @param item What is being borrowed.
 * @returns Days. The tests borrow books and DVDs, never a tool, so that `case`
 *   is uncovered, and the `default` is unreachable by construction.
 */
export function loanDays(item: Item): number {
  switch (item.kind) {
    case 'book':
      return item.pages > 600 ? 42 : 21;
    case 'dvd':
      return 7;
    case 'tool':
      return item.deposit > 100 ? 2 : 5;
    default:
      return assertNever(item);
  }
}

/**
 * The day an item is due back.
 *
 * @param start When it was taken out, in milliseconds.
 * @param days How long it may stay out. Every caller passes it, so the default
 *   value is a branch nobody takes.
 * @returns The due date, in milliseconds.
 */
export function dueDate(start: number, days = 21): number {
  return start + days * DAY;
}

/**
 * Where a reminder goes.
 *
 * @param member Whom to remind.
 * @returns An address. Every member in the tests has given one, so the
 *   fallback after `??` is never needed.
 */
export function contactOf(member: Member): string {
  return member.contact?.email ?? 'front desk';
}

/**
 * Whether the desk hands over one more item.
 *
 * @param member Who is asking.
 * @param open How many items that member has out already.
 * @param limit How many are allowed.
 * @returns True when the card is good and there is room, or the member is
 *   staff. Nobody in the tests is ever at the limit, so the third operand is
 *   never even evaluated.
 */
export function canBorrow(member: Member, open: number, limit: number): boolean {
  return !member.suspended && (open < limit || member.tier === 'staff');
}

/**
 * Extend a loan by a week.
 *
 * @param loan The loan to extend. Every test loan has renewals left, so the
 *   `if` is always taken and the implicit `else` never is.
 * @returns The same loan.
 */
export function renew(loan: Loan): Loan {
  if (loan.renewals < 3) {
    loan.due += 7 * DAY;
    loan.renewals += 1;
  }
  return loan;
}

/**
 * The titles on a member's receipt.
 *
 * @param loans What the member has out. The test prints the receipt of a
 *   member with nothing out: the line runs, the arrow function on it never
 *   does.
 * @returns The titles, one per line.
 */
export function receipt(loans: Loan[]): string {
  return loans.map((loan) => loan.item.title).join('\n');
}

/**
 * A checksum over every page in the catalogue, for the nightly export.
 *
 * @param pages Page counts of the whole catalogue.
 * @returns A 16-bit sum. The loop is what the inline hit counts are for: one
 *   test, some twelve thousand turns.
 */
export function checksum(pages: number[]): number {
  let sum = 0;
  for (const count of pages) {
    sum = (sum + count) & 0xffff;
  }
  return sum;
}

/* istanbul ignore next -- @preserve: a developer's aid, deliberately outside every total */
export function debugDump(loans: Loan[]): void {
  for (const loan of loans) {
    console.log(loan.id, loan.item.kind, new Date(loan.due).toISOString());
  }
}
