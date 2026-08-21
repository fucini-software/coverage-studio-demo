#include "calc.h"

/* Simple arithmetic used by the demo. */
int add(int a, int b) {
    return a + b;
}

int subtract(int a, int b) {
    return a - b;
}

/* Partially covered: the negative branch is never tested. */
int classify(int x) {
    if (x > 0) {
        return 1;
    } else {
        return -1;
    }
}

/* MC/DC decision: a compound condition with three inputs. */
int gate(int a, int b, int c) {
    if ((a && b) || c) {
        return 1;
    }
    return 0;
}

/* Dead code: never called by any test. */
int unused_helper(int x) {
    return x * 2;
}
