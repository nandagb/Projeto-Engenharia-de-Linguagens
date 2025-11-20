#include <stdio.h>
#include "./lib/cat.h"
#include "./lib/record.h"
#include "./lib/file_gen.h"

int main(){
    char * str_list[] = {"a", "h"};
    char * str = cat(str_list, 2);

    record * r = createRecord(str, EINTEGER);

    gen_file(r->code, "gen_test.c");

    return 0;
}