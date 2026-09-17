## @file reconcile.py
#  @brief Matching a ledger against a bank statement.
#
#  ledger.py leaves gaps in ordinary control flow. These functions leave the
#  ones Python makes easy to write and easy to forget: an @c except that never
#  fires, the @c else of a @c for loop, a @c while that is never entered and a
#  guard clause nobody triggers.
#
#  @author Mario Fucini
#  @copyright Copyright (c) 2026 Fucini Consulting. Released under the MIT
#             License; see the LICENSE file in the repository root.

"""Matching a ledger against a bank statement."""


def parse_amount(text):
    """! @brief Read an amount as a bank writes it.

    @param text  For example @c "1'250.50" or @c "-40".
    @return The amount as a float, or @c None when @p text is not a number.
    @note Every test amount is well formed, so the @c except never fires and
          the fallback it returns is untested.
    """
    try:
        return float(text.replace("'", ""))
    except ValueError:
        return None


def find_entry(entries, amount):
    """! @brief First entry with a given amount.

    @param entries  Ledger entries to search.
    @param amount   The amount to look for.
    @return The matching entry, or @c None.
    @note The tests always search for an amount that exists, so the loop always
          ends in @c break and its @c else clause never runs.
    """
    for entry in entries:
        if entry["amount"] == amount:
            found = entry
            break
    else:
        found = None
    return found


def settle(entries, tolerance=0):
    """! @brief Drop trailing entries until the rest balances.

    @param entries    Ledger entries, oldest first; modified in place.
    @param tolerance  Largest imbalance to accept.
    @return How many entries were dropped.
    @note The test ledger already balances, so the @c while is never entered.
    """
    dropped = 0
    while entries and abs(sum(e["amount"] for e in entries)) > tolerance:
        entries.pop()
        dropped += 1
    return dropped


def unmatched(entries, statement_lines):
    """! @brief Statement lines with no ledger entry of the same amount.

    @param entries          Ledger entries.
    @param statement_lines  Amounts as text, one per line of the statement.
    @return The lines that matched nothing.
    @note The guard for an empty statement is never triggered, and every test
          line matches an entry, so nothing is ever reported missing either.
    """
    if not statement_lines:
        return []
    missing = []
    for line in statement_lines:
        amount = parse_amount(line)
        if find_entry(entries, amount) is None:
            missing.append(line)
    return missing
