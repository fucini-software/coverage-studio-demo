"""Imported by nothing, so no test loads it and no report mentions it.

That is "unmeasured", which is not "uncovered": coverage.py has no zero for
this file, it has no data at all. (Its --source option would list it at 0%;
the generator deliberately does not pass it, to keep the difference visible.)
"""


def archive_name(year, quarter):
    return f"ledger-{year}-q{quarter}.csv"
