## @file ledger.py
#  @brief A small double-entry ledger for the Python coverage sample.
#
#  Written so that each method leaves a different kind of gap once the tests
#  have run; ../README.md says which line shows what.
#
#  @author Mario Fucini
#  @copyright Copyright (c) 2026 Fucini Consulting. Released under the MIT
#             License; see the LICENSE file in the repository root.

"""A small double-entry ledger."""


class LedgerError(Exception):
    """! @brief An entry or an operation the ledger refuses."""


class Ledger:
    """! @brief Entries against named accounts, which must sum to zero to close."""

    def __init__(self):
        """! @brief Start an open ledger with no entries."""
        ## The posted entries, oldest first.
        self.entries = []
        ## Whether the books are closed.
        self.closed = False

    def post(self, account, amount, memo=""):
        """! @brief Record one entry.

        @param account  Name of the account the amount is booked to.
        @param amount   Positive for a debit, negative for a credit.
        @param memo     Free text describing the entry.
        @return The entry as stored.
        @exception LedgerError  The ledger is closed, or @p amount is zero.
        @note The tests never post to a closed ledger: that check is half taken
              and its @c raise uncovered.
        """
        if self.closed:
            raise LedgerError("ledger is closed")
        if amount == 0:
            raise LedgerError("an entry needs an amount")
        entry = {"account": account, "amount": amount, "memo": memo}
        self.entries.append(entry)
        return entry

    def balance(self, account=None):
        """! @brief Sum of everything, or of one account.

        @param account  The account to total, or @c None for the whole ledger.
        @return The total.
        """
        total = 0
        for entry in self.entries:
            if account is None or entry["account"] == account:
                total += entry["amount"]
        return total

    def classify(self, amount):
        """! @brief Size band of an amount.

        @param amount  The amount to classify.
        @return @c "refund", @c "small", @c "regular" or @c "needs-approval".
        @note No test amount reaches the last band, so the final @c return is
              uncovered.
        """
        if amount < 0:
            return "refund"
        if amount < 100:
            return "small"
        if amount < 10_000:
            return "regular"
        return "needs-approval"

    def close(self):
        """! @brief Close the books.

        @exception LedgerError  The ledger does not balance.
        @note An unbalanced ledger is never closed in the tests: the error
              path is uncovered.
        """
        if self.balance() != 0:
            raise LedgerError("ledger does not balance")
        self.closed = True

    def memo_index(self):
        """! @brief Entries by memo word.

        @return A dict from lower-cased word to the entries mentioning it.
        @note The inner loop is the hot one. coverage.py records that it ran,
              not how often, so this is the format to see "Covered" on.
        """
        index = {}
        for entry in self.entries:
            for word in entry["memo"].split():
                index.setdefault(word.lower(), []).append(entry)
        return index

    def export_csv(self):
        """! @brief The ledger as CSV text.

        @return One header line and one line per entry.
        @note Never called by any test: every line of it is uncovered.
        """
        lines = ["account,amount,memo"]
        for entry in self.entries:
            lines.append(f'{entry["account"]},{entry["amount"]},{entry["memo"]}')
        return "\n".join(lines)

    def debug_dump(self):  # pragma: no cover
        """! @brief Print every entry.

        @note Excluded from measurement on purpose: a developer aid.
        """
        for entry in self.entries:
            print(entry)
