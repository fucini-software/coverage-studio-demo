#include "calc.h"
#include <assert.h>

int main(void) {
    assert(add(2, 3) == 5);
    assert(subtract(5, 2) == 3);
    assert(classify(10) == 1);   /* only the positive path is exercised */
    assert(gate(1, 1, 0) == 1);  /* a && b true,  c false */
    assert(gate(0, 0, 1) == 1);  /* a && b false, c true  */
    return 0;
}
