#include "record.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

void freeRecord(record * r){
  if (r) {
    if (r->code != NULL) free(r->code);
    free(r);
  }
}

record * createRecord(char * c1, type c2){
  record * r = (record *) malloc(sizeof(record));

  if (!r) {
    printf("Allocation problem. Closing application...\n");
    exit(0);
  }

  r->code = strdup(c1);
  r->type = c2;

  return r;
}

char * type_to_string(type t){
  if (t == EINTEGER){
    return "inteiro";
  }
  else if (t == EFLOAT){
    return "real";
  }
  else if(t == ESTRING){
    return "texto";
  }
  else if(t == EBOOL){
    return "lógico";
  }
  else if(t == EVOID){
    return "vazio";
  }
  else if(t == EUNTYPED || t == UNDEFINED_TYPE){
    return "indefinido";
  }
}

char * type_to_string_in_C(type t){
  if (t == EINTEGER){
    return "int";
  }
  else if (t == EFLOAT){
    return "float";
  }
  // else if(t == ESTRING){
  //   return "texto";
  // }
  else if(t == EBOOL){
    return "bool";
  }
  else if(t == EVOID){
    return "void";
  }
  // else if(t == EUNTYPED || t == UNDEFINED_TYPE){
  //   return "indefinido";
  // }
}

char * string_to_type_in_C(char* str){
  if (strcmp(str, "int ") == 0){
    return "int ";
  }
  else if (strcmp(str, "real ") == 0){
    return "float ";
  }
  else if(strcmp(str, "texto ") == 0){
    return "char* ";
  }
  else if(strcmp(str, "logico ") == 0){
    return "bool ";
  }
  else if(strcmp(str, "vazio ") == 0){
    return "void ";
  }
  // else if(t == EUNTYPED || t == UNDEFINED_TYPE){
  //   return "indefinido";
  // }
}
