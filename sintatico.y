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

%token <sValue> ID STRING_LITERAL FLOAT_LITERAL INT_LITERAL BOOL_LITERAL
/* %token <fValue>  */
/* %token <iValue>  */
%token INTEGER LIST STRUCT FLOAT STRING VOID BOOLEAN FUNCTION NEW SUM_ASSIGN SUBTRACTION_ASSIGN TIMES_ASSIGN DIVISION_ASSIGN AND OR EQUALS DIFF GTE LTE INT_DIVISION UNARY_SUM UNARY_SUBTRACTION

%start prog

%%
prog : func_declaration
     | general_stmt_list func_declaration                                                         {printf("PROGRAMA\n");}
;

stmt_list : stmt                                                                                   
            | stmt_list stmt                                                                      {/*printf("STATEMENT\n");*/}   
;

stmt : general_stmt ';'                                                                           {/*printf("STATEMENT\n");*/}
     | var_assign ';'                                                                     
     | func_declaration     
;

func_declaration : type FUNCTION ID '(' params_list ')' '{' stmt_list '}'                         {printf("FUNÇÃO\n");}
;

general_stmt : var_declaration                                                                    {printf("STATEMENT GERAL - var declaration\n");}
     | list_initialization                                                                        {printf("STATEMENT GERAL - list initialization\n");}
     | list_assign                                                                                {/*printf("ID\n");*/}
     | struct_initialization
     /* | type_declaration */
;

general_stmt_list : general_stmt ';'
                  | general_stmt_list general_stmt ';'                                             {printf("STATEMENT GERAL LISTA\n");}                                                                            
;

params_list : 
            | var_declaration_list {printf("PARAM LISTA\n");}
;

var_declaration : primitive_type ID                                                                {printf("VAR DECLARATION - %s\n", $2);}
                | list_declaration                                                                 {/*printf("LIST DECLARATION\n");*/}
;

var_declaration_list : var_declaration                                                             {printf("VAR DECLARATION LIST\n");}
                     | var_declaration ',' var_declaration_list                                    {/*printf("LIST DECLARATION\n");*/}
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

struct_initialization: STRUCT ID '=' NEW STRUCT '{' var_declaration_list '}'                       {printf("INICIALIZAÇÃO DE REGISTRO\n");}
;	

var_assign : ID '=' factor                                                                            {printf("VAR_ASSIGN\n");}
           | ID composite_assign_operator factor                                                      {printf("VAR_ASSIGN WITH OPERATOR\n");}
;

composite_assign_operator : SUM_ASSIGN                                                             {printf("SUM_ASSIGN\n");}
                | SUBTRACTION_ASSIGN                                                               {printf("SUBTRACTION_ASSIGN\n");}
                | TIMES_ASSIGN                                                                     {printf("TIMES_ASSIGN\n");}
                | DIVISION_ASSIGN                                                                  {printf("DIVISION_ASSIGN\n");}
;

/* expression : expression AND composite_expression
           | expression OR composite_expression
           | composite_expression
; */

/* composite_expression : composite_expression EQUALS relation_expression
                     | composite_expression DIFF relation_expression
                     | relation_expression
; */
/* 
relation_expression : relation_expression '>' arithmatic_expression
                    | relation_expression '<' arithmatic_expression
                    | relation_expression GTE arithmatic_expression
                    | relation_expression LTE arithmatic_expression
                    | arithmatic_expression
; */

/* arithmatic_expression : arithmatic_expression '+' factor
                      | arithmatic_expression '-' factor
                      | factor
; */

factor : factor '*' unary                                                                          {printf("FACTOR - TIMES\n");} 
       | factor '/' unary                                                                          {printf("FACTOR - DIVISION\n");} 
       | factor INT_DIVISION unary                                                                 {printf("FACTOR - INT DIVISION\n");} 
       | unary                                                                                     {printf("FACTOR - UNARY\n");} 
;
 
unary : unary UNARY_SUM
      | unary UNARY_SUBTRACTION 
      /* | expression  */
      | ID                                                                                         {/*printf("UNARY - ID\n");*/} 
      | INT_LITERAL                                                                                {/*printf("UNARY - INT LITERAL\n");*/} 
      | FLOAT_LITERAL                                                                              {/*printf("UNARY - FLOAT LITERAL\n");*/} 
      | BOOL_LITERAL                                                                               {/*printf("UNARY - BOOL LITERAL\n");*/} 
      | STRING_LITERAL                                                                             {/*printf("UNARY - STRING LITERAL\n");*/} 
      /* | func_call                                                                             {printf("STRING LITERAL\n");}  */
; 
/* 
func_call: ID '(' args ')'
;

args : args ',' expression
     | expression
     |
; */

%%

int main (void) {
	return yyparse ( );
}

int yyerror (char *msg) {
	fprintf (stderr, "%d: %s at '%s'\n", yylineno, msg, yytext);
	return 0;
}