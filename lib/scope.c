#include "scope.h"
#include <stdio.h>
#include <stdbool.h>
#include <string.h>
#include <stdlib.h>

// Define the maximim capacity of the stack
#define MAX_SIZE 100

// Function to initialize the stack
void initialize(Stack *stack) {
    stack->top = -1;  
}

// Function to check if the stack is empty
bool isEmpty(Stack *stack) {
    return stack->top == -1;  
}

// Function to check if the stack is full
bool isFull(Stack *stack) {
    return stack->top == MAX_SIZE - 1;  
}

bool find(Stack *stack, char* value){
    for(int i = 0; i < stack->top; i++){
        if(!strcmp(stack->arr[i], value)) return true;
    }
    return false;
}

// Function to push an element onto the stack
//TODO: AUMENTAR TAMANHO DINAMICAMENTE
void push(Stack *stack, char* value) {
    if (isFull(stack)) {
        printf("Stack Overflow\n");
        return;
    }

    char str[20];
    do{
        int random = rand();
        sprintf(str, "%d", random);
    } while (find(stack, str));

    size_t len = strlen(value) + strlen(str) + 1;
    char *new_value = malloc(len);
    if (!new_value) {
        printf("Erro de alocacao\n");
        return;
    }

    strcpy(new_value, value);
    strcat(new_value, str);
    
    stack->arr[++stack->top] = new_value;
    printf("Pushed %s onto the stack\n", new_value);
}

// Function to pop an element from the stack
char* pop(Stack *stack) {
    if (isEmpty(stack)) {
        printf("Stack Underflow\n");
        return "";
    }

    char* popped = stack->arr[stack->top];
    stack->top--;
    printf("Popped %s from the stack\n", popped);
    return popped;
}

// Function to peek the top element of the stack
char* peek(Stack *stack) {
    if (isEmpty(stack)) {
        printf("Stack is empty\n");
        return "";
    }
    return stack->arr[stack->top];
}

// Function to peek the top element of the stack
char* peek_position(Stack *stack, int index) {
    if (isEmpty(stack)) {
        printf("Stack is empty\n");
        return "";
    }
    if(index > stack->top || index < 0){
        printf("Stack out of bounds\n");
        return "";
    }
    return stack->arr[index];
}