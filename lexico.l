%{
  #include <stdio.h>  
  #include "sintatico.tab.h"
  
  extern int yyerror (char *msg);  
  int yylineno = 1;
%}

%%

[ \r?\n\t]             ;

"func"                 {printf("FUNCTION\n");}
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

"&&"                   { printf("AND\n");}
"||"                   { printf("OR\n");}
"=="                   { printf("EQUALS\n"); }
"!="                   { printf("DIFF\n"); }
">="                   { printf("GTE\n"); }
"<="                   { printf("LTE\n"); }
"//"                   { printf("INT_DIVISION\n"); }
"++"                   { printf("UNARY_SUM\n"); }
"--"                   { printf("UNARY_SUBTRACTION\n"); }

"."                    { printf(".\n"); }
"("                    { return(yytext[0]); }
")"                    { return(yytext[0]); }
"{"                    { printf("{\n"); }
"}"                    { printf("}\n"); }
"["                    { printf("[\n"); }
"]"                    { printf("]\n"); }
";"                    { return(yytext[0]); }
","                    { printf(",\n"); }
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

[a-zA-Z][a-zA-Z0-9\_]*   {return(ID); }
[0-9]+			             {printf("INT_LITERAL(%s)\n", yytext); }
[0-9]+\.[0-9]+		       {printf("FLOAT_LITERAL(%s)\n", yytext);}
\"[^\"]*\"               { printf("STRING_LITERAL(%s)\n", yytext); }



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