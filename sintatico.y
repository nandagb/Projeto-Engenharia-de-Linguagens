%{
#include <stdio.h>
#include "./../lib/record.h"
#include "./../lib/cat.h"
#include "./../lib/file_gen.h"

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
     struct record * rec;
	};

%token <sValue> ID STRING_LITERAL FLOAT_LITERAL INT_LITERAL BOOL_LITERAL
/* %token <fValue>  */
/* %token <iValue>  */
%token INTEGER LIST STRUCT CONTINUE WHILE FLOAT STRING DO BREAK RETURN FOR VOID BOOLEAN FUNCTION NEW SUM_ASSIGN SUBTRACTION_ASSIGN TIMES_ASSIGN DIVISION_ASSIGN AND OR EQUALS DIFF GTE LTE INT_DIVISION UNARY_SUM UNARY_SUBTRACTION IF ELSE ELSE_IF INPUT OUTPUT SWITCH CASE DEFAULT ADD REMOVE

/* %type <rec> func_declaration_list general_stmt_list func_declaration stmt_list stmt general_stmt access_assign 
%type <rec> var_assign list_assign if return while do_while for expression write switch list_push list_remove 
%type <rec> type params_list var_declaration list_initialization struct_declaration var_initialization 
%type <rec> var_declaration_list primitive_type list_declaration unary access_suffix_list access access_suffix
%type <rec> int_literal float_literal list_types composite_assign_operator comparison_expression 
%type <rec> relation_expression arithmatic_expression factor func_call read args if_complement else_if cases
%type <rec> for_initialization for_step input_args */

%type <rec> primitive_type var_declaration params_list stmt general_stmt stmt_list 
%type <rec> func_declaration func_declaration_list general_stmt_list type list_types
%type <rec> list_declaration list_initialization struct_declaration var_declaration_list
%type <rec> var_initialization expression comparison_expression relation_expression
%type <rec> arithmatic_expression factor unary int_literal

%start prog
 
%%
prog : func_declaration_list
     {
          gen_file($1->code, "./output/output.c");
          free($1);
     }
     | general_stmt_list func_declaration_list
     {
          printf("A0: \n%s%s\n", $1->code, $2->code);
          char * str_list[] = {$1->code, $2->code};
          int list_size = 2;
          char * s = cat(str_list, list_size);
          
          freeRecord($1);
          freeRecord($2);
          
          gen_file(s, "./output/output.c");
          free(s);
     }
;

general_stmt   : var_declaration
               {
                    $$ = createRecord($1->code, EUNTYPED);
                    free($1);
               }
               | list_initialization
               {
                    $$ = createRecord($1->code, EUNTYPED);
                    free($1);
               }
               | struct_declaration
               {
                    $$ = createRecord($1->code, EUNTYPED);
                    free($1);
               }
               | var_initialization
               {
                    $$ = createRecord($1->code, EUNTYPED);
                    free($1);
               }
;

general_stmt_list   : general_stmt ';'
                    {
                         printf("A1: %s\n", $1->code);
                         
                         char * str_list[] = {$1->code, ";\n"};
                         int list_size = 2;
                         char * s = cat(str_list, list_size);
                         
                         freeRecord($1);
                         
                         $$ = createRecord(s, EUNTYPED);
                         free(s);
                    }
                    | general_stmt_list general_stmt ';'
                    {
                         printf("A2: %s\n", $1->code);
                         
                         char * str_list[] = {$1->code, $2->code, ";\n"};
                         int list_size = 3;
                         char * s = cat(str_list, list_size);
                         
                         freeRecord($1);
                         freeRecord($2);
                         
                         $$ = createRecord(s, EUNTYPED);
                         free(s);
                    }
;

func_declaration_list    : func_declaration
                         {
                              $$ = createRecord($1->code, EUNTYPED);
                              free($1);
                         }
                         | func_declaration_list func_declaration
                         {
                              char * str_list[] = {$1->code, $2->code};
                              int list_size = 2;
                              char * s = cat(str_list, list_size);
                              
                              freeRecord($1);
                              freeRecord($2);
                              
                              $$ = createRecord(s, EUNTYPED);
                              free(s);
                         }
;

func_declaration    : type FUNCTION ID '(' params_list ')' '{' stmt_list '}'
                    {
                         char * str_list[] = {$1->code, $3, "(", $5->code, ")", "{\n\t", $8->code, "}"};
                         int list_size = 8;
                         char * s = cat(str_list, list_size);
                         
                         freeRecord($1);
                         freeRecord($5);
                         freeRecord($8);
                         
                         $$ = createRecord(s, EUNTYPED);
                         free(s);
                    }
;

stmt_list : stmt
          {
               $$ = createRecord($1->code, EUNTYPED);
               free($1);
          }
          | stmt_list stmt
          {
               char * str_list[] = {$1->code, $2->code};
               int list_size = 2;
               char * s = cat(str_list, list_size);
               
               freeRecord($1);
               freeRecord($2);
               
               $$ = createRecord(s, EUNTYPED);
               free(s);
          }
;

stmt : general_stmt ';'
     {
          char * str_list[] = {$1->code, ";\n"};
          
          int list_size = 2;
          char * s = cat(str_list, list_size);
          freeRecord($1);
          
          $$ = createRecord(s, EUNTYPED);
          free(s);
     }
     | access_assign ';'
     /* {
          char * str_list[] = {$1->code, ";"};
          int list_size = 2;
          char * s = cat(str_list, list_size);
          
          freeRecord($1);
          
          $$ = createRecord(s, EUNTYPED);
          free(s);
     } */
     | var_assign ';'                                                                     
     | list_assign ';'                                                                            {/*printf("ID\n");*/}
     | func_declaration
     | if
     | return ';'
     | BREAK ';'                                                                                  {/*printf("BREAK\n");*/}
     | CONTINUE ';'                                                                               {/*printf("CONTINUE\n");*/}
     | while
     | do_while ';'
     | for
     | expression ';'         
     /* | read ';' */
     | write ';'
     /* | struct_attr_assign ';' */
     | switch
     | list_push ';'
     | list_remove ';'
;


return : RETURN
       /* {
          $$ = createRecord("return ", EUNTYPED);
       } */
       | RETURN expression
       /* {
          char * str_list[] = {"return ", $2->code};
          int list_size = 2;
          char * s = cat(str_list, list_size);
          
          // Free só é necessário quando se é utilizado malloc(), calloc() e realloc(), ou seja, memória alocada dinamicamente.
          // for(int i = 0; i < list_size; i++){
          //      free(str_list[i]);
          // }
          // free(str_list);
          freeRecord($2);
          
          $$ = createRecord(s, EUNTYPED);
          free(s);
       }                                                                      */
;

/* ANALISAR A POSSIBILIDADE DE UTILIZAR UMA LISTA LIGADA PARA LISTA DE PARÂMETROS OU LISTA DE STATEMENTS */
params_list :
            {
               $$ = createRecord("",EUNTYPED);
            }
            | var_declaration_list
;

var_initialization  : primitive_type ID '=' expression
                    {
                         printf("A3: %s %s = %s\n", $1->code, $2, $4->code);
                         printf("A3: %s\n", $2);
                         printf("A3: %s\n", $4->code);
                         //primitive_type ID = expression;
                         //int exemplo = 2;
                         //int exemplo = 2;
                         char * str_list[] = {$1->code, $2, "=", $4->code};
                         int list_size = 4;
                         char * s = cat(str_list, list_size);
                         
                         freeRecord($1);
                         free($2);
                         freeRecord($4);
                         
                         $$ = createRecord(s, EUNTYPED);
                         free(s);
                    }

// TODO
var_declaration     : primitive_type ID
                    {
                         //int exemplo
                         //int exemplo
                         char * str_list[] = {$1->code, $2};
                         int list_size = 2;
                         char * s = cat(str_list, list_size);
                         
                         freeRecord($1);
                         free($2);
                         
                         $$ = createRecord(s, EUNTYPED);
                         free(s);
                    }
                    | list_declaration                                                                {/*printf("LIST DECLARATION\n");*/}
                    | ID ID
                    {
                         // printf("A9");
                    }
;

var_declaration_list     : var_declaration
                         {
                              char * str_list[] = {$1->code, ";"};
                              int list_size = 2;
                              
                              char * s = cat(str_list, list_size);
                              freeRecord($1);

                              $$ = createRecord(s, EUNTYPED);
                              free(s);
                         }
                         | var_declaration_list ',' var_declaration
                         { 
                              char * str_list[] = {$1->code, "\n\t",$3->code, ";"};
                              int list_size = 4;
                              char * s = cat(str_list, list_size);
                              
                              freeRecord($1);
                              freeRecord($3);

                              $$ = createRecord(s, EUNTYPED);
                              free(s);
                         }
;


list_declaration    : LIST '<' list_types '>' ID 
                    {
                         //list_types ID[]
                         //int exemplo[]
                         char * str_list[] = {$3->code, $5, "[]"};
                         int list_size = 3;
                         char * s = cat(str_list, list_size);
                         
                         // $1 has no type declared, does it need one?
                         // free($1);
                         freeRecord($3);
                         free($5);
                         
                         $$ = createRecord(s, EUNTYPED);
                         free(s);
                    }
;

list_types     : primitive_type
               {
                    $$ = createRecord($1->code, EINTEGER);
                    free($1);
               }
               | ID                                                                                   {}
               | LIST '<' list_types '>'                                                              {}
;

//TODO
list_initialization : list_declaration '=' NEW LIST '<' '>' '(' ')'
                    {
                         //list_types ID[] = novo Lista<>()
                         //int exemplo[] = {}
                         char * str_list[] = {$1->code, "=", "{}"};
                         int list_size = 3;
                         char * s = cat(str_list, list_size);
                         
                         free($1);
                         // free($3);
                         // free($4);
                         
                         $$ = createRecord(s, EUNTYPED);
                         free(s);
                    }
                    | list_declaration '=' NEW LIST '<' '>' '(' ID ')'                            { /* printf("LIST INITIALIZATION FROM ANOTHER LIST (NEW COPY)\n"); */ }
;

list_assign : ID '=' NEW LIST '<' '>' '(' ')'                                                     { /* printf("LIST ASSIGN\n"); */ }
            | ID '=' NEW LIST '<' '>' '(' ID ')'                                                  { /* printf("LIST ASSIGN FROM ANOTHER LIST (NEW COPY)\n"); */ }
;

list_push: ID access_suffix_list '.' ADD '(' expression ')'                                       {}
         | ID '.' ADD '(' expression ')'                                                          {}
;

list_remove: ID access_suffix_list '.' REMOVE '(' ')'                                             {}
           | ID '.' REMOVE '(' ')'                                                                {}
;

access_assign : access '=' expression
              /* {
                    char * str_list[] = {$1->code, "=", $3->code};
                    int list_size = 3;
                    char * s = cat(str_list, list_size);

                    freeRecord($1);
                    freeRecord($3);

                    $$ = createRecord(s, EUNTYPED);
                    free(s);
              } */
;

access : ID access_suffix_list
       /* {
          char * str_list[] = {$1, $2->code};
          int list_size = 2;
          char * s = cat(str_list, list_size);

          free($1);
          freeRecord($2);

          $$ = createRecord(s, EUNTYPED);
          free(s);
       } */
;

access_suffix_list : access_suffix
                   | access_suffix_list access_suffix
;

// TODO: Verficação do tipo
access_suffix : '[' expression ']'
               /* { 
                    char * str_list[] = {"[", $2->code, "]"};
                    int list_size = 3;
                    char * s = cat(str_list, list_size);

                    freeRecord($2);
                    
                    $$ = createRecord(s, EUNTYPED);
                    free(s);
               } */
              | '.' ID                                                                            
              /* { 
                    char * str_list[] = {".", $2, "]"};
                    int list_size = 2;
                    char * s = cat(str_list, list_size);

                    for(int i = 0; i < list_size; i++){
                         free(str_list[i]);
                    }
                    free($2);

                    $$ = createRecord(s, EUNTYPED);
                    free(s);
               } */
;

int_literal : INT_LITERAL
            {
               printf("A5: %s\n", $1);
               
               char * str_list[] = {$1};
               int list_size = 1;
               char * s = cat(str_list, list_size);
               
               // ASK: WHY RELEASING $1 gives segmentation fault later on the code?
               // free($1);

               $$ = createRecord(s, EINTEGER);
               free(s);
            }
            | '-' INT_LITERAL             
            /* {
               char * str_list[] = {"-", $2};
               int list_size = 2;
               char * s = cat(str_list, list_size);

               for(int i = 0; i < list_size; i++){
                    free(str_list[i]);
               }
               free($2);

               $$ = createRecord(s,EINTEGER);
               free(s);
            } */
;

float_literal : FLOAT_LITERAL
              /* {
                    $$ = createRecord($1, EFLOAT);
                    free($1);
              } */
              | '-' FLOAT_LITERAL
              /* {
                    char * str_list[] = {"-", $2};
                    int list_size = 2;
                    char * s = cat(str_list, list_size);

                    for(int i = 0; i < list_size; i++){
                         free(str_list[i]);
                    }
                    free($2);

                    $$ = createRecord(s,EFLOAT);
                    free(s);
              } */
;

type : primitive_type
     /* {
          printf("A10");
          $$ = createRecord($1->code,$1->type);
          free($1);
     } */
     | LIST '<' list_types '>'
     /* {
          ESTA DECLARAÇÃO NÃO VAI FUNCIONAR
          TODO: Verficar como faz lista em C
          char * str_list[] = {"list","<", $3->code, ">"};
          int list_size = 4;
          char * s = cat(str_list, list_size);

          for(int i = 0; i < list_size; i++){
               free(str_list[i]);
          }
          free($3);

          $$ = createRecord(s,EUNTYPED);
          free(s);
     } */
     | STRUCT                                
     /* {
          $$ = createRecord("struct ",EUNTYPED);
     } */
;

primitive_type : INTEGER
               {
                    $$ = createRecord("int ",EINTEGER);
               }
               | FLOAT
               {
                    $$ = createRecord("float ",EFLOAT);
               }
               | STRING
               {
                    $$ = createRecord("char * ",ESTRING);
               }
               | VOID
               {
                    $$ = createRecord("void ",EVOID);
               }
               | BOOLEAN
               {
                    $$ = createRecord("bool ",EBOOL);
               }
;

struct_declaration  : STRUCT ID '=' '{' var_declaration_list '}'
                    {
                         //Registro ID = { var_declaration_list }
                         //Registro ID = { int exemplo, int exemplo2 }
                         //struct exemplo{int exemplo; int exemplo2;}
                         char * str_list[] = {"struct ", $2, "{\n\t", $5->code, "\n}"};
                         int list_size = 5;
                         char * s = cat(str_list, list_size);
                         
                         // free($1);
                         free($2);
                         free($5);
                         
                         $$ = createRecord(s, EUNTYPED);
                         free(s);
                    }
;	

var_assign : ID '=' expression                                                                     {/*printf("VAR_ASSIGN\n");*/}
           | ID composite_assign_operator expression                                               {/*printf("VAR_ASSIGN WITH OPERATOR\n");*/}
;

composite_assign_operator : SUM_ASSIGN                                                             {/*printf("SUM_ASSIGN\n");*/}
                | SUBTRACTION_ASSIGN                                                               {/*printf("SUBTRACTION_ASSIGN\n");*/}
                | TIMES_ASSIGN                                                                     {/*printf("TIMES_ASSIGN\n");*/}
                | DIVISION_ASSIGN                                                                  {/*printf("DIVISION_ASSIGN\n");*/}
;

expression     : expression AND comparison_expression                                                  {/*printf("EXPRESSION - AND\n");*/} 
               | expression OR comparison_expression                                                   {/*printf("EXPRESSION - OR\n");*/} 
               | comparison_expression
               {
                    $$ = createRecord($1->code, $1->type);
                    freeRecord($1);
               }
;

comparison_expression : comparison_expression EQUALS relation_expression                           {/*printf("COMPARISON_EXPRESSION - EQUALS\n");*/}
                      | comparison_expression DIFF relation_expression                             {/*printf("COMPARISON_EXPRESSION - DIFF\n");*/}
                      | relation_expression
                      {
                         $$ = createRecord($1->code, $1->type);
                         freeRecord($1);
                      }
;

relation_expression : relation_expression '>' arithmatic_expression                                {/*printf("RELATION_EXPRESSION - GREATER\n");*/}
                    | relation_expression '<' arithmatic_expression                                {/*printf("RELATION_EXPRESSION - LESSER\n");*/}
                    | relation_expression GTE arithmatic_expression                                {/*printf("RELATION_EXPRESSION - GREATER EQUAL\n");*/}
                    | relation_expression LTE arithmatic_expression                                {/*printf("RELATION_EXPRESSION - LESSER EQUAL\n");*/}
                    | arithmatic_expression
                    {
                         $$ = createRecord($1->code, $1->type);
                         freeRecord($1);
                    }
;

arithmatic_expression : arithmatic_expression '+' factor                                           {/* printf("ARITHMATIC - SUM\n");*/ }
                      | arithmatic_expression '-' factor                                           {/* printf("ARITHMATIC - MINUS\n");*/ }
                      | factor
                      {
                         $$ = createRecord($1->code, $1->type);
                         freeRecord($1);
                      }
;

factor : factor '*' unary                                                                          {/* printf("FACTOR - TIMES\n");*/} 
       | factor '/' unary                                                                          {/* printf("FACTOR - DIVISION\n");*/} 
       | factor INT_DIVISION unary                                                                 {/* printf("FACTOR - INT DIVISION\n");*/} 
       | unary
       {
          $$ = createRecord($1->code, $1->type);
          freeRecord($1);
       }
;
 
unary : ID UNARY_SUM
      /* {
          char * str_list[] = {$1,"++"};
          int list_size = 2;
          char * s = cat(str_list, list_size);

          for(int i = 0; i < list_size; i++){
               free(str_list[i]);
          }
          free($1);

          $$ = createRecord(s,EUNTYPED);
          free(s);
      } */
      | ID UNARY_SUBTRACTION
      /* {
          char * str_list[] = {$1,"--"};
          int list_size = 2;
          char * s = cat(str_list, list_size);

          for(int i = 0; i < list_size; i++){
               free(str_list[i]);
          }
          free($1);

          $$ = createRecord(s,EUNTYPED);
          free(s);
      } */
      | '(' expression ')'
      /* {
          char * str_list[] = {"(", $2->code, ")"};
          int list_size = 2;
          char * s = cat(str_list, list_size);
          
          //TODO: Colocar freeRecord em todos os records
          for(int i = 0; i < list_size; i++){
               free(str_list[i]);
          }
          freeRecord($2);
          
          $$ = createRecord(s, EUNTYPED);
          free(s); 
      } */
      | ID
      /* {
          $$ = createRecord($1, EUNTYPED);free($1);
      } */
      | int_literal
      {
          printf("A4: %s\n", $1->code);
          $$ = createRecord($1->code, $1->type);
          freeRecord($1);
      }
      | float_literal
      /* {
          $$ = createRecord($1->code, EFLOAT); freeRecord($1);
      } */
      | BOOL_LITERAL
      /* {
          $$ = createRecord($1, EBOOL); free($1);
      } */
      | STRING_LITERAL
      /* {
          $$ = createRecord($1, ESTRING); free($1);
      } */
      | func_call
      /* {
          $$ = createRecord($1->code, EUNTYPED); freeRecord($1);
      } */
      | read
      /* {
         $$ = createRecord($1->code, EUNTYPED); freeRecord($1);
      } */
      | access
      /* {
         $$ = createRecord($1->code, EUNTYPED); freeRecord($1);
      } */
; 

func_call : ID '(' args ')'
          /* {
               char * str_list[] = {$1, "(", $3->code, ")"};
               int list_size = 4;
               char * s = cat(str_list, list_size);
               
               //TODO: Colocar freeRecord em todos os records
               for(int i = 0; i < list_size; i++){
                    free(str_list[i]);
               }
               free($1);
               freeRecord($3);
               
               $$ = createRecord(s, EUNTYPED);
               free(s);
          } */
;

args : args ',' expression
     | expression
     |
     /* {
          $$ = createRecord("", EUNTYPED);
     } */
;

if : IF '(' expression ')' '{' stmt_list '}' if_complement                                          {/*printf("IF \n");*/} 
;

if_complement : ELSE '{' stmt_list '}'                                                              {/*printf("ELSE \n");*/} 
              | else_if                                                                             {/*printf("ELSE IF \n")*/;}
              | else_if ELSE '{' stmt_list '}'                                                      {/*printf("ELSE IF COM ELSE \n")*/;}
              |
              /* {
                    $$ = createRecord("",EUNTYPED);
              } */

else_if : else_if ELSE_IF '(' expression ')' '{' stmt_list '}'
        /* {
          // NÃO É PERMITIDO USAR ELSE
          // Verificar como fazer o else usando goto | Confirmar no documento da atividade
          char * str_list[] = {$1->code, "else if" "(", $4->code, ")", "{", $7->code, "}"};
          int list_size = 7;
          char * s = cat(str_list, list_size);
          
          //TODO: Colocar freeRecord em todos os records
          for(int i = 0; i < list_size; i++){
               free(str_list[i]);
          }
          freeRecord($1);
          freeRecord($4);
          freeRecord($7);
          
          $$ = createRecord(s, EUNTYPED);
          free(s);
        } */
        | ELSE_IF '(' expression ')' '{' stmt_list '}'
        /* {
          // NÃO É PERMITIDO USAR ELSE
          // Verificar como fazer o else usando goto | Confirmar no documento da atividade
          char * str_list[] = {"else if" "(", $3->code, ")", "{", $6->code, "}"};
          int list_size = 6;
          char * s = cat(str_list, list_size);
          
          //TODO: Colocar freeRecord em todos os records
          for(int i = 0; i < list_size; i++){
               free(str_list[i]);
          }
          freeRecord($3);
          freeRecord($6);
          
          $$ = createRecord(s, EUNTYPED);
          free(s);
        } */

switch : SWITCH '(' ID ')' '{' cases DEFAULT ':' stmt_list '}'                                      {/*printf("SWITCH COM DEFAULT \n");*/}
       | SWITCH '(' ID ')' '{' cases '}'                                                            {/*printf("SWITCH SEM DEFAULT \n");*/}
;

cases : cases case                                                                        
      | case                                                                                         
      /* {
          $$ = createRecord("case",EUNTYPED);
      } */
;

case : CASE expression ':' stmt_list                                                                {/*printf("CASE \n");*/}
;

while : WHILE '(' expression ')' '{' stmt_list '}'                                                  {/*printf("WHILE\n");*/}


do_while : DO '{' stmt_list '}' WHILE '(' expression ')'                                            {/*printf("DO WHILE\n");*/}

for_initialization : var_initialization
                   | var_assign
                   ;

for_step : var_assign
         | expression
         ;

for : FOR '(' for_initialization ',' expression ',' for_step ')' '{' stmt_list '}'                  
     /* {
          //VERIFICAR SE É PERTMITIDO USAR O FOR DO C
          //SE NÃO FOR, ENCONTRAR OUTRA MANEIRA
          char * str_list[] = {"for" "(", $3->code, ",", $5->code, ",", $7->code, ")", "{", $10->code , "}"};
          int list_size = 11;
          char * s = cat(str_list, list_size);
          
          //TODO: Colocar freeRecord em todos os records
          for(int i = 0; i < list_size; i++){
               free(str_list[i]);
          }
          freeRecord($3);
          freeRecord($5);
          freeRecord($7);
          freeRecord($10);
          
          $$ = createRecord(s, EUNTYPED);
          free(s);
     } */

read : INPUT '(' input_args ')'
          /* {
               char * str_list[] = {"scanf", "(", $3->code, ")"};
               int list_size = 4;
               char * s = cat(str_list, list_size);
               
               for(int i = 0; i < list_size; i++){
                    free(str_list[i]);
               }
               freeRecord($3);

               $$ = createRecord(s, EUNTYPED);
               free(s);
          } */
;

write : OUTPUT '(' expression ')'                                                                   
          /* {
               char * str_list[] = {"printf", "(", $3->code, ")"};
               int list_size = 4;
               char * s = cat(str_list, list_size);
               
               for(int i = 0; i < list_size; i++){
                    free(str_list[i]);
               }
               freeRecord($3);
               
               $$ = createRecord(s, EUNTYPED);
               free(s);
          } */
;

input_args :
           /* {
               $$ = createRecord("",EUNTYPED);
           } */
           | STRING_LITERAL
           /* {
               $$ = createRecord($1,STRING);
               free($1);
           } */
;

/* type_declaration : STRUCT ID '{' var_declaration_list '}' */

%%

int main (void) {
	return yyparse ( );
}

int yyerror (char *msg) {
	fprintf (stderr, "%d: %s at '%s'\n", yylineno, msg, yytext);
	return 0;
}