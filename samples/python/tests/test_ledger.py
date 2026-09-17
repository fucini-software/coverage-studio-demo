import unittest

from ledger import Ledger, LedgerError


class PostingTests(unittest.TestCase):
    def test_post_and_balance(self):
        book = Ledger()
        book.post("cash", 250, "Opening float")
        book.post("sales", -250, "Opening float")
        self.assertEqual(book.balance(), 0)
        self.assertEqual(book.balance("cash"), 250)

    def test_zero_amount_is_refused(self):
        with self.assertRaises(LedgerError):
            Ledger().post("cash", 0)

    def test_classify(self):
        book = Ledger()
        # Three of the four bands: nothing here is large enough for approval.
        self.assertEqual(book.classify(-5), "refund")
        self.assertEqual(book.classify(40), "small")
        self.assertEqual(book.classify(900), "regular")


class ClosingTests(unittest.TestCase):
    def test_a_balanced_ledger_closes(self):
        book = Ledger()
        book.post("cash", 10)
        book.post("sales", -10)
        book.close()
        self.assertTrue(book.closed)

    def test_memo_index_over_a_full_year(self):
        book = Ledger()
        for day in range(365):
            book.post("cash", 1, f"Daily takings day {day} till one")
            book.post("sales", -1, f"Daily takings day {day} till one")
        self.assertEqual(len(book.memo_index()["takings"]), 730)


if __name__ == "__main__":
    unittest.main()
