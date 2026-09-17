## @file __init__.py
#  @brief The ledger package of the Python coverage sample.
#
#  @author Mario Fucini
#  @copyright Copyright (c) 2026 Fucini Consulting. Released under the MIT
#             License; see the LICENSE file in the repository root.

"""The ledger package."""

from .ledger import Ledger, LedgerError

__all__ = ["Ledger", "LedgerError"]
