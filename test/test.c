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
    int var;
    table_set(sym_table, "var", EINTEGER, EPRIMARY, NULL);
    type var_type = table_get_type(sym_table, "var");
    structure var_structure = table_get_structure(sym_table, "var");
    table_entry* entry = table_get_entry_object(sym_table, "var");
    // var = 5;
    printf("TESTING SYMBOL THAT IS NOT IN TABLE\n");
    type unknown_type = table_get_type(sym_table, "teste");
    table_entry* unknown_entry = table_get_entry_object(sym_table, "teste");
    printf("UNKNOWN TYPE: %d\n", unknown_type);
    if (unknown_entry == NULL) {
        printf("VARIABLE TESTE NOT FOUND \n");
    }

    table_set(sym_table, "var2", EINTEGER, EPRIMARY, NULL);
    table_set(sym_table, "var3", EINTEGER, EPRIMARY, NULL);
    table_set(sym_table, "var4", EINTEGER, EPRIMARY, NULL);
    table_set(sym_table, "var5", EINTEGER, EPRIMARY, NULL);
    table_set(sym_table, "var6", EINTEGER, EPRIMARY, NULL);
    table_set(sym_table, "var7", EFLOAT, EPRIMARY, NULL);
    type var7_type = table_get_type(sym_table, "var7");
    printf("TABLE CAPACITY 7: %d\n", sym_table->capacity);
    printf("TABLE LENGTH 7: %d\n", sym_table->length);
    printf("VAR 7 TYPE: %d\n", var7_type);
    table_set(sym_table, "var8", ESTRING, EPRIMARY, NULL);
    type var8_type = table_get_type(sym_table, "var8");
    printf("TABLE CAPACITY 8: %d\n", sym_table->capacity);
    printf("TABLE LENGTH 8: %d\n", sym_table->length);
    printf("VAR 8 TYPE: %d\n", var8_type);
    table_set(sym_table, "var9", EBOOL, EPRIMARY, NULL);
    type var9_type = table_get_type(sym_table, "var9");
    printf("TABLE CAPACITY 9: %d\n", sym_table->capacity);
    printf("TABLE LENGTH 9: %d\n", sym_table->length);
    printf("VAR 9 TYPE: %d\n", var9_type);
    table_destroy(sym_table);
    return 0;
}