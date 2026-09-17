'use strict';

// A shopping cart. Small on purpose, and written so that each function leaves
// a different kind of gap behind once the tests have run: see ../README.md for
// which line shows what.

const { quote } = require('./pricing');

/** Sum of the lines, minus a coupon when there is one. */
function total(items, coupon) {
  const sum = items.reduce((acc, item) => acc + item.price * item.qty, 0);
  return coupon ? sum - coupon.value : sum;
}

/** What delivery costs. No test ever asks for anything but the two real kinds. */
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

/** Swiss VAT, when the order ships there. Every test order does. */
function applyVat(amount, country) {
  if (country === 'CH') amount = amount * 1.081;
  return Math.round(amount * 100) / 100;
}

/** Names for the order confirmation. */
function labels(items) {
  return items.filter((item) => item.qty > 0).map((item) => (item.discontinued ? `${item.name} (last units)` : item.name));
}

/** A bulk order gets an audit trail. No test order is that large. */
function auditTrail(items) {
  return items.length > 100 ? items.map((item) => item.sku) : [];
}

/** Position-weighted checksum of a SKU: the loop the hit counts are about. */
function checksum(sku) {
  let sum = 0;
  for (let i = 0; i < sku.length; i++) {
    sum = (sum + sku.charCodeAt(i) * (i + 1)) % 97;
  }
  return sum;
}

/** The whole order, priced. */
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

/* istanbul ignore next */
function debugDump(order) {
  // Excluded from measurement on purpose: a developer aid, not product code.
  console.log(JSON.stringify(order, null, 2));
}

module.exports = { total, shippingFor, applyVat, labels, auditTrail, checksum, checkout, debugDump };
