/**
 * @file Stock keeping for the JavaScript coverage sample.
 *
 * cart.js leaves gaps in ordinary control flow. This class leaves the ones that
 * are particular to JavaScript: a default parameter value nobody relies on, a
 * `??` fallback that is never needed, a `catch` that is never reached, a getter
 * that is never read and a static method that is never called.
 *
 * @author Mario Fucini
 * @copyright Copyright (c) 2026 Fucini Consulting. Released under the MIT
 *            License; see the LICENSE file in the repository root.
 * @license MIT
 */
'use strict';

/** Units below which a product counts as running low. */
const LOW_STOCK = 5;

/** What is on the shelves, by SKU. */
class Inventory {
  /**
   * @param {Object<string, number>} [stock] Units per SKU. Every test passes
   *   one, so the default value is a branch that is never taken.
   */
  constructor(stock = {}) {
    this.stock = stock;
    this.log = [];
  }

  /**
   * Units available of a product.
   *
   * @param {string} sku The product.
   * @returns {number} Units in stock; 0 for a product the shop never stocked.
   *   No test asks about one, so the `?? 0` operand never decides.
   */
  available(sku) {
    return this.stock[sku] ?? 0;
  }

  /**
   * Take units off the shelf.
   *
   * @param {string} sku The product.
   * @param {number} [qty] How many. Always given by the tests: another default
   *   value never used.
   * @returns {boolean} Whether there was enough. The tests never ask for more
   *   than there is, so the refusal is uncovered.
   */
  reserve(sku, qty = 1) {
    if (this.available(sku) < qty) {
      this.log.push(`short: ${sku}`);
      return false;
    }
    this.stock[sku] -= qty;
    return true;
  }

  /**
   * Fetch new stock levels from a supplier.
   *
   * @param {function(): Promise<Object<string, number>>} fetcher Resolves to
   *   units per SKU.
   * @returns {Promise<number>} How many products were updated, or -1 when the
   *   supplier could not be reached. The test supplier always answers, so the
   *   `catch` is an error path that exists only on paper.
   */
  async restock(fetcher) {
    try {
      const levels = await fetcher();
      Object.assign(this.stock, levels);
      return Object.keys(levels).length;
    } catch (error) {
      this.log.push(`restock failed: ${error.message}`);
      return -1;
    }
  }

  /**
   * Products running low. Never read by any test: a getter looks like data,
   * and is a function nobody called.
   *
   * @type {string[]}
   */
  get lowStock() {
    return Object.keys(this.stock).filter((sku) => this.stock[sku] < LOW_STOCK);
  }

  /**
   * Rebuild an inventory from its saved form. Never called by any test.
   *
   * @param {string} json What `JSON.stringify(inventory.stock)` produced.
   * @returns {Inventory} The restored inventory.
   */
  static fromJSON(json) {
    return new Inventory(JSON.parse(json));
  }
}

module.exports = { Inventory, LOW_STOCK };
