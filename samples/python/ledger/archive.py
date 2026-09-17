## @file archive.py
#  @brief Archive naming that nothing imports: the unmeasured file of this sample.
#
#  @author Mario Fucini
#  @copyright Copyright (c) 2026 Fucini Consulting. Released under the MIT
#             License; see the LICENSE file in the repository root.

"""Imported by nothing, so no test loads it and no report mentions it.

That is "unmeasured", which is not "uncovered": coverage.py has no zero for
this file, it has no data at all. (Its --source option would list it at 0%;
the generator deliberately does not pass it, to keep the difference visible.)
"""


def archive_name(year, quarter):
    """! @brief File name of a quarter's archive.

    @param year     Four-digit year.
    @param quarter  1 to 4.
    @return For example @c "ledger-2026-q3.csv".
    """
    return f"ledger-{year}-q{quarter}.csv"
