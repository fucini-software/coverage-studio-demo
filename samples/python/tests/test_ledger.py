## @file test_ledger.py
#  @brief The test suite of the Python coverage sample: three unittest classes.
#
#  What it never passes in is deliberate, and is what the sample demonstrates;
#  each gap is documented on the function it belongs to, under ../ledger. The
#  generator runs each class on its own as well, for one report per suite.
#
#  @author Mario Fucini
#  @copyright Copyright (c) 2026 Fucini Consulting. Released under the MIT
#             License; see the LICENSE file in the repository root.

"""The test suite of the Python coverage sample."""

import unittest

from ledger import Ledger, LedgerError
from ledger.reconcile import find_entry, parse_amount, settle, unmatched


class PostingTests(unittest.TestCase):
    """! @brief Posting entries and reading balances."""

    def test_post_and_balance(self):
        """! @brief Two entries that cancel out."""
        book = Ledger()
        book.post("cash", 250, "Opening float")
        book.post("sales", -250, "Opening float")
        self.assertEqual(book.balance(), 0)
        self.assertEqual(book.balance("cash"), 250)

    def test_zero_amount_is_refused(self):
        """! @brief The one refusal the suite does exercise."""
        with self.assertRaises(LedgerError):
            Ledger().post("cash", 0)

    def test_classify(self):
        """! @brief Three of the four bands: nothing here needs approval."""
        book = Ledger()
        self.assertEqual(book.classify(-5), "refund")
        self.assertEqual(book.classify(40), "small")
        self.assertEqual(book.classify(900), "regular")


class ClosingTests(unittest.TestCase):
    """! @brief Closing the books and indexing a year of entries."""

    def test_a_balanced_ledger_closes(self):
        """! @brief Only ever a ledger that balances."""
        book = Ledger()
        book.post("cash", 10)
        book.post("sales", -10)
        book.close()
        self.assertTrue(book.closed)

    def test_memo_index_over_a_full_year(self):
        """! @brief 730 entries of five words each: the hot inner loop."""
        book = Ledger()
        for day in range(365):
            book.post("cash", 1, f"Daily takings day {day} till one")
            book.post("sales", -1, f"Daily takings day {day} till one")
        self.assertEqual(len(book.memo_index()["takings"]), 730)


class ReconcileTests(unittest.TestCase):
    """! @brief Matching against a bank statement, always the happy path."""

    def setUp(self):
        """! @brief A ledger that balances, with two distinct amounts."""
        book = Ledger()
        book.post("cash", 1250.5, "Invoice 17")
        book.post("sales", -1250.5, "Invoice 17")
        ## The entries of the balanced ledger every test here works on.
        self.entries = book.entries

    def test_amounts_parse(self):
        """! @brief Well-formed text only: the except never fires."""
        self.assertEqual(parse_amount("1'250.50"), 1250.5)
        self.assertEqual(parse_amount("-40"), -40.0)

    def test_an_existing_amount_is_found(self):
        """! @brief Always an amount that exists: the loop always breaks."""
        self.assertEqual(find_entry(self.entries, 1250.5)["account"], "cash")

    def test_a_balanced_ledger_needs_no_settling(self):
        """! @brief Already balanced: the while loop is never entered."""
        self.assertEqual(settle(self.entries), 0)

    def test_every_statement_line_matches(self):
        """! @brief Never an empty statement, never a line that matches nothing."""
        self.assertEqual(unmatched(self.entries, ["1'250.50", "-1'250.50"]), [])


if __name__ == "__main__":
    unittest.main()
