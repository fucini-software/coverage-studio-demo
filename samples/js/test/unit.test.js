/**
 * @file The unit suite: the cart's and the inventory's functions, one at a time.
 *
 * What it never passes in is deliberate, and is what the sample demonstrates;
 * each gap is documented on the function it belongs to, under ../src.
 *
 * @author Mario Fucini
 * @copyright Copyright (c) 2026 Fucini Consulting. Released under the MIT
 *            License; see the LICENSE file in the repository root.
 * @license MIT
 */
'use strict';

const test = require('node:test');
const assert = require('node:assert');
const { total, shippingFor, applyVat, labels, checksum } = require('../src/cart');
const { fastTrack } = require('../src/pricing');
const { Inventory } = require('../src/inventory');

const items = [
  { sku: 'TEA-001', name: 'Tea', price: 8, qty: 2 },
  { sku: 'CUP-014', name: 'Cup', price: 12.5, qty: 1 },
  { sku: 'OLD-900', name: 'Tin', price: 3, qty: 0 },
];

test('total adds up the lines', () => {
  // Never with a coupon: the ternary's first arm stays untaken.
  assert.strictEqual(total(items), 28.5);
});

test('shipping knows both real kinds', () => {
  assert.strictEqual(shippingFor('standard'), 4.9);
  assert.strictEqual(shippingFor('express'), 12);
});

test('vat is added for Switzerland', () => {
  assert.strictEqual(applyVat(100, 'CH'), 108.1);
});

test('labels skip empty lines', () => {
  assert.deepStrictEqual(labels(items), ['Tea', 'Cup']);
});

test('checksum is stable across the catalogue', () => {
  // The whole catalogue, which is what makes the loop's count a big number.
  let last = 0;
  for (let n = 0; n < 2500; n++) last = checksum(`SKU-${n}`);
  assert.strictEqual(typeof last, 'number');
});

test('small verified orders are fast-tracked', () => {
  // `amount < 200` is always true here, so the gold-tier operand never decides.
  assert.strictEqual(fastTrack({ verified: true, tier: 'basic' }, 50), true);
  assert.strictEqual(fastTrack({ verified: false, tier: 'basic' }, 50), false);
});

test('stock is reserved while there is enough', () => {
  // Always with a stock map and a quantity, never for an unknown SKU and never
  // for more than there is: two default values, one ?? fallback and the
  // refusal all stay untaken.
  const shelf = new Inventory({ 'TEA-001': 10 });
  assert.strictEqual(shelf.reserve('TEA-001', 4), true);
  assert.strictEqual(shelf.available('TEA-001'), 6);
});

test('restocking takes what the supplier sends', async () => {
  // The test supplier always answers, so the catch is never reached.
  const shelf = new Inventory({ 'TEA-001': 1 });
  const updated = await shelf.restock(async () => ({ 'TEA-001': 50, 'CUP-014': 20 }));
  assert.strictEqual(updated, 2);
  assert.strictEqual(shelf.available('CUP-014'), 20);
});
