/**
 * @file The integration suite: one loan from the desk to the late fee.
 *
 * The only suite that reaches ../src/fees.ts, and it walks one path through
 * it. Load this suite's report on its own to see what it is worth, or with the
 * unit suite's to see the two merge.
 *
 * @author Mario Fucini
 * @copyright Copyright (c) 2026 Fucini Consulting. Released under the MIT
 *            License; see the LICENSE file in the repository root.
 * @license MIT
 */
import { expect, test } from 'vitest';
import { Catalogue } from '../src/catalogue';
import { lateFee } from '../src/fees';
import { canBorrow, dueDate, loanDays, type Item, type Loan, type Member } from '../src/loan';

const DAY = 24 * 60 * 60 * 1000;

test('a book goes out, comes back three days late, and costs 1.50', () => {
  const book: Item = { kind: 'book', title: 'Knots', pages: 96 };
  const member: Member = { id: 'M-001', tier: 'standard', contact: { email: 'ada@example.org' } };
  const catalogue = new Catalogue([book], 1);

  expect(canBorrow(member, 0, 5)).toBe(true);
  expect(catalogue.take(book.title)).toBe(true);

  const loan: Loan = { id: 'L-7', item: book, due: dueDate(0, loanDays(book)), renewals: 0 };
  const returned = loan.due + 3 * DAY;
  const daysLate = Math.floor((returned - loan.due) / DAY);

  expect(lateFee(daysLate, member, book)).toBe(1.5);
});
