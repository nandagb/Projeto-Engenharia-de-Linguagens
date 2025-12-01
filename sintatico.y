%{
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include "./../lib/record.h"
#include "./../lib/cat.h"
#include "./../lib/file_gen.h"
#include "./../lib/symbol_table.h"
#include "./../lib/scope.h"
#include "./../lib/labels.h"
#include "./../lib/errors.h"

int yylex(void);
int yyerror(char *s);
extern int yylineno;
extern char * yytext;
table* sym_table;
Stack stack;
Stack labels_stack;

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

/*%type <rec> list_assign do_while write switch list_push list_remove 
%type <rec> access 
%type <rec> composite_assign_operator 
%type <rec> cases*/

%type <rec> primitive_type var_declaration params_list stmt general_stmt stmt_list type_conversion
%type <rec> func_declaration func_declaration_list general_stmt_list type list_types return
%type <rec> list_declaration list_initialization struct_declaration var_declaration_list /*list_push*/ access_suffix access_suffix_list access_assign
%type <rec> var_initialization expression comparison_expression relation_expression
%type <rec> arithmatic_expression factor unary int_literal float_literal func_call args
%type <rec> var_assign write

%type <rec> if if_complement else_if while read input_args for for_initialization for_step

%start prog
 
%%
prog : 
     {
          /* creates symbol table for the program*/
          sym_table = table_create();
          initialize(&stack);
          initialize(&labels_stack);
          push(&stack, "global");
     }
     prog_options
     {
          table_destroy(sym_table);
          pop(&stack);

          // PRINT ALL ERRORS FOUND
          int error_count = get_error_count();
          char** errors = get_errors();

          if (error_count > 0) {
               printf("Foram encontrados %d erros:\n", error_count);

               for (int i = 0; i < error_count; i++) {
                    printf("%s\n", errors[i]);
                    free(errors[i]);
               }

               printf("\nCompilação abortada.\n");
               exit(1);
          }
          // ====================================
     }
     
;

prog_options : func_declaration_list
     {
          char * include_list[] = {"#include <stdbool.h>", "\n", "#include <stdlib.h>", "\n", "#include <stdio.h>", "\n", "#include <string.h>", "\n"};
          char * include_str = cat(include_list, 8);

          char * str_list[] = {include_str, $1->code};
          int list_size = 2;
          char * s = cat(str_list, list_size);

          gen_file(s, "./output/output.c");
          free($1);
     }
     | general_stmt_list func_declaration_list
     {
          printf("A0: \n%s%s\n", $1->code, $2->code);
          char * include_list[] = {"#include <stdbool.h>", "\n"};
          char * include_str = cat(include_list, 2);
          
          char * str_list[] = {include_str, $1->code, $2->code};
          int list_size = 3;
          char * s = cat(str_list, list_size);
          
          gen_file(s, "./output/output.c");
          free(s);

          freeRecord($1);
          freeRecord($2);
     }
;

general_stmt   : var_declaration
               {
                    $$ = createRecord($1->code, $1->type);
                    free($1);
               }
               | list_initialization
               {
                    $$ = createRecord($1->code, $1->type);
                    free($1);
               }
               | struct_declaration
               {
                    $$ = createRecord($1->code, EUNTYPED);
                    free($1);
               }
               | var_initialization
               {
                    $$ = createRecord($1->code, $1->type);
                    free($1);
               }
;

general_stmt_list   : general_stmt ';'
                    {
                         // printf("A1: %s\n", $1->code);
                         
                         char * str_list[] = {$1->code, ";\n"};
                         int list_size = 2;
                         char * s = cat(str_list, list_size);
                         
                         $$ = createRecord(s, EUNTYPED);

                         freeRecord($1);
                         free(s);
                    }
                    | general_stmt_list general_stmt ';'
                    {
                         // printf("A2: %s\n", $1->code);
                         
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

func_declaration    : type FUNCTION ID '(' params_list ')' '{' { push(&stack,"func"); } stmt_list '}' {pop(&stack);}
                    {
                         char* key = strdup(peek(&stack));
                         strcat(key, "@");
                         strcat(key, $3);

                         table_entry* entry = table_get_entry_object(sym_table, key);
                          if (entry != NULL) {
                              // Variable was already initialized
                              printf("Erro! A variável %s já foi declarada!\n", key);
                         }
                         else {
                              // initilize variable
                              table_set(sym_table, key, $3, $1->type, EFUNC, NULL);
                              entry = table_get_entry_object(sym_table, key);
                         }

                         char * str_list[] = {$1->code, $3, "(", $5->code, ")", "{\n\t", $9->code, "}\n"};
                         int list_size = 8;
                         char * s = cat(str_list, list_size);
                         
                         freeRecord($1);
                         freeRecord($5);
                         freeRecord($9);
                         
                         $$ = createRecord(s, EUNTYPED);
                         free(s);
                         free(key);
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

          $$ = createRecord(s, $1->type);

          freeRecord($1);
          free(s);
     }
     | access_assign ';'
     {
          char * str_list[] = {$1->code, ";"};
          int list_size = 2;
          char * s = cat(str_list, list_size);

          $$ = createRecord(s, $1->type);

          freeRecord($1);
          free(s);
     }
     | var_assign ';'
     {
          char * str_list[] = {$1->code, ";\n"};

          int list_size = 2;
          char * s = cat(str_list, list_size);

          $$ = createRecord(s, $1->type);

          freeRecord($1);
          free(s);
     }
     | list_assign ';'                                                                            {/*printf("ID\n");*/}
     | func_declaration
     | if 
     | return ';'
     {
          char * str_list[] = {$1->code, ";\n"};

          int list_size = 2;
          char * s = cat(str_list, list_size);

          $$ = createRecord(s, $1->type);

          freeRecord($1);
          free(s);
     }
     | BREAK ';'                                                                                  {/*printf("BREAK\n");*/}
     | CONTINUE ';'                                                                               {/*printf("CONTINUE\n");*/}
     | while
     | do_while ';'
     | for
     | expression ';'
     {
          char * str_list[] = {$1->code, ";\n"};

          int list_size = 2;
          char * s = cat(str_list, list_size);

          $$ = createRecord(s, $1->type);

          freeRecord($1);
          free(s);
     }
     | write ';'
     {
          char * str_list[] = {$1->code, ";\n"};

          int list_size = 2;
          char * s = cat(str_list, list_size);

          $$ = createRecord(s, $1->type);

          freeRecord($1);
          free(s);
     }
     /* | struct_attr_assign ';' */
     | switch
     | list_push ';'
     | list_remove ';'
;


return : RETURN
       {
          $$ = createRecord("return ", EUNTYPED);
       }
       | RETURN expression
       {
          char * str_list[] = {"return ", $2->code};
          int list_size = 2;
          char * s = cat(str_list, list_size);
          
          $$ = createRecord(s, $2->type);

          freeRecord($2);
          free(s);
       }
;

/* ANALISAR A POSSIBILIDADE DE UTILIZAR UMA LISTA LIGADA PARA LISTA DE PARÂMETROS OU LISTA DE STATEMENTS */
params_list :
            {
               $$ = createRecord("",EUNTYPED);
            }
            | var_declaration_list
            {
               $$ = createRecord($1->code, EUNTYPED);
               free($1);
            }
;

//TODO: EXPRESSIONS
var_initialization  : primitive_type ID '=' expression
                    {
                         table_entry* entry = NULL;
                         int index = stack.top;
                         while(index >= 0){
                              char* strStack = strdup(peek_position(&stack, index));
                              
                              if(strStack != NULL){
                                   char * str_list[] = {strStack, "@", $2};
                                   int list_size = 3;
                                   char * key = cat(str_list, list_size);
                                   entry = table_get_entry_object(sym_table, key);

                                   if(entry != NULL){
                                        break;
                                   }

                                   free(key);
                              }
                              
                              free(strStack);
                              index--;
                         }

                         if (entry != NULL) {
                              // Variable was already initialized
                              printf("Erro! A variável %s já foi declarada!\n", $2);
                         }
                         else {
                              // initilize variable
                              char * str_list[] = {strdup(peek(&stack)), "@", $2};
                              int list_size = 3;
                              char * key = cat(str_list, list_size);

                              table_set(sym_table, key, $2, $1->type, EPRIMARY, NULL);
                              entry = table_get_entry_object(sym_table, key);

                              free(key);
                         }

                         //TODO: permitir coersão de inteiro para real?
                         if (entry->type != $4->type){
                              // Type error!
                              printf("Erro! A variável %s é do tipo %s, e não pode ser inicializada com um valor do tipo %s!\n", $2, type_to_string(entry->type), type_to_string($4->type));
                         }
                         // =============

                         char * str_list[] = {$1->code, $2, " = ", $4->code};
                         int list_size = 4;
                         char * s = cat(str_list, list_size);

                         table_get_type(sym_table, $2);

                         $$ = createRecord(s, $1->type);

                         freeRecord($1);
                         free($2);
                         freeRecord($4);
                         free(s);
                    }

// TODO
var_declaration  : primitive_type ID
                    {
                         table_entry* entry = NULL;
                         int index = stack.top;
                         while(index >= 0){
                              char* strStack = strdup(peek_position(&stack, index));
                              
                              if(strStack != NULL){
                                   char * str_list[] = {strStack, "@", $2};
                                   int list_size = 3;
                                   char * key = cat(str_list, list_size);

                                   entry = table_get_entry_object(sym_table, key);

                                   if(entry != NULL){
                                        break;
                                   }
                                   
                                   free(key);
                              }
                              
                              free(strStack);
                              index--;
                         }

                         if (entry != NULL) {
                              // Variable was already initialized
                              printf("Erro! A variável %s já foi declarada!\n", $2);
                         }
                         else {
                              // initilize variable
                              char* key = strdup(peek(&stack));
                              strcat(key, "@");
                              strcat(key, $2);
                              table_set(sym_table, key, $2, $1->type, EPRIMARY, NULL);
                              free(key);
                         }
                         
                         //int exemplo
                         //int exemplo
                         char * str_list[] = {$1->code, $2};
                         int list_size = 2;
                         char * s = cat(str_list, list_size);
                         $$ = createRecord(s, $1->type);

                         freeRecord($1);
                         free($2);
                         free(s);
                    }
                    | list_declaration
                    {
                         $$ = createRecord($1->code, $1->type);
                         $$->structure = $1->structure;
                         $$->type_string = strdup($1->type_string);

                         freeRecord($1);
                    }
                    | ID ID
                    {
                         table_entry* entry = NULL;
                         int index = stack.top;
                         while(index >= 0){
                              char* strStack = strdup(peek_position(&stack, index));
                              
                              if(strStack != NULL){
                                   char * str_list[] = {strStack, "@", $2};
                                   int list_size = 3;
                                   char * key = cat(str_list, list_size);

                                   entry = table_get_entry_object(sym_table, key);

                                   if(entry != NULL){
                                        break;
                                   }
                                   
                                   free(key);
                              }
                              
                              free(strStack);
                              index--;
                         }

                         if (entry != NULL) {
                              // Variable was already initialized
                              printf("Erro! A variável %s já foi declarada!\n", $2);
                         }
                         else {
                              // initilize variable
                              char* key = strdup(peek(&stack));
                              strcat(key, "@");
                              strcat(key, $2);
                              table_set(sym_table, key, $2, UNDEFINED_TYPE, UNDEFINED_STRUCTURE, NULL);
                              free(key);
                         }

                         char * str_list[] = {"struct ", $1, " * ", $2};
                         int list_size = 4;
                         char * s = cat(str_list, list_size);
                         
                         $$ = createRecord(s, EUNTYPED);
                         
                         free($1);
                         free($2);
                         free(s);
                    }
;

var_declaration_list     : var_declaration
                         {
                              $$ = createRecord($1->code, EUNTYPED);
                              freeRecord($1);
                         }
                         | var_declaration_list ',' var_declaration
                         { 
                              char * str_list[] = {$1->code, ",", $3->code};
                              int list_size = 3;
                              char * s = cat(str_list, list_size);

                              $$ = createRecord(s, EUNTYPED);

                              freeRecord($1);
                              freeRecord($3);
                              free(s);
                         }
;


list_declaration :  list_types ID
                    {
                         // printf("TABLE SIZE: %d\n", stack.top);
                         table_entry* entry = NULL;
                         int index = stack.top;
                         while(index >= 0){
                              char* strStack = strdup(peek_position(&stack, index));
                              
                              if(strStack != NULL){
                                   char * str_list[] = {strStack, "@", $2};
                                   int list_size = 3;
                                   char * key = cat(str_list, list_size);

                                   entry = table_get_entry_object(sym_table, key);

                                   if(entry != NULL){
                                        break;
                                   }
                                   free(key);
                              }

                              free(strStack);
                              index--;
                         }

                         if (entry != NULL) {
                              // Variable was already initialized
                              printf("Erro! A variável %s já foi declarada!\n", $2);
                         }
                         else {
                              // initilize variable
                              char* key = strdup(peek(&stack));
                              strcat(key, "@");
                              strcat(key, $2);
                              table_set(sym_table, key, $2, $1->type, ELIST, NULL);
                              entry = table_get_entry_object(sym_table, key);
                              entry->size = 0;

                              free(key);
                         }

                         char * str_list[] = {$1->code, $2};
                         int list_size = 2;
                         char * s = cat(str_list, list_size);
                         
                         $$ = createRecord(s, $1->type);
                         $$->structure = $1->structure;
                         $$->type_string = strdup($1->type_string);

                         freeRecord($1);
                         free($2);
                         free(s);
                    }
;

list_types     : LIST '<' primitive_type '>'
               {
                    //one dimension list
                    char * str_list[] = {string_to_type_in_C($3->code), " *"};
                    int list_size = 2;
                    char * s = cat(str_list, list_size);

                    $$ = createRecord(s, $3->type);
                    $$->structure = EPRIMARY;
                    $$->type_string = strdup($3->code);

                    free($3);
                    free(s);
                    
               }
               /*| ID
               {
                    // TODO: change to LIST '<' primitive_type '>'
                    //list of struct
                    $$ = createRecord($1, EUNTYPED);
               }*/
               | LIST '<' list_types '>'
               {
                    //list of list
                    char * str_list[] = {$3->code, " *"};
                    int list_size = 2;
                    char * s = cat(str_list, list_size);
                    
                    $$ = createRecord(s, $3->type);
                    $$->structure = ELIST;
                    $$->type_string = strdup($3->code);

                    free(s);
                    freeRecord($3);
               }
;

//TODO
list_initialization : list_declaration '=' NEW LIST '<' '>' '(' ')'
                    {
                         //list_types ID[] = novo Lista<>()
                         //int exemplo[] = {}
                         // char * str_list[] = {$1->code, " = NULL"};
                         // int list_size = 2;
                         // char * s = cat(str_list, list_size);

                         // // free($3);
                         // // free($4);
                         
                         // $$ = createRecord(s, $1->type);

                         // free($1);
                         // free(s);
                    }
                    //| list_declaration '=' NEW LIST '<' '>' '(' ID ')'                            { /* printf("LIST INITIALIZATION FROM ANOTHER LIST (NEW COPY)\n"); */ }
                    | list_declaration '=' NEW LIST '<' '>' '(' ')' '(' expression ')'
                    //| LIST '<' list_types '>' ID '=' NEW LIST '<' '>' '(' ')' '(' expression ')'
                    {
                         //table_set(sym_table, $5, $3->type, ELIST, NULL);
                         // table_entry* entry = table_get_entry_object(sym_table, $5);
                         // entry->size = 0;
                         char * str_list[] = {
                              $1->code, " = malloc(sizeof(", $1->type_string, ") * (", $10->code, "));\n"
                         };
                         int list_size = 6;
                         char * s = cat(str_list, list_size);
                         
                         $$ = createRecord(s, $1->type);
                         $$->structure = $1->structure;

                         free($1);
                         free($10);
                         free(s);
                    }
;

list_assign : ID '=' NEW LIST '<' '>' '(' ')'                                                     { /* printf("LIST ASSIGN\n"); */ }
            | ID '=' NEW LIST '<' '>' '(' ID ')'                                                  { /* printf("LIST ASSIGN FROM ANOTHER LIST (NEW COPY)\n"); */ }
;

list_push: ID access_suffix_list '.' ADD '(' expression ')'
         /*{
          // VERIFICATIONS
          table_entry* entry = table_get_entry_object(sym_table, $1);
          if (entry == NULL) {
               // Variable was not initialized
               printf("Erro! A lista %s não foi declarada!\n", $1);
          }

          if (entry->type != $6->type){
               // Type error!
               printf("Erro! A lista %s é do tipo %s, e não pode ser inicializada com um valor do tipo %s!\n", $1, type_to_string(entry->type), type_to_string($6->type));
          }
          // =============
          // monta algo como:
          // lista = realloc(lista, sizeof(TYPE)*(lista_size+1));
          // lista[lista_size++] = expr;
          char * str_list[] = {
               $1, $2->code, " = realloc(", $1, $2->code, ", sizeof(", type_to_string_in_C(entry->type), ")*(", entry->size, "+1));\n",
               $1, $2->code, "[", $1, $2->code, entry->size, "++] = ", $6->code, ";\n"
          };
          int list_size = 19;
          char * s = cat(str_list, list_size);

          $$ = createRecord(s, entry->type);
          entry->size = entry->size + 1;

          freeRecord($2);
          freeRecord($6);
          free(s);
         }*/
         | ID '.' ADD '(' expression ')'                                                          {}
;

list_remove: ID access_suffix_list '.' REMOVE '(' ')'                                             {}
           | ID '.' REMOVE '(' ')'                                                                {}
;

access_assign : ID access_suffix_list '=' expression
              {
                    char * str_list[] = {$1, $2->code, "=", $4->code};
                    int list_size = 4;
                    char * s = cat(str_list, list_size);

                    $$ = createRecord(s, $4->type);

                    freeRecord($2);
                    freeRecord($4);
                    free(s);
              }
;

/* access : ID access_suffix_list
       {
          char * str_list[] = {$1, $2->code};
          int list_size = 2;
          char * s = cat(str_list, list_size);

          //TODO: GET TYPE FROM SYMBOL TABEL
          $$ = createRecord(s, EUNTYPED);

          free($1);
          freeRecord($2);
          free(s);
       }
; */

access_suffix_list : access_suffix
                   {
                    $$ = createRecord($1->code, $1->type);
                    freeRecord($1);
                   }
                   | access_suffix_list access_suffix
                   {
                    char * str_list[] = {$1->code, $2->code};
                    int list_size = 2;
                    char * s = cat(str_list, list_size);

                    $$ = createRecord(s, $2->type);

                    freeRecord($1);
                    freeRecord($2);
                    free(s);
                   }
;

// TODO: Verficação do tipo
access_suffix : '[' expression ']'
               { 
                    char * str_list[] = {"[", $2->code, "]"};
                    int list_size = 3;
                    char * s = cat(str_list, list_size);
                    
                    $$ = createRecord(s, $2->type);

                    freeRecord($2);
                    free(s);
               }
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
               // printf("\n\nA5: %s\n\n", $1);
               $$ = createRecord($1, EINTEGER);
               free($1);
            }
            | '-' INT_LITERAL             
            {
               // printf("\n\nA6: %s\n\n", $2);
               char * str_list[] = {"-", $2};
               int list_size = 2;
               char * s = cat(str_list, list_size);
               
               free($2);

               $$ = createRecord(s, EINTEGER);
               free(s);
            }
;

float_literal  : FLOAT_LITERAL
               {
                    $$ = createRecord($1, EFLOAT);
                    free($1);
               }
               | '-' FLOAT_LITERAL
               {
                    char * str_list[] = {"-", $2};
                    int list_size = 2;
                    char * s = cat(str_list, list_size);
                    
                    free($2);

                    $$ = createRecord(s, EFLOAT);
                    free(s);
               }
;

 type: primitive_type
     {
          //printf("A10");
          $$ = createRecord($1->code,$1->type);
          free($1);
     }
     | list_types
     {
          $$ = createRecord($1->code, $1->type);
          $$->structure = $1->structure;
          $$->type_string = strdup($1->type_string);

          freeRecord($1);
     }
     //| LIST '<' list_types '>'
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
                    // printf("A3\n");
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

                         $$ = createRecord(s, EUNTYPED);

                         free($2);
                         free($5);
                         free(s);
                    }
;	

var_assign : ID '=' expression
           {
               // VERIFICATIONS
               table_entry* entry = NULL;
               int index = stack.top;
               while(index >= 0){
                    char* strStack = strdup(peek_position(&stack, index));
                    
                    if(strStack != NULL){
                         char * str_list[] = {strStack, "@", $1};
                         int list_size = 3;
                         char * key = cat(str_list, list_size);

                         entry = table_get_entry_object(sym_table, key);

                         if(entry != NULL){
                              break;
                         }
                         free(key);
                    }
                    
                    free(strStack);
                    index--;
               }

               if (entry == NULL) {
                    // Variable was not initialized
                    printf("Erro! A variável %s não foi declarada!\n", $1);
               }

               //TODO: permitir coersão de inteiro para real?
               if (entry->type != $3->type){
                    // Type error!
                    printf("Erro! A variável %s é do tipo %s, e não pode ser inicializada com um valor do tipo %s!\n", $1, type_to_string(entry->type), type_to_string($3->type));
               }
               // =============

               char * str_list[] = {$1, " = ", $3->code};
               int list_size = 3;
               char * s = cat(str_list, list_size);

               $$ = createRecord(s, EUNTYPED);

               free($3);
               free(s);
           }
           | ID composite_assign_operator expression                                               {/*printf("VAR_ASSIGN WITH OPERATOR\n");*/}
;

composite_assign_operator : SUM_ASSIGN                                                             {/*printf("SUM_ASSIGN\n");*/}
                | SUBTRACTION_ASSIGN                                                               {/*printf("SUBTRACTION_ASSIGN\n");*/}
                | TIMES_ASSIGN                                                                     {/*printf("TIMES_ASSIGN\n");*/}
                | DIVISION_ASSIGN                                                                  {/*printf("DIVISION_ASSIGN\n");*/}
;

//TODO: EXPRESSIONS
expression     : expression AND comparison_expression
               {
                    char * str_list[] = {$1->code," && ", $3->code};
                    int list_size = 3;
                    char * s = cat(str_list, list_size);

                    $$ = createRecord(s,EBOOL);
                    
                    free($1);
                    free($3);
                    free(s);
               }
               | expression OR comparison_expression
               {
                    char * str_list[] = {$1->code," || ", $3->code};
                    int list_size = 3;
                    char * s = cat(str_list, list_size);

                    $$ = createRecord(s,EBOOL);
                    
                    free($1);
                    free($3);
                    free(s);
               }
               | comparison_expression
               {
                    $$ = createRecord($1->code, $1->type);
                    freeRecord($1);
               }
;

comparison_expression    : comparison_expression EQUALS relation_expression
                         {
                              char * str_list[] = {$1->code," == ", $3->code};
                              int list_size = 3;
                              char * s = cat(str_list, list_size);

                              $$ = createRecord(s,EBOOL);
                              
                              free($1);
                              free($3);
                              free(s);
                         }
                         | comparison_expression DIFF relation_expression
                         {
                              char * str_list[] = {$1->code," != ", $3->code};
                              int list_size = 3;
                              char * s = cat(str_list, list_size);

                              $$ = createRecord(s,EBOOL);
                              
                              free($1);
                              free($3);
                              free(s);
                         }
                         | relation_expression
                         {
                              $$ = createRecord($1->code, $1->type);
                              freeRecord($1);
                         }
;

relation_expression : relation_expression '>' arithmatic_expression
                    {
                         char * str_list[] = {$1->code," > ", $3->code};
                         int list_size = 3;
                         char * s = cat(str_list, list_size);

                         $$ = createRecord(s,EBOOL);
                         
                         free($1);
                         free($3);
                         free(s);
                    }
                    | relation_expression '<' arithmatic_expression
                    {
                         char * str_list[] = {$1->code," < ", $3->code};
                         int list_size = 3;
                         char * s = cat(str_list, list_size);

                         $$ = createRecord(s,EBOOL);
                         
                         free($1);
                         free($3);
                         free(s);
                    }
                    | relation_expression GTE arithmatic_expression
                    {
                         char * str_list[] = {$1->code," >= ", $3->code};
                         int list_size = 3;
                         char * s = cat(str_list, list_size);

                         $$ = createRecord(s,EBOOL);
                         
                         free($1);
                         free($3);
                         free(s);
                    }
                    | relation_expression LTE arithmatic_expression
                    {
                         char * str_list[] = {$1->code," <= ", $3->code};
                         int list_size = 3;
                         char * s = cat(str_list, list_size);

                         $$ = createRecord(s,EBOOL);
                         
                         free($1);
                         free($3);
                         free(s);
                    }
                    | arithmatic_expression
                    {
                         // printf("A4: %s -> %d\n", $1->code, $1->type);
                         $$ = createRecord($1->code, $1->type);
                         freeRecord($1);
                    }
;

arithmatic_expression    : arithmatic_expression '+' factor
                         {
                              type expression_type = UNDEFINED_TYPE;
                              // VERIFICATIONS
                              if ($1->type != $3->type){
                                   // Type error!
                                   char * str_list[] = {$1->code," + ", $3->code};
                                   int list_size = 3;
                                   char * s = cat(str_list, list_size);

                                   char buffer[256];
                                   sprintf(buffer, "Erro! A expressão %s e é do tipo %s, e não podem ser somada a um valor do tipo %s!\n", $1->code, type_to_string($1->type), type_to_string($3->type));
                                   report_error(buffer);

                                   $$ = createRecord(s,expression_type);

                                   free($1);
                                   free($3);
                                   free(s);
                                   return -1;
                              }
                              // =============
                              // past this point, we know both expressions are of the same type

                              //TODO: FAZER ALTERAÇÃO DO TIPO COM BASE NO VALORES INSERIDOS
                              char * s;
                              if($1->type == EFLOAT){
                                   expression_type = EFLOAT;

                                   char * str_list[] = {$1->code," + ", $3->code};
                                   int list_size = 3;
                                   s = cat(str_list, list_size);
                              }
                              else if($1->type == EINTEGER){
                                   expression_type = EINTEGER;

                                   char * str_list[] = {$1->code," + ", $3->code};
                                   int list_size = 3;
                                   s = cat(str_list, list_size);
                              }
                              // else if($1->type == EBOOL){
                              //      expression_type = EBOOL;
                              // }
                              else if($1->type == ESTRING){
                                   char * str_list[] = {"({ char *tmp = malloc(strlen(", $1->code, ") + strlen(", $3->code, ") + 1); strcpy(tmp, ", $1->code, "); strcat(tmp, ", $3->code, "); tmp; })"};
                                   int list_size = 9;
                                   s = cat(str_list, list_size);

                                   expression_type = ESTRING;
                              }

                              $$ = createRecord(s,expression_type);
                              
                              free($1);
                              free($3);
                              free(s);
                         }
                         | arithmatic_expression '-' factor
                         {
                              char * str_list[] = {$1->code," - ", $3->code};
                              int list_size = 3;
                              char * s = cat(str_list, list_size);

                              type expression_type = EINTEGER;
                              //TODO: FAZER ALTERAÇÃO DO TIPO COM BASE NO VALORES INSERIDOS
                              if($1->type == EFLOAT || $3->type == EFLOAT){
                                   expression_type = EFLOAT;
                              }

                              $$ = createRecord(s,expression_type);
                              
                              free($1);
                              free($3);
                              free(s);
                         }
                         | factor
                         {
                              $$ = createRecord($1->code, $1->type);
                              freeRecord($1);
                         }
;

factor    : factor '*' unary
          {
               // TODO: SOLVE THIS ERROR BELLOW

               char * str_list[] = {$1->code," * ", $3->code};
               int list_size = 3;
               char * s = cat(str_list, list_size);

               type expression_type = EINTEGER;
               //TODO: FAZER ALTERAÇÃO DO TIPO COM BASE NO VALORES INSERIDOS
               if($1->type == EFLOAT || $3->type == EFLOAT){
                    expression_type = EFLOAT;
               }

               $$ = createRecord(s,expression_type);
               
               free($1);
               free($3);
               free(s);
          }
          | factor '/' unary
          {
               char * str_list[] = {$1->code," / ", $3->code};
               int list_size = 3;
               char * s = cat(str_list, list_size);

               type expression_type = EINTEGER;
               //TODO: FAZER ALTERAÇÃO DO TIPO COM BASE NO VALORES INSERIDOS
               if($1->type == EFLOAT || $3->type == EFLOAT){
                    expression_type = EFLOAT;
               }

               $$ = createRecord(s,expression_type);
               
               free($1);
               free($3);
               free(s);
          }
          | factor INT_DIVISION unary
          {
               char * str_list[] = {$1->code," / ", $3->code};
               int list_size = 3;
               char * s = cat(str_list, list_size);

               //TODO: FAZER ALTERAÇÃO DO TIPO COM BASE NO VALORES INSERIDOS
               $$ = createRecord(s,EINTEGER);
               
               free($1);
               free($3);
               free(s);
          }
          | unary
          {
               $$ = createRecord($1->code, $1->type);
               freeRecord($1);
          }
;
 
unary : ID UNARY_SUM
      {
          // VERIFICATIONS
          table_entry* entry = NULL;
          int index = stack.top;
          while(index >= 0){
               char* strStack = strdup(peek_position(&stack, index));
               
               if(strStack != NULL){
                    char * str_list[] = {strStack, "@", $1};
                    int list_size = 3;
                    char * key = cat(str_list, list_size);

                    entry = table_get_entry_object(sym_table, key);

                    if(entry != NULL){
                         break;
                    }
                    free(key);
               }
               
               free(strStack);
               index--;
          }

          type entry_type = UNDEFINED_TYPE;
          if (entry == NULL) {
               // Variable was not initialized
               printf("Erro! A variável %s não foi declarada!\n", $1);
          }
          else{
               entry_type = entry->type;
          }

          // =============

          // TODO: checar o escopo (não pode usar em escopo global)
          char * str_list[] = {$1,"++"};
          int list_size = 2;
          char * s = cat(str_list, list_size);

          free($1);

          $$ = createRecord(s, entry_type);
          free(s);
      }
      | ID UNARY_SUBTRACTION
      {
          // TODO: checar o escopo (não pode usar em escopo global)
          char * str_list[] = {$1,"--"};
          int list_size = 2;
          char * s = cat(str_list, list_size);

          free($1);

          $$ = createRecord(s,EUNTYPED);
          free(s);
      }
      | '(' expression ')'
      {
          // TODO: SOLVE THIS ERROR BELLOW
          // int teste = 2.1 / (4 +1)  *5; is parsing to int teste = 2.1 / (4 + 1) + 5;
          
          // printf("M-A1: %s\n", $2->code);
          char * str_list[] = {"(", $2->code, ")"};
          int list_size = 3;
          char * s = cat(str_list, list_size);
          
          $$ = createRecord(s, $2->type);
          
          free(s); 
          freeRecord($2);
      }
      | ID
      {
          table_entry* entry = NULL;
          int index = stack.top;
          while(index >= 0){
               char* strStack = strdup(peek_position(&stack, index));
               
               if(strStack != NULL){
               char * str_list[] = {strStack, "@", $1};
               int list_size = 3;
               char * key = cat(str_list, list_size);

               entry = table_get_entry_object(sym_table, key);

                    if(entry != NULL){
                         break;
                    }
                    free(key);
               }
               
               free(strStack);
               index--;
          }

          type entry_type = UNDEFINED_TYPE;
          if (entry == NULL) {
               // Variable was not initialized
               printf("Erro! A variável %s não foi declarada!\n", $1);
          }
          else{
               entry_type = entry->type;
          }

          // =============

          $$ = createRecord($1, entry_type);
          free($1);
      }
      | int_literal
      {
          $$ = createRecord($1->code, $1->type);
          freeRecord($1);
      }
      | float_literal
      {
          $$ = createRecord($1->code, $1->type);
          freeRecord($1);
      }
      | BOOL_LITERAL
      {
          $$ = createRecord((strcmp($1,"verdadeiro") == 0 ? "true" : "false"), EBOOL);
          free($1);
      }
      | STRING_LITERAL
      {
          //printf("\n\nA4: %s\n\n", $1);
          $$ = createRecord($1, ESTRING);
          free($1);
      }
      | func_call
      {
          $$ = createRecord($1->code, $1->type);
          freeRecord($1);
      }
      | read
      /* {
         $$ = createRecord($1->code, EUNTYPED); freeRecord($1);
      } */
      | ID access_suffix_list
      {
          // VERIFICATIONS
          table_entry* entry = NULL;
          int index = stack.top;
          while(index >= 0){
               char* strStack = strdup(peek_position(&stack, index));
               
               if(strStack != NULL){
                    char * str_list[] = {strStack, "@", $1};
                    int list_size = 3;
                    char * key = cat(str_list, list_size);

                    entry = table_get_entry_object(sym_table, key);

                    if(entry != NULL){
                         break;
                    }
                    free(key);
               }
               
               free(strStack);
               index--;
          }
          
          if (entry == NULL) {
               // Variable was already initialized
               printf("Erro! A variável %s não foi declarada!\n", $1);
          }
          // =============

          char * str_list[] = {$1, $2->code};
          int list_size = 2;
          char * s = cat(str_list, list_size);

          $$ = createRecord(s, entry->type);
          freeRecord($2);
          free(s);
      }
      | type_conversion
      {
         $$ = createRecord($1->code, $1->type);
         freeRecord($1);
      }
; 

func_call : ID '(' args ')'
          {
               char * str_list[] = {$1, "(", $3->code, ")"};
               int list_size = 4;
               char * s = cat(str_list, list_size);
               
               // TODO: pegar tipo do func_call pela tabela de simbolos de ID
               $$ = createRecord(s, EUNTYPED);

               freeRecord($3);
               free(s);
          }
;

args : args ',' expression
     {
          char * str_list[] = {$1->code, ",", $3->code, ")"};
          int list_size = 3;
          char * s = cat(str_list, list_size);

          $$ = createRecord(s, EUNTYPED);

          freeRecord($1);
          freeRecord($3);
          free(s);
     }
     | expression
     {
          $$ = createRecord($1->code, $1->type);
          freeRecord($1);
     }
     |
     {
          $$ = createRecord("", EUNTYPED);
     }
;

if : IF '(' expression ')' '{' {push(&stack, "if"); push(&labels_stack, "out_if_label");} stmt_list {pop(&stack);} '}' if_complement
     {
          //OK
          // may need to implement a dictionary, but for now the out label will be the scope of the if
          // char* label_out = peek(&stack);
          // char* label_out = new_label("out");

          char* label_out = peek(&labels_stack);
          pop(&labels_stack);
          char* label_else = new_label("else");

          // in case there are else_if
          char * replacement_list[] = {"goto ", label_out};
          char * replacement_string = cat(replacement_list, 2);
          $10->code = replace_all($10->code, "_PLACEHOLDER_OUT_", replacement_string);
          //

          char * str_list[] = {
               "if (!(", $3->code /*expression*/, ")) goto ", label_else, ";\n",
               "{\n\t", $7->code, "}\n", //stmt_list
               "goto ", label_out, ";\n",
               label_else, ":\n",
               $10->code,//if_complement
               label_out, ":\n"
          };

          int list_size = 16;
          char * s = cat(str_list, list_size);
          
          freeRecord($3);
          freeRecord($7);
          freeRecord($10);
          
          $$ = createRecord(s, EUNTYPED);
          free(s);
          free(replacement_string);
     } 
;

if_complement : ELSE '{' {push(&stack, "else");} stmt_list {pop(&stack);} '}'
               {
                    //OK
                    char * str_list[] = {
                         "{\n\t", $4->code, "}\n" //stmt_list
                    };

                    int list_size = 3;
                    char * s = cat(str_list, list_size);

                    $$ = createRecord(s, EUNTYPED);
                    
                    free(s);
                    freeRecord($4);
               } 
              | else_if
              //OK
              {$$ = $1;}
              | else_if ELSE '{' {push(&stack, "else_if");} stmt_list {pop(&stack);} '}'
              {
                    //OK
                    char * str_list[] = {$1->code, "{\n\t", $5->code, "}", "\n"};
                    int list_size = 5;
                    char * s = cat(str_list, list_size);

                    freeRecord($1);
                    freeRecord($5);

                    $$ = createRecord(s, EUNTYPED);
                    free(s);
              }
              |
              {
                    //OK
                    $$ = createRecord("",EUNTYPED);
              }

else_if : else_if ELSE_IF '(' expression ')' '{' {push(&stack, "else_iff");} stmt_list {pop(&stack);} '}'
          {
               char* label_out_else_if2 = new_label("out_else_if");
               char * str_list[] = {
                    $1->code,
                    "if (!(", $4->code/*expression*/, ")) goto ", label_out_else_if2, ";\n",
                    "{\n\t", $8->code, "}\n",//stmt_list
                    "_PLACEHOLDER_OUT_;\n",
                    label_out_else_if2, ":\n"
               };
               int list_size = 12;
               char * s = cat(str_list, list_size);

               $$ = createRecord(s, EUNTYPED);

               freeRecord($1);
               freeRecord($4);
               freeRecord($8);
               free(s);
          }
          | ELSE_IF '(' expression ')' '{' {push(&stack, "else_ifff");} stmt_list {pop(&stack);} '}'
          {
               //OK
               char* label_out_else_if = new_label("out_else_if");
               char * str_list[] = {
                    "if (!(", $3->code/*expression*/, ")) goto ", label_out_else_if, ";\n",
                    "{\n\t", $7->code, "}\n",//stmt_list
                    "_PLACEHOLDER_OUT_;\n",
                    label_out_else_if, ":\n"
               };
               int list_size = 11;
               char * s = cat(str_list, list_size);

               $$ = createRecord(s, EUNTYPED);

               freeRecord($3);
               freeRecord($7);
               free(s);
          } 

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

while : WHILE '(' expression ')' '{' {push(&stack, "while");} stmt_list {pop(&stack);} '}'
{
     // VERIFICATIONS
     //only boolean expressions are allowed in while statements
     if ($3->type != EBOOL){
          // Type error!
          char * error_list[] = {"Erro! A expressão utilizada é do tipo ", type_to_string($3->type), "! Enquanto só aceita expressões do tipo lógico!\n"};
          char * error_string = cat(error_list, 3);
          report_error(error_string);
          free(error_string);
     }
     // =============

     char* label_start = new_label("start_while");
     char* label_end = new_label("end_while");

     char * str_list[] = {
          label_start, ":\n",
          "if (!(", $3->code/*expression*/, ")) goto ", label_end, ";\n",
          "{\n\t", $7->code, "}\n",//stmt_list
          "goto ", label_start, ";\n",
          label_end, ":\n"
          };
     int list_size = 15;
     char * s = cat(str_list, list_size);
     
     freeRecord($3);
     freeRecord($7);
     
     $$ = createRecord(s, EUNTYPED);
     free(s);
}


do_while : DO '{' stmt_list '}' WHILE '(' expression ')'                                            {/*printf("DO WHILE\n");*/}

for_initialization : var_initialization
                   {
                    $$ = createRecord($1->code, $1->type);
                    freeRecord($1);
                   }
                   | var_assign
                   {
                    $$ = createRecord($1->code, $1->type);
                    freeRecord($1);
                   }
                   ;

for_step : var_assign
         {
          $$ = createRecord($1->code, $1->type);
          freeRecord($1);
         }
         | expression
         {
          // VERIFICATIONS
          //only integer expressions are allowed in for step
          if ($1->type != EINTEGER){
               // Type error!
               char * error_list[] = {"Erro! A expressão utilizada é do tipo ", type_to_string($1->type), "! O passo do repita só aceita expressões do tipo inteiro!\n"};
               char * error_string = cat(error_list, 3);
               report_error(error_string);
               free(error_string);
          }
          //TODO: verify if $1->code ends in ++ or --
          // =============

          $$ = createRecord($1->code, $1->type);
          freeRecord($1);
         }
         ;

for : FOR {push(&stack, "for");} '(' for_initialization ',' expression ',' for_step ')' '{' stmt_list {pop(&stack);} '}'
     {
          char* label_start = new_label("for_start");
          char* label_out = new_label("for_out");

          char * str_list[] = {
               "{\n\t", $4->code, ";\n",//for_initialization
               label_start, ":\n",
               "if (!(", $6->code/*expression*/, ")) goto ", label_out, ";\n",
               "{", $11->code, "}\n",//stmt_list
               $8->code, ";\n",//for_step
               "goto ", label_start, ";\n}\n",
               label_out, ":\n"
          };
          int list_size = 20;
          char * s = cat(str_list, list_size);
          
          $$ = createRecord(s, EUNTYPED);

          freeRecord($4);
          freeRecord($6);
          freeRecord($8);
          freeRecord($11);
          free(s);
     }

read : INPUT '(' input_args ')' 
          {
               char * str_list[] = {"scanf(\"%d\", &", $3->code, ")"};
               int list_size = 3;
               char * s = cat(str_list, list_size);
               
               freeRecord($3);
               
               $$ = createRecord(s, EUNTYPED);
               free(s);
          } 
;

type_conversion : primitive_type '(' expression ')'
               {
                    type expression_type = $3->type;
                    if (expression_type == EUNTYPED && $3->code != NULL) {
                         type looked_up_type = table_get_type(sym_table, $3->code);
                         if (looked_up_type != UNDEFINED_TYPE) {
                              expression_type = looked_up_type;
                         }
                    }

                    record *result_record = NULL;

                    if ($1->type == ESTRING) {

                         char *buffer = NULL;

                         if (expression_type == EINTEGER) {
                              buffer = malloc(200);
                              sprintf(buffer, "({ char* tmp = malloc(32); sprintf(tmp, \"%%d\", %s); tmp; })", $3->code);
                         } else if (expression_type == EFLOAT) {
                              buffer = malloc(200);
                              sprintf(buffer, "({ char* tmp = malloc(32); sprintf(tmp, \"%%f\", %s); tmp; })", $3->code);
                         } else if (expression_type == EBOOL) {
                              buffer = malloc(200);
                              sprintf(buffer, "({ char* tmp = malloc(8); sprintf(tmp, \"%%s\", (%s) ? \"true\" : \"false\"); tmp; })", $3->code);
                         } else {
                              result_record = createRecord($3->code, $1->type);
                         }

                         if (buffer != NULL) {
                              result_record = createRecord(buffer, $1->type);
                              free(buffer);
                         }
                    } else {
                         char * str_list[] = {"(", $1->code, ") ", $3->code};
                         int list_size = 4;
                         char * s = cat(str_list, list_size);

                         result_record = createRecord(s, $1->type);
                         free(s);
                    }

                    if (result_record == NULL) {
                         result_record = createRecord($3->code, $1->type);
                    }

                    $$ = result_record;

                    freeRecord($1);
                    freeRecord($3);
               }
;

write : OUTPUT '(' expression ')'                                                                   
          {
               char * str_list[] = {"printf(\"%s\", ", $3->code, ")"};
               int list_size = 3;
               char * s = cat(str_list, list_size);
               
               $$ = createRecord(s, EUNTYPED);

               freeRecord($3);
               free(s);
          }
;

input_args : ID
{
     $$ = createRecord($1, EUNTYPED);
     
}
| STRING_LITERAL
{
     $$ = createRecord($1, EUNTYPED);
     free($1);
}
;

/* type_declaration : STRUCT ID '{' var_declaration_list '}' */

%%

int main (void) {
	int result = yyparse ( );
     return result;
}

int yyerror (char *msg) {
	fprintf (stderr, "%d: %s at '%s'\n", yylineno, msg, yytext);
	return 0;
}