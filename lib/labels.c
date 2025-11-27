#include <stdlib.h>
#include <stdio.h>
#include <string.h>

char *newLabel(char* label) {
    static int labelCount = 0;
    char *buf = malloc(20*sizeof(char));
    if (!buf) {
        return "error";
    }
    sprintf(buf, "%s%d", label, labelCount++);
    return buf;
}

// find a substring whithin a string and replace it by another string
char *replace(const char *str, const char *placeholder, const char *replacement) {
    if (!str || !placeholder || !replacement)
        return strdup(str ? str : "");

    const char *p = str;
    size_t count = 0;
    size_t len_ph = strlen(placeholder);

    while ((p = strstr(p, placeholder)) != NULL) {
        count++;
        p += len_ph;
    }

    if (count == 0)
        return strdup(str);

    size_t len_rep = strlen(replacement);
    size_t len = strlen(str) + count * (len_rep - len_ph);
    char *result = malloc(len + 1);

    char *dst = result;
    const char *src = str;

    while ((p = strstr(src, placeholder)) != NULL) {
        size_t chunk = p - src;
        memcpy(dst, src, chunk);
        dst += chunk;
        memcpy(dst, replacement, len_rep);
        dst += len_rep;
        src = p + len_ph;
    }

    strcpy(dst, src);
    return result;
}