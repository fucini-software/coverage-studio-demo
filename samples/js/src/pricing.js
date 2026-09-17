'use strict';

/**
 * The price after every rule the business ever asked for.
 *
 * This is the function to worry about: a dozen decisions, and a test suite
 * that walks through two of them. Line coverage alone makes it look half
 * done; the branch column shows how little of it was ever decided.
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

/** Whether an order may skip manual review: all three must hold. */
function fastTrack(customer, amount) {
  return customer.verified && (amount < 200 || customer.tier === 'gold');
}

module.exports = { quote, fastTrack };
