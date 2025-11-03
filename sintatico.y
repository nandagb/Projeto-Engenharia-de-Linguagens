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
%token INTEGER LIST STRUCT FLOAT STRING VOID BOOLEAN FUNCTION NEW SUM_ASSIGN SUBTRACTION_ASSIGN TIMES_ASSIGN DIVISION_ASSIGN AND OR EQUALS DIFF GTE LTE INT_DIVISION UNARY_SUM UNARY_SUBTRACTION IF ELSE ELSE_IF

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
     | list_assign ';'                                                                            {/*printf("ID\n");*/}
     | func_call ';'
     | func_declaration
     | if
;

func_declaration : type FUNCTION ID '(' params_list ')' '{' stmt_list '}'                         {printf("FUNÇÃO\n");}
;

general_stmt : var_declaration                                                                    {printf("STATEMENT GERAL - var declaration\n");}
             | list_initialization                                                                        {printf("STATEMENT GERAL - list initialization\n");}
             | struct_initialization
             /* | type_declaration */
;

general_stmt_list : general_stmt ';'
                  | general_stmt_list general_stmt ';'                                             {/*printf("STATEMENT GERAL LISTA\n");*/}
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

var_assign : ID '=' expression                                                                     {printf("VAR_ASSIGN\n");}
           | ID composite_assign_operator expression                                               {printf("VAR_ASSIGN WITH OPERATOR\n");}
;

composite_assign_operator : SUM_ASSIGN                                                             {printf("SUM_ASSIGN\n");}
                | SUBTRACTION_ASSIGN                                                               {printf("SUBTRACTION_ASSIGN\n");}
                | TIMES_ASSIGN                                                                     {printf("TIMES_ASSIGN\n");}
                | DIVISION_ASSIGN                                                                  {printf("DIVISION_ASSIGN\n");}
;

expression : expression AND comparison_expression                                                  {printf("EXPRESSION - AND\n");} 
           | expression OR comparison_expression                                                   {printf("EXPRESSION - OR\n");} 
           | comparison_expression                                                                 {printf("EXPRESSION - COMPOSITE\n");}
;

comparison_expression : comparison_expression EQUALS relation_expression                           {/*printf("COMPARISON_EXPRESSION - EQUALS\n");*/}
                      | comparison_expression DIFF relation_expression                             {/*printf("COMPARISON_EXPRESSION - DIFF\n");*/}
                      | relation_expression                                                        {/*printf("COMPARISON_EXPRESSION - RELATION\n");*/}
;

relation_expression : relation_expression '>' arithmatic_expression                                {/*printf("RELATION_EXPRESSION - GREATER\n");*/}
                    | relation_expression '<' arithmatic_expression                                {/*printf("RELATION_EXPRESSION - LESSER\n");*/}
                    | relation_expression GTE arithmatic_expression                                {/*printf("RELATION_EXPRESSION - GREATER EQUAL\n");*/}
                    | relation_expression LTE arithmatic_expression                                {/*printf("RELATION_EXPRESSION - LESSER EQUAL\n");*/}
                    | arithmatic_expression                                                        {/*printf("RELATION_EXPRESSION - ARITHMATIC\n");*/}
;

arithmatic_expression : arithmatic_expression '+' factor                                           {/* printf("ARITHMATIC - SUM\n");*/ }
                      | arithmatic_expression '-' factor                                           {/* printf("ARITHMATIC - MINUS\n");*/ }
                      | factor                                                                     {/* printf("ARITHMATIC - FACTOR\n");*/ }
;

factor : factor '*' unary                                                                          {/* printf("FACTOR - TIMES\n");*/} 
       | factor '/' unary                                                                          {/* printf("FACTOR - DIVISION\n");*/} 
       | factor INT_DIVISION unary                                                                 {/* printf("FACTOR - INT DIVISION\n");*/} 
       | unary                                                                                     {/* printf("FACTOR - UNARY\n");*/} 
;
 
unary : unary UNARY_SUM
      | unary UNARY_SUBTRACTION 
      | '(' expression ')'                                                                         {printf("UNARY - EXPRESSION\n");}
      | ID                                                                                         {/*printf("UNARY - ID\n");*/} 
      | INT_LITERAL                                                                                {/*printf("UNARY - INT LITERAL\n");*/} 
      | FLOAT_LITERAL                                                                              {/*printf("UNARY - FLOAT LITERAL\n");*/} 
      | BOOL_LITERAL                                                                               {/*printf("UNARY - BOOL LITERAL\n");*/} 
      | STRING_LITERAL                                                                             {/*printf("UNARY - STRING LITERAL\n");*/} 
      | func_call                                                                                  {printf("UNARY - FUNC CALL\n");} 
; 

func_call: ID '(' args ')'                                                                         {printf("FUNC CALL\n");} 
;

args : args ',' expression
     | expression
     |
;

if : IF '(' expression ')' '{' stmt_list '}' if_complement                                          {printf("IF \n");} 
;

if_complement : ELSE '{' stmt_list '}'                                                              {printf("ELSE \n");} 
              | else_if                                                                             {printf("ELSE IF \n");}
              | else_if ELSE '{' stmt_list '}'                                                      {printf("ELSE IF COM ELSE \n");}
              |

else_if : else_if ELSE_IF '(' expression ')' '{' stmt_list '}'
        | ELSE_IF '(' expression ')' '{' stmt_list '}'

/* type_declaration : STRUCT ID '{' var_declaration_list '}' */

%%

int main (void) {
	return yyparse ( );
}

int yyerror (char *msg) {
	fprintf (stderr, "%d: %s at '%s'\n", yylineno, msg, yytext);
	return 0;
}