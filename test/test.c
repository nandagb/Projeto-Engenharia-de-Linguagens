#include <stdio.h>
#include <stdlib.h>
#include "./../lib/cat.h"
#include "./../lib/record.h"
#include "./../lib/file_gen.h"
#include "./../lib/symbol_table.h"

int main(){
    printf("TESTING SYMBOL TABLE\n");
    table* sym_table = table_create();
    printf("SYMBOL TABLE CREATED\n");
    table_entry* entry = malloc(sizeof(table_entry));
    return 0;
}