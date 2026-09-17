"""A small double-entry ledger.

Written so that each function leaves a different kind of gap once the tests
have run; ../README.md says which line shows what.
"""


class LedgerError(Exception):
    """An entry the ledger refuses."""


class Ledger:
    def __init__(self):
        self.entries = []
        self.closed = False

    def post(self, account, amount, memo=""):
        """Record one entry. The tests never post to a closed ledger."""
        if self.closed:
            raise LedgerError("ledger is closed")
        if amount == 0:
            raise LedgerError("an entry needs an amount")
        entry = {"account": account, "amount": amount, "memo": memo}
        self.entries.append(entry)
        return entry

    def balance(self, account=None):
        """Sum of everything, or of one account."""
        total = 0
        for entry in self.entries:
            if account is None or entry["account"] == account:
                total += entry["amount"]
        return total

    def classify(self, amount):
        """Size band of an amount. No test amount reaches the last band."""
        if amount < 0:
            return "refund"
        if amount < 100:
            return "small"
        if amount < 10_000:
            return "regular"
        return "needs-approval"

    def close(self):
        """Close the books. An unbalanced ledger is never tested."""
        if self.balance() != 0:
            raise LedgerError("ledger does not balance")
        self.closed = True

    def memo_index(self):
        """Entries by memo word. The inner loop is where the hit counts pile up."""
        index = {}
        for entry in self.entries:
            for word in entry["memo"].split():
                index.setdefault(word.lower(), []).append(entry)
        return index

    def export_csv(self):
        """Never called by any test: every line of it is uncovered."""
        lines = ["account,amount,memo"]
        for entry in self.entries:
            lines.append(f'{entry["account"]},{entry["amount"]},{entry["memo"]}')
        return "\n".join(lines)

    def debug_dump(self):  # pragma: no cover
        # Excluded from measurement on purpose: a developer aid.
        for entry in self.entries:
            print(entry)
