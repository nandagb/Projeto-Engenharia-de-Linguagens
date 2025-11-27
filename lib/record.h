#ifndef RECORD
#define RECORD

typedef enum { 
	EINTEGER, EFLOAT, ESTRING, EBOOL, EVOID, EUNTYPED, UNDEFINED_TYPE
} type;

struct record {
	   char * code; /* field for storing the output code */
	   type type; /* field for storing the variable type, if any */
};

typedef struct record record;
 
void freeRecord(record *);
record * createRecord(char *, type);
record * setRecord(char* str_list[], int list_size);
char * type_to_string(type t);

#endif