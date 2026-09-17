/**
 * @file Invoice numbering that nothing uses any more.
 *
 * Nothing requires this file, so no test ever loads it and no report mentions
 * it. That is "unmeasured", which is not the same as "uncovered": there is no
 * zero here, there is no data at all. `fuciniCoverage.unmeasured.mode` is how
 * the extension tells the two apart.
 *
 * @author Mario Fucini
 * @copyright Copyright (c) 2026 Fucini Consulting. Released under the MIT
 *            License; see the LICENSE file in the repository root.
 * @license MIT
 */
'use strict';

/**
 * Format an invoice number.
 *
 * @param {number} year Four-digit year.
 * @param {number} serial Running number within the year.
 * @returns {string} For example `2026-000042`.
 */
function formatInvoiceNumber(year, serial) {
  return `${year}-${String(serial).padStart(6, '0')}`;
}

module.exports = { formatInvoiceNumber };
