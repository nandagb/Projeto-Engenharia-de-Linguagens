#include <stdlib.h>
#include <stdio.h>

void gen_file(char * str, char * file_name){
    FILE *fptr;

    fptr = fopen(file_name, "w");
    if(fptr == NULL){
        fprintf(stderr, "\nError opened file\n");
        exit(1);
    }

    fprintf(fptr, "%s", str);

    fclose(fptr);
}