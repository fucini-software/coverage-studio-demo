#include "buffer.h"

/* Fully covered: every line runs in the test. */
void buffer_init(buffer_t *b, int capacity) {
    b->count = 0;
    b->capacity = capacity < BUFFER_MAX ? capacity : BUFFER_MAX;
    b->locked = 0;
}

/* Both outcomes exercised — the accept path and the "buffer full" refusal. */
int buffer_push(buffer_t *b, int value) {
    if (b->count >= b->capacity) {
        return 0;
    }
    b->data[b->count++] = value;
    return 1;
}

/* MC/DC decision with three independent conditions.
   The test only ever reaches it with `force` true, so the decision is taken
   but the conditions inside it are not independently exercised — line and
   branch coverage look fine here while MC/DC does not, which is the whole
   argument for measuring MC/DC at ASIL C/D and SIL 3/4. */
int buffer_can_write(const buffer_t *b, int force) {
    if ((b->count < b->capacity && !b->locked) || force) {
        return 1;
    }
    return 0;
}

/* Never called by any test — shows up in the report's never-called table. */
int buffer_drain(buffer_t *b) {
    int n = b->count;
    b->count = 0;
    return n;
}
