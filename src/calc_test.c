#include "calc.h"
#include "buffer.h"
#include <assert.h>

int main(void) {
    assert(add(2, 3) == 5);
    assert(subtract(5, 2) == 3);
    assert(classify(10) == 1);   /* only the positive path is exercised */
    /* Enough vectors to satisfy MC/DC for `(a && b) || c`: each condition is
       shown to change the outcome on its own, holding the others fixed. */
    assert(gate(1, 1, 0) == 1);  /* baseline true  */
    assert(gate(0, 1, 0) == 0);  /* a alone flips it */
    assert(gate(1, 0, 0) == 0);  /* b alone flips it */
    assert(gate(0, 0, 1) == 1);  /* c alone flips it */
    assert(gate(0, 0, 0) == 0);  /* all false       */

    buffer_t b;
    buffer_init(&b, 2);
    assert(buffer_push(&b, 10) == 1);
    assert(buffer_push(&b, 20) == 1);
    assert(buffer_push(&b, 30) == 0);      /* refused: buffer full */
    assert(buffer_can_write(&b, 1) == 1);  /* only ever reached with force set */
    return 0;
}
