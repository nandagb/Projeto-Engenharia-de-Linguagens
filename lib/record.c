#include "record.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

void freeRecord(record * r){
  if (r) {
    if (r->code != NULL) free(r->code);
	  if (r->opt1 != NULL) free(r->opt1);
    free(r);
  }
}


record * createRecord(char * c1, enum type c2){
  record * r = (record *) malloc(sizeof(record));

  

  if (!r) {
    printf("Allocation problem. Closing application...\n");
    exit(0);
  }

  r->code = strdup(c1);
  r->type = c2;

  return r;
}
