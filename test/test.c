#include <stdio.h>
#include <stdlib.h>
#include "./../lib/cat.h"
#include "./../lib/record.h"
#include "./../lib/file_gen.h"
#include "./../lib/symbol_table.h"
#include "./../lib/scope.h"

int main(){
    // printf("TESTING SYMBOL TABLE\n");
    // table* sym_table = table_create();
    // printf("SYMBOL TABLE CREATED\n");
    // table_entry* entry = malloc(sizeof(table_entry));

    Stack stack;
    initialize(&stack);  

    push(&stack, "global");
    printf("Top element: %s\n", peek(&stack));

    push(&stack, "main");
    printf("Top element: %s\n", peek(&stack));

    push(&stack, "if1");
    printf("Top element: %s\n", peek(&stack));

    push(&stack, "if2");
    printf("Top element: %s\n", peek(&stack));

    pop(&stack);
    printf("Peeked element at position %d: %s\n", 1, peek_position(&stack, 1));

    return 0;
}