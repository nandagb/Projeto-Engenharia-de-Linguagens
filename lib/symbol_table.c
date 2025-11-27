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

#define FNV_OFFSET 14695981039346656037UL
#define FNV_PRIME 1099511628211UL

// Return 64-bit FNV-1a hash for key (NUL-terminated). See description:
// https://en.wikipedia.org/wiki/Fowler–Noll–Vo_hash_function
static uint64_t hash_key(const char* key) {
    uint64_t hash = FNV_OFFSET;
    for (const char* p = key; *p; p++) {
        hash ^= (uint64_t)(unsigned char)(*p);
        hash *= FNV_PRIME;
    }
    return hash;
}

table_entry* get_table_entry(table_entry* entries, int capacity, const char* key, uint64_t hash, int index) {
    /* if null then key is not in the table */
    while (entries[index].key != NULL) {
        if (strcmp(key, entries[index].key) == 0) {
            /* Found key, return value. */
            return &entries[index];
        }

        /* either a collision or key isnt in the table */
        index++;

        if (index >= capacity) {
            /* reset index */
            index = 0;
        }
    }
    return NULL;
}

type table_get_type(table* table, const char* key) {
    printf("\nA1: GETTING ENTRY FROM KEY: %s\n", key);

    uint64_t hash = hash_key(key);
    int index = hash % table->capacity;

    table_entry* entry = get_table_entry(table->entries, table->capacity, key, hash, index);

    printf("\nENTRY KEY: %s\n", entry->key);
    printf("ENTRY HASH: %ld\n", hash);
    printf("ENTRY INDEX: %d\n", index);
    printf("ENTRY TYPE: %d\n", entry->type);
    printf("ENTRY STRUCTURE: %d\n", entry->structure);
    // printf("ENTRY VALUE: %d\n", entry->value);

    printf("\n");

    if (entry == NULL) {
        return UNDEFINED_TYPE;
    }

    return entry->type;
}

structure table_get_structure(table* table, const char* key) {
    uint64_t hash = hash_key(key);
    int index = hash % table->capacity;

    table_entry* entry = get_table_entry(table->entries, table->capacity, key, hash, index);

    if (entry == NULL) {
        return UNDEFINED_STRUCTURE;
    }

    return entry->structure;
}

void* table_get_value(table* table, const char* key) {
    uint64_t hash = hash_key(key);
    int index = hash % table->capacity;

    table_entry* entry = get_table_entry(table->entries, table->capacity, key, hash, index);

    if (entry == NULL) {
        return NULL;
    }

    return entry->value;
}

table_entry* table_get_entry_object(table* table, const char* key) {
    uint64_t hash = hash_key(key);
    int index = hash % table->capacity;

    table_entry* entry = get_table_entry(table->entries, table->capacity, key, hash, index);

    if (entry == NULL) {
        return NULL;
    }

    return entry;
}

static const char* table_set_entry(table_entry* entries, int capacity, const char* key, type type, structure structure, void* value, int* plength) {
    // AND hash with capacity-1 to ensure it's within entries array.
    uint64_t hash = hash_key(key);
    int index = hash % capacity;

    table_entry* entry = get_table_entry(entries, capacity, key, hash, index);
    if (entry != NULL) {
        entry->type = type;
        entry->structure = structure;
        entry->value = value;
        return entry->key;
    }

    /* key doesnt exists yet, allocate and if needed, then insert it. */
    if (plength != NULL) {
        key = strdup(key);

        if (key == NULL) {
            return NULL;
        }

        (*plength)++;
    }

    entries[index].key = (char*)key;
    entries[index].type = type;
    entries[index].structure = structure;
    entries[index].value = value;

    return key;
}

const char* table_set(table* table, const char* key, type type, structure structure, void* value) {
    /* if length will exceed half of current capacity, expand it. */
    if (table->length >= table->capacity / 2) {
        if (!table_expand(table)) {
            return NULL;
        }
    }

    return table_set_entry(table->entries, table->capacity, key, type, structure, value, &table->length);
}

/* expand hash table to twice its current size. Return true on success, false if out of memory*/
static bool table_expand(table* table) {
    /* allocate new entries array */
    int new_capacity = table->capacity * 2;

    if (new_capacity < table->capacity) {
        /* overflow (capacity would be too big) */
        return false;
    }

    table_entry* new_entries = calloc(new_capacity, sizeof(table_entry));

    if (new_entries == NULL) {
        return false;
    }

    /* iterate entries, move all non-empty ones to new table's entries */
    for (int i = 0; i < table->capacity; i++) {
        table_entry entry = table->entries[i];
        if (entry.key != NULL) {
            table_set_entry(new_entries, new_capacity, entry.key, entry.type, entry.structure, entry.value, NULL);
        }
    }

    /* Free old entries array and update this table's details */
    free(table->entries);
    table->entries = new_entries;
    table->capacity = new_capacity;
    return true;
}




