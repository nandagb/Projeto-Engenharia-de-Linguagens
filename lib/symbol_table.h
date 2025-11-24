#ifndef SYMBOLTABLE
#define SYMBOLTABLE

#include "record.h"

typedef enum { 
	ELIST, ESTRUCT, EPRIMARY
} structure;

typedef struct {
    const char* key;     /* variable's name */
    type type;           /* variable's primitive type */
    structure structure; /* variable's structure type: primary or user defined */
} table_entry;


typedef struct {
    table_entry* entries;  /* array of table entries */
    int capacity;       /* actual size of entries array*/
    int length;         /* number of items currently in the hash table */
} table;

table* table_create(void);

void table_destroy(table* table);

#endif