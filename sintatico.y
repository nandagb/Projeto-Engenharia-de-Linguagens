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


%start var_declaration

%%
var_declaration : TYPE ID {printf("VAR DECLARATION\n");} 
	 ;

TYPE : INTEGER                 ;
	

%%

int main (void) {
	return yyparse ( );
}

int yyerror (char *msg) {
	fprintf (stderr, "%d: %s at '%s'\n", yylineno, msg, yytext);
	return 0;
}