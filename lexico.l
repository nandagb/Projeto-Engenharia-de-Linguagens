%{
  #include <stdio.h>  
  #include "sintatico.tab.h"
  
  extern int yyerror (char *msg);  
%}
%option yylineno

%%

[ \r?\n\t]             ;

"func"                 {return(FUNCTION);}
"retorne"              {printf("RETURN\n");}
"novo"                 {return(NEW);}
"liberar"              {printf("FREE\n");}
"adicionar"            {printf("ADD\n");}
"remover"              {printf("REMOVE\n");}
"se"                   {printf("IF\n");}
"senao se"             {printf("ELSE_IF\n");}
"senao"                {printf("ELSE\n");}
"escolha"              {printf("SWITCH\n");}
"padrao"               {printf("DEFAULT\n");}
"pare"                 {printf("BREAK\n");}
"repita"               {printf("FOR\n");}
"continue"             {printf("CONTINUE\n");}
"execute"              {printf("DO\n");}
"entrada"              {printf("IN\n");}
"saida"                {printf("OUT\n");}
"enquanto"             {printf("WHILE\n");}
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
"++"                   { return(UNARY_SUM); }
"--"                   { return(UNARY_SUBTRACTION); }
"+="                   { return(SUM_ASSIGN); }
"-="                   { return(SUBTRACTION_ASSIGN); }
"*="                   { return(TIMES_ASSIGN); }
"/="                   { return(DIVISION_ASSIGN); }

"."                    { printf(".\n"); }
"("                    { return(yytext[0]); }
")"                    { return(yytext[0]); }
"{"                    { return(yytext[0]); }
"}"                    { return(yytext[0]); }
"["                    { printf("[\n"); }
"]"                    { printf("]\n"); }
";"                    { return(yytext[0]); }
","                    { return(yytext[0]); }
"="                    { return(yytext[0]); }
"!"                    { printf("!\n"); }
"+"                    { printf("+\n"); }
"-"                    { printf("-\n"); }
"/"                    { printf("/\n"); }
"*"                    { printf("*\n"); }
">"                    { return(yytext[0]); }
"<"                    { return(yytext[0]); }
":"                    { printf(":\n"); }
“%”                    { return'%'; }

"verdadeiro"             { yylval.sValue = strdup(yytext); return(BOOL_LITERAL);}
"falso"                  { yylval.sValue = strdup(yytext); return(BOOL_LITERAL);}
[a-zA-Z][a-zA-Z0-9\_]*   { yylval.sValue = strdup(yytext); return(ID); }
[0-9]+			             { return(INT_LITERAL); }
[0-9]+\.[0-9]+		       { return(FLOAT_LITERAL);}
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