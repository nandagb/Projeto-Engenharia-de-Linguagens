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
%token INTEGER
%token LIST
%token STRUCT
%token FLOAT
%token STRING
%token VOID
%token BOOLEAN


%start stmt_list

%%
stmt_list : stmt
          | stmt_list stmt
;

stmt : var_declaration
;

var_declaration : primary_type ID ';' {printf("VAR DECLARATION\n");}
                | list_declaration  {printf("LIST DECLARATION\n");}
	 ;

list_declaration : LIST '<' primary_type '>' ID ';'

primary_type : INTEGER
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