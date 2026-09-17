## @file run_tests.py
#  @brief Runs the test suite in-process, so coverage.py starts the same way on every Python.
#
#  @author Mario Fucini
#  @copyright Copyright (c) 2026 Fucini Consulting. Released under the MIT
#             License; see the LICENSE file in the repository root.

"""Run the test suite in-process: `coverage run --branch run_tests.py`.

A script rather than `-m unittest`, so coverage.py starts the same way on every
Python, including embedded ones whose standard library lives in a zip file.
An optional argument narrows the run to one test class, which is how the
generator produces a report per suite: `run_tests.py PostingTests`.
"""

import os
import sys
import unittest

# An embedded Python runs isolated and leaves the script's own folder off the
# module path, so `tests` and `ledger` would only be importable by accident.
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))


def main(argv):
    """! @brief Run the whole suite, or one test class of it.

    @param argv  The command line; an optional second element names a test class.
    @return 0 when every test passed, otherwise 1.
    """
    loader = unittest.TestLoader()
    if len(argv) > 1:
        suite = loader.loadTestsFromName(f"tests.test_ledger.{argv[1]}")
    else:
        suite = loader.discover("tests", top_level_dir=".")
    result = unittest.TextTestRunner(verbosity=1).run(suite)
    return 0 if result.wasSuccessful() else 1


if __name__ == "__main__":
    sys.exit(main(sys.argv))
