#include <stdlib.h>
#include <stdio.h>
#include <string.h>

char *new_label(char* label) {
    static int labelCount = 0;
    char *buf = malloc(20*sizeof(char));
    if (!buf) {
        return "error";
    }
    sprintf(buf, "%s%d", label, labelCount++);
    return buf;
}

// find a substring whithin a string and replace all occurrences by another string
char* replace_all(const char* str, const char* sub, const char* rep) {
    const char* pos;
    int count = 0;
    int sub_len = strlen(sub);
    int rep_len = strlen(rep);

    // counts how many times the substring occurs
    pos = str;
    while ((pos = strstr(pos, sub)) != NULL) {
        count++;
        pos += sub_len;
    }

    // if there are no occurrences, return as it is (IMPORTANT!)
    if (count == 0) {
        char* copy = malloc(strlen(str) + 1);
        strcpy(copy, str);
        return copy;
    }

    // calculate new size
    int new_len = strlen(str) + count * (rep_len - sub_len);
    char* result = malloc(new_len + 1);

    char* r = result;
    const char* p = str;

    while ((pos = strstr(p, sub)) != NULL) {
        // copies before
        memcpy(r, p, pos - p);
        r += pos - p;

        // copies substitution
        memcpy(r, rep, rep_len);
        r += rep_len;

        p = pos + sub_len;
    }

    // copia the rest
    strcpy(r, p);

    return result;
}