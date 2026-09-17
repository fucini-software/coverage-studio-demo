/**
 * @file Pricing rules for the JavaScript coverage sample.
 *
 * @author Mario Fucini
 * @copyright Copyright (c) 2026 Fucini Consulting. Released under the MIT
 *            License; see the LICENSE file in the repository root.
 * @license MIT
 */
'use strict';

/**
 * Who is buying.
 *
 * @typedef {Object} Customer
 * @property {('basic'|'silver'|'gold'|'staff')} tier Loyalty tier.
 * @property {number} years Years as a customer.
 * @property {boolean} blocked Set by accounts when nothing may be sold.
 * @property {boolean} overdue Whether an invoice is unpaid.
 * @property {boolean} [verified] Whether the identity was checked.
 */

/**
 * The price after every rule the business ever asked for.
 *
 * This is the function to worry about: a dozen decisions, and a test suite
 * that walks through them exactly one way. Line coverage alone makes it look
 * half done; the branch column shows how little of it was ever decided.
 *
 * @param {{amount: number, customer: Customer, items: Array}} order The goods
 *   total, the customer and the lines of the order.
 * @returns {number} The price to charge, never below zero.
 * @throws {Error} When the order needs manual approval. No test gets here.
 */
function quote({ amount, customer, items }) {
  let price = amount;

  if (customer.tier === 'gold') {
    price *= 0.9;
  } else if (customer.tier === 'silver') {
    price *= 0.95;
  } else if (customer.tier === 'staff') {
    price *= 0.7;
  }

  if (customer.years > 5 && customer.tier !== 'staff') {
    price -= 5;
  }

  if (items.length >= 10) {
    price *= 0.97;
  } else if (items.length >= 5) {
    price *= 0.99;
  }

  if (customer.blocked || (customer.overdue && amount > 500)) {
    throw new Error('order needs approval');
  }

  if (price < 0) {
    price = 0;
  }

  return price;
}

/**
 * Whether an order may skip manual review.
 *
 * @param {Customer} customer Who is buying.
 * @param {number} amount The order total.
 * @returns {boolean} True for a verified customer with a small order or a gold
 *   tier. Every test amount is small, so the gold-tier operand never decides.
 */
function fastTrack(customer, amount) {
  return customer.verified && (amount < 200 || customer.tier === 'gold');
}

module.exports = { quote, fastTrack };
