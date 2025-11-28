#ifndef SYMBOLTABLE
#define SYMBOLTABLE

#include "record.h"
#include <stdint.h>   /* uint64_t */
#include <stddef.h>   /* size_t */
#include <stdbool.h>  /* bool */

typedef enum { 
	ELIST, ESTRUCT, EPRIMARY, UNDEFINED_STRUCTURE
} structure;

typedef struct {
    const char* key;     /* variable's name */
    type type;           /* variable's primitive type */
    structure structure; /* variable's structure type: primary or user defined */
    void* value;         /* variable's value*/
    int size;           /* size of list (if its a list)*/
} table_entry;


typedef struct {
    table_entry* entries;  /* array of table entries */
    int capacity;          /* actual size of entries array*/
    int length;            /* number of items currently in the hash table */
} table;

table* table_create(void);

void table_destroy(table* table);

void* table_get(table* table, const char* key);

const char* table_set(table* table, const char* key, type type, structure structure, void* value);

static bool table_expand(table* table);

type table_get_type(table* table, const char* key);

structure table_get_structure(table* table, const char* key);

void* table_get_value(table* table, const char* key);

table_entry* table_get_entry_object(table* table, const char* key);

#endif