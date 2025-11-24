#include "symbol_table.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define INITIAL_CAPACITY 16

table* table_create(void) {
    table* table = malloc(sizeof(table));

    if (table == NULL) {
        return NULL;
    }

    table->length = 0;
    table->capacity = INITIAL_CAPACITY;

    table->entries = calloc(table->capacity, sizeof(table_entry));

    if (table->entries == NULL) {
        free(table);
        return NULL;
    }

    return table;
}

void table_destroy(table* table) {
    for (int i = 0; i < table->capacity; i++) {
        free((void*)table->entries[i].key);
    }

    free(table->entries);
    free(table);
}
