"""Run the test suite in-process: `coverage run --branch run_tests.py`.

A script rather than `-m unittest`, so coverage.py starts the same way on every
Python, including embedded ones whose standard library lives in a zip file.
An optional argument narrows the run to one test class, which is how the
generator produces a report per suite: `run_tests.py PostingTests`.
"""

import sys
import unittest


def main(argv):
    loader = unittest.TestLoader()
    if len(argv) > 1:
        suite = loader.loadTestsFromName(f"tests.test_ledger.{argv[1]}")
    else:
        suite = loader.discover("tests", top_level_dir=".")
    result = unittest.TextTestRunner(verbosity=1).run(suite)
    return 0 if result.wasSuccessful() else 1


if __name__ == "__main__":
    sys.exit(main(sys.argv))
