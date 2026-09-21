/**
 * @file The unit suite: the desk's and the catalogue's functions, one at a time.
 *
 * What it never passes in is deliberate, and is what the sample demonstrates;
 * each gap is documented on the function it belongs to, under ../src.
 *
 * @author Mario Fucini
 * @copyright Copyright (c) 2026 Fucini Consulting. Released under the MIT
 *            License; see the LICENSE file in the repository root.
 * @license MIT
 */
import { expect, test } from 'vitest';
import { Catalogue, pick, type Supplier } from '../src/catalogue';
import { waivable } from '../src/fees';
import { canBorrow, checksum, contactOf, dueDate, loanDays, receipt, renew, type Item, type Loan, type Member } from '../src/loan';

const DAY = 24 * 60 * 60 * 1000;

const novel: Item = { kind: 'book', title: 'Moby-Dick', pages: 635 };
const primer: Item = { kind: 'book', title: 'Knots', pages: 96 };
const film: Item = { kind: 'dvd', title: 'Metropolis', minutes: 148 };

const ada: Member = { id: 'M-001', tier: 'standard', contact: { email: 'ada@example.org' } };
const tom: Member = { id: 'M-002', tier: 'student', suspended: true, contact: { email: 'tom@example.org' } };

test('a long book stays out longer than a short one, a film a week', () => {
  // Never a tool: that `case` stays uncovered.
  expect(loanDays(novel)).toBe(42);
  expect(loanDays(primer)).toBe(21);
  expect(loanDays(film)).toBe(7);
});

test('the due date is the start plus the days', () => {
  // Always with the days given: the default value is never used.
  expect(dueDate(0, 7)).toBe(7 * DAY);
});

test('a reminder goes to the address on the card', () => {
  expect(contactOf(ada)).toBe('ada@example.org');
});

test('the desk refuses a blocked card', () => {
  // Nobody is ever at the limit: whether staff may go over it is never asked.
  expect(canBorrow(ada, 2, 5)).toBe(true);
  expect(canBorrow(tom, 0, 5)).toBe(false);
});

test('renewing adds a week', () => {
  const loan: Loan = { id: 'L-1', item: novel, due: 0, renewals: 0 };
  expect(renew(loan).due).toBe(7 * DAY);
});

test('a member with nothing out gets an empty receipt', () => {
  expect(receipt([])).toBe('');
});

test('the export checksum covers the whole catalogue', () => {
  const pages = Array.from({ length: 12_000 }, (_, index) => 80 + (index % 700));
  expect(checksum(pages)).toBe(pages.reduce((sum, count) => (sum + count) & 0xffff, 0));
});

test('a small first fee may be waived', () => {
  // Always a first offence: the librarian's goodwill is never asked for.
  expect(waivable(1.5, true, false)).toBe(true);
  expect(waivable(12, true, false)).toBe(false);
});

test('the shelf counts down and up', async () => {
  const catalogue = new Catalogue([novel, film], 2);
  expect(catalogue.take('Moby-Dick')).toBe(true);
  expect(catalogue.available('Moby-Dick')).toBe(1);

  const reliable: Supplier = { order: async (_title, copies) => copies };
  expect(await catalogue.restock('Moby-Dick', reliable)).toBe(5);
  expect(catalogue.available('Moby-Dick')).toBe(6);
});

test('pick finds what is there', () => {
  expect(pick(['Knots', 'Moby-Dick'], (title) => title.startsWith('M'))).toBe('Moby-Dick');
});
