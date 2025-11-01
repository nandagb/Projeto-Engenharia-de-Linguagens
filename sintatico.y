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
prog : general_stmt_list func_declaration                                                         {printf("PROGRAMA\n");}
;

stmt_list : stmt                                                                                   
            | stmt_list stmt                                                                      {/*printf("STATEMENT\n");*/}   
;

stmt : general_stmt ';'                                                                           {/*printf("STATEMENT\n");*/}
     | func_declaration                                                                           
;

func_declaration : type FUNCTION ID '(' params_list ')' '{' stmt_list '}'                         {printf("FUNÇÃO\n");}
;

general_stmt : var_declaration                                                                    {printf("STATEMENT GERAL\n");}
     | list_initialization                                                                        {/*printf("ID\n");*/}
     | list_assign                                                                                {/*printf("ID\n");*/}
;

general_stmt_list : general_stmt_union                                          {printf("LISTA STATEMENT GERAL\n");}
                  |                                                                             
;

general_stmt_union : general_stmt                                         {printf("LISTA STATEMENT GERAL\n");}
                   | general_stmt ';' general_stmt_list 
;

params_list : params_union
              |
;

params_union : var_declaration
             | var_declaration ',' params_union

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