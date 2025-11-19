#ifndef RECORD
#define RECORD

typedef enum { 
	EINTEGER, EFLOAT, ESTRING, EBOOL, EVOID, EUNTYPED
} type;

struct record {
	   char * code; /* field for storing the output code */
	   type type; /* field for another purpose */
};

typedef struct record record;
 
void freeRecord(record *);
record * createRecord(char *, type);
record * setRecord(char* str_list[], int list_size);

#endif