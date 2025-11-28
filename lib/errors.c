#include <string.h>
#include <stdio.h>

#define MAX_ERRORS 256

char *errors[MAX_ERRORS];
static int error_count = 0;

void report_error(const char *msg) {
    printf("INSIDE REPORT ERROR");
    if (error_count < MAX_ERRORS) {
        errors[error_count++] = strdup(msg);
    }
}

int get_error_count() {
    return error_count;
}

char** get_errors() {
    return errors;
}