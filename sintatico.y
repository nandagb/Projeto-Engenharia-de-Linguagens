%{
#include <stdio.h>

int yylex(void);
int yyerror(char *s);
extern int yylineno;
extern char * yytext;

%}

%union {
     int    iValue; 	/* integer value */
     char   cValue; 	/* char value */
     char * sValue;      /* string value */
     /* float type??? */
	};

%token <sValue> ID STRING_LITERAL FLOAT_LITERAL INT_LITERAL
/* %token <fValue>  */
/* %token <iValue>  */
%token INTEGER LIST STRUCT FLOAT STRING VOID BOOLEAN FUNCTION
NEW


%start stmt_list

%%
stmt_list : stmt
            | stmt_list stmt
;

stmt : global ';'                                                                                 {printf("GLOBAL\n");}
;

func_declaration : type FUNCTION ID '(' params_list ')' '{' stmt_list '}'                         {printf("FUNÇÃO\n");}
;

global : var_declaration                                                                          {/*printf("ID\n");*/}
     | list_initialization                                                                        {/*printf("ID\n");*/}
     | list_assign                                                                                {/*printf("ID\n");*/}
;

global_list : |
              | global_list global ';'                                                             {/*printf("ID\n");*/}
              | global ';'
;

params_list : |
              | params_list ',' var_declaration
              | var_declaration
;

unary : ID                                                                                         {/*printf("ID\n");*/}
      | INT_LITERAL                                                                                {/*printf("INT LITERAL\n");*/}
      | FLOAT_LITERAL                                                                              {/*printf("FLOAT LITERAL\n");*/}
      | STRING_LITERAL                                                                             {/*printf("STRING LITERAL\n");*/}
;

var_declaration : primitive_type ID                                                                {/*printf("VAR DECLARATION\n");*/}
                | list_declaration                                                                 {/*printf("LIST DECLARATION\n");*/}
;

list_initialization : list_declaration '=' NEW LIST '<' primitive_type '>' '(' ')'                 {/*printf("LIST INITIALIZATION\n");*/}
                    | list_declaration '=' NEW LIST '<' primitive_type '>' '(' ID ')'              {/*printf("LIST INITIALIZATION FROM ANOTHER LIST (NEW COPY)\n");*/}
;

list_assign : ID '=' NEW LIST '<' primitive_type '>' '(' ')'                                       {/*printf("LIST ASSIGN\n");*/}
            | ID '=' NEW LIST '<' primitive_type '>' '(' ID ')'                                    {/*printf("LIST ASSIGN FROM ANOTHER LIST (NEW COPY)\n");*/}
;

list_declaration : LIST '<' primitive_type '>' ID
;

type : primitive_type
     | LIST
     | STRUCT
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