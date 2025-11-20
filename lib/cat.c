#include <stdio.h>
#include <string.h>
#include <stdlib.h>

char * cat(char **str_list, long list_size){
  int tam = 1;
  char * output;

  for (int i=0; i < list_size; i++){
     tam = tam + strlen(str_list[i]);
  }

  output = malloc(tam);
  output[0] = '\0';

  if (!output){
    printf("Allocation problem. Closing application...\n");
    exit(0);
  }

  for (int i=0; i < list_size; i++){
    strcat(output, str_list[i]);
  }

  return output;
}