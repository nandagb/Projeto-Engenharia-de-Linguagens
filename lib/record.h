#ifndef RECORD
#define RECORD

typedef enum { 
	ELIST, ESTRUCT, EPRIMARY, UNDEFINED_STRUCTURE
} structure;

typedef enum {
	EINTEGER, EFLOAT, ESTRING, EBOOL, EVOID, ESTRUCT_TYPE, EUNTYPED, UNDEFINED_TYPE
} type;

struct record {
	   char * code; /* field for storing the output code */
	   type type; /* field for storing the variable type, if any */
	   structure structure; /* variable's structure type: primary or user defined */
	   char * type_string; /* field for storing the variable type in C code, if any */
};

typedef struct record record;
 
void freeRecord(record *);
record * createRecord(char *, type);
record * setRecord(char* str_list[], int list_size);
char * type_to_string(type t);
char * type_to_string_in_C(type t);
char * string_to_type_in_C(char* str);

#endif