#ifndef SCOPE
#define SCOPE

#define MAX_SIZE 100

struct Stack {
	char *arr[MAX_SIZE];
    int top; 
};

typedef struct Stack Stack;

void initialize(Stack *stack);
void push(Stack *stack, char* value);
char* pop(Stack *stack);
char* peek(Stack *stack);
char* peek_position(Stack *stack, int index);

#endif