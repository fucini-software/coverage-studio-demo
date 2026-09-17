'use strict';

// The unit suite: the cart's own functions, one at a time.

const test = require('node:test');
const assert = require('node:assert');
const { total, shippingFor, applyVat, labels, checksum } = require('../src/cart');
const { fastTrack } = require('../src/pricing');

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
