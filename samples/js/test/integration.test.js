/**
 * @file The integration suite: one whole order, end to end.
 *
 * It is the only thing that reaches pricing.js's quote(), and it reaches it
 * exactly one way.
 *
 * @author Mario Fucini
 * @copyright Copyright (c) 2026 Fucini Consulting. Released under the MIT
 *            License; see the LICENSE file in the repository root.
 * @license MIT
 */
'use strict';

const test = require('node:test');
const assert = require('node:assert');
const { checkout } = require('../src/cart');

test('a gold customer checks out', () => {
  const result = checkout({
    items: [
      { sku: 'TEA-001', name: 'Tea', price: 8, qty: 2 },
      { sku: 'CUP-014', name: 'Cup', price: 12.5, qty: 1 },
    ],
    customer: { tier: 'gold', years: 2, blocked: false, overdue: false },
    shipping: 'standard',
    country: 'CH',
  });
  assert.strictEqual(result.amount, 33.02);
  assert.deepStrictEqual(result.labels, ['Tea', 'Cup']);
  assert.deepStrictEqual(result.audit, []);
});
