#ifndef BUFFER_H
#define BUFFER_H

#define BUFFER_MAX 4

/* A tiny bounded buffer — the kind of guard embedded code is full of, and
   the reason branch and MC/DC coverage are worth measuring separately. */
typedef struct {
    int data[BUFFER_MAX];
    int count;
    int capacity;
    int locked;
} buffer_t;

void buffer_init(buffer_t *b, int capacity);
int buffer_push(buffer_t *b, int value);
int buffer_can_write(const buffer_t *b, int force);
int buffer_drain(buffer_t *b);

#endif /* BUFFER_H */
