%{
#include <stdio.h>

int yylex(void);
int yyerror(char *s);
extern int yylineno;
extern char * yytext;

%}

%union {
	char * sValue;  /* string value */
	};

%token <sValue> ID
%token INTEGER LIST STRUCT FLOAT STRING VOID BOOLEAN
NEW


%start stmt_list

%%
stmt_list : stmt
          | stmt_list stmt
;

stmt : var_declaration ';'
     | list_initialization ';'
;

var_declaration : primitive_type ID {printf("VAR DECLARATION\n");}
                | list_declaration  {printf("LIST DECLARATION\n");}
;

list_initialization : list_declaration '=' NEW LIST '<' primitive_type '>' '(' ')'                 {printf("LIST INITIALIZATION\n");}
                    | list_declaration '=' NEW LIST '<' primitive_type '>' '(' ID ')'  {printf("LIST INITIALIZATION FROM ANOTHER LIST\n");}
;

list_declaration : LIST '<' primitive_type '>' ID
;

primitive_type : INTEGER
     | FLOAT
     | STRING
     | VOID
     | BOOLEAN
;
	

%%

int main (void) {
	return yyparse ( );
}

int yyerror (char *msg) {
	fprintf (stderr, "%d: %s at '%s'\n", yylineno, msg, yytext);
	return 0;
}