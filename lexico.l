%{
  #include <stdio.h>  
  #include "sintatico.tab.h"
  
  extern int yyerror (char *msg);  
%}
%option yylineno

%%

[ \r?\n\t]             ;

"func"                 {return(FUNCTION);}
"retorne"              {return(RETURN);}
"novo"                 {return(NEW);}
"liberar"              {printf("FREE\n");}
"adicionar"            {return(ADD);}
"remover"              {return(REMOVE);}
"se"                   {return(IF);}
"senao se"             {return(ELSE_IF);}
"senao"                {return(ELSE);}
"escolha"              {return(SWITCH);}
"caso"                 {return(CASE);}
"padrao"               {return(DEFAULT);}
"pare"                 {return(BREAK);}
"repita"               {return(FOR);}
"continue"             {return(CONTINUE);}
"execute"              {return(DO);}
"entrada"              {return(INPUT);}
"saida"                {return(OUTPUT);}
"enquanto"             {return(WHILE);}
"const"                {printf("CONST\n");}

"Lista"                {return(LIST);}
"Registro"             {return(STRUCT);}
"int"                  {return(INTEGER);}
"real"                 {return(FLOAT);}
"texto"                {return(STRING);}
"vazio"                {return(VOID);}
"logico"               {return(BOOLEAN);}

"&&"                   { return(AND);}
"||"                   { return(OR);}
"=="                   { return(EQUALS); }
"!="                   { return(DIFF); }
">="                   { return(GTE); }
"<="                   { return(LTE); }
"//"                   { return(INT_DIVISION); }
"%%"                   { return(DIV_LEFTOVER); }
"++"                   { return(UNARY_SUM); }
"--"                   { return(UNARY_SUBTRACTION); }
"+="                   { return(SUM_ASSIGN); }
"-="                   { return(SUBTRACTION_ASSIGN); }
"*="                   { return(TIMES_ASSIGN); }
"/="                   { return(DIVISION_ASSIGN); }

"."                    { return(yytext[0]); }
"("                    { return(yytext[0]); }
")"                    { return(yytext[0]); }
"{"                    { return(yytext[0]); }
"}"                    { return(yytext[0]); }
"["                    { return(yytext[0]); }
"]"                    { return(yytext[0]); }
";"                    { return(yytext[0]); }
","                    { return(yytext[0]); }
"="                    { return(yytext[0]); }
"!"                    { printf("!\n"); }
"+"                    { return(yytext[0]); }
"-"                    { return(yytext[0]); }
"/"                    { return(yytext[0]); }
"*"                    { return(yytext[0]); }
">"                    { return(yytext[0]); }
"<"                    { return(yytext[0]); }
":"                    { return(yytext[0]); }
"%"                    { return(yytext[0]); }

"verdadeiro"             { yylval.sValue = strdup(yytext); return(BOOL_LITERAL);}
"falso"                  { yylval.sValue = strdup(yytext); return(BOOL_LITERAL);}
[a-zA-Z][a-zA-Z0-9\_]*   { yylval.sValue = strdup(yytext); return(ID); }
[0-9]+			             { yylval.sValue = strdup(yytext); return(INT_LITERAL); }
[0-9]+\.[0-9]+		       { yylval.sValue = strdup(yytext); return(FLOAT_LITERAL);}
\"[^\"]*\"               { yylval.sValue = strdup(yytext); return(STRING_LITERAL);}



"#".*                 ; {/* ignora comentário de linha */}
.                     {printf("Invalid character.\n");}

%%

#ifndef yywrap
   // Indicates no more input 
   int yywrap (void) {return 1;}
#endif

/* removendo a main pois será chamada pelo parser
int main(void)
{
  yylex();  
  return 0;
}
*/