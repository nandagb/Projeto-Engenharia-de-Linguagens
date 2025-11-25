#include "scope.h"
#include <stdio.h>
#include <stdbool.h>

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

// Function to push an element onto the stack
//TODO: AUMENTAR TAMANHO DINAMICAMENTE
void push(Stack *stack, char* value) {
    if (isFull(stack)) {
        printf("Stack Overflow\n");
        return;
    }
    stack->arr[++stack->top] = value;
    printf("Pushed %s onto the stack\n", value);
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