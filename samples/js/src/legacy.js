'use strict';

// Nothing requires this file, so no test ever loads it and no report mentions
// it. That is "unmeasured", which is not the same as "uncovered": there is no
// zero here, there is no data at all. Set fuciniCoverage.unmeasured.mode to see
// how the extension tells the two apart.

function formatInvoiceNumber(year, serial) {
  return `${year}-${String(serial).padStart(6, '0')}`;
}

module.exports = { formatInvoiceNumber };
