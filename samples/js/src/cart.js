/**
 * @file A shopping cart for the JavaScript coverage sample.
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
'use strict';

const { quote } = require('./pricing');

/**
 * One line of an order.
 *
 * @typedef {Object} Item
 * @property {string} sku Stock keeping unit.
 * @property {string} name What the customer sees.
 * @property {number} price Price of one unit.
 * @property {number} qty Units ordered.
 * @property {boolean} [discontinued] Set while the last units are sold off.
 */

/**
 * Sum of the lines, minus a coupon when there is one.
 *
 * @param {Item[]} items The lines of the order.
 * @param {{value: number}} [coupon] A coupon to subtract. No test passes one,
 *   so the first arm of the ternary is never taken.
 * @returns {number} The goods total.
 */
function total(items, coupon) {
  const sum = items.reduce((acc, item) => acc + item.price * item.qty, 0);
  return coupon ? sum - coupon.value : sum;
}

/**
 * What delivery costs.
 *
 * @param {string} kind `standard` or `express`.
 * @returns {number} The charge; 0 for a kind the shop does not know. No test
 *   asks for one, so the `default` never runs.
 */
function shippingFor(kind) {
  switch (kind) {
    case 'standard':
      return 4.9;
    case 'express':
      return 12;
    default:
      return 0;
  }
}

/**
 * Swiss VAT, when the order ships there.
 *
 * @param {number} amount The amount before tax.
 * @param {string} country ISO country code. Every test order ships to `CH`, so
 *   the `if` is always taken and its implicit `else` never is.
 * @returns {number} The amount with tax, rounded to cents.
 */
function applyVat(amount, country) {
  if (country === 'CH') amount = amount * 1.081;
  return Math.round(amount * 100) / 100;
}

/**
 * Names for the order confirmation.
 *
 * @param {Item[]} items The lines of the order.
 * @returns {string[]} One label per line that has units on it. Nothing in the
 *   tests is discontinued, so that arm is never taken.
 */
function labels(items) {
  return items.filter((item) => item.qty > 0).map((item) => (item.discontinued ? `${item.name} (last units)` : item.name));
}

/**
 * A bulk order gets an audit trail.
 *
 * @param {Item[]} items The lines of the order.
 * @returns {string[]} The SKUs of a bulk order, otherwise nothing. No test
 *   order is that large: the line runs, the lambda inside it never does.
 */
function auditTrail(items) {
  return items.length > 100 ? items.map((item) => item.sku) : [];
}

/**
 * Position-weighted checksum of a SKU: the loop the hit counts are about.
 *
 * @param {string} sku The SKU to check.
 * @returns {number} A value from 0 to 96.
 */
function checksum(sku) {
  let sum = 0;
  for (let i = 0; i < sku.length; i++) {
    sum = (sum + sku.charCodeAt(i) * (i + 1)) % 97;
  }
  return sum;
}

/**
 * The whole order, priced.
 *
 * @param {{items: Item[], coupon?: {value: number}, customer: Object, shipping: string, country: string}} order
 *   The order to price.
 * @returns {{amount: number, labels: string[], audit: string[]}} What to charge
 *   and what to print.
 */
function checkout(order) {
  const goods = total(order.items, order.coupon);
  const priced = quote({ amount: goods, customer: order.customer, items: order.items });
  const withShipping = priced + shippingFor(order.shipping);
  return {
    amount: applyVat(withShipping, order.country),
    labels: labels(order.items),
    audit: auditTrail(order.items),
  };
}

/**
 * Print an order. Excluded from measurement on purpose: a developer aid, not
 * product code.
 *
 * @param {Object} order The order to print.
 */
/* istanbul ignore next */
function debugDump(order) {
  console.log(JSON.stringify(order, null, 2));
}

module.exports = { total, shippingFor, applyVat, labels, auditTrail, checksum, checkout, debugDump };
