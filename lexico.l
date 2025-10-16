%{
  #include <stdio.h>  
  
  extern int yyerror (char *msg);  
%}

%%

[ \r?\n\t]             ;

"func"                 {printf("FUNCTION\n");}
"retorne"              {printf("RETURN\n");}
"novo"                 {printf("NEW\n");}
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

"Lista"                {printf("LIST\n");}
"Registro"             {printf("STRUCT\n");}
"int"                  {printf("INTEGER\n");}
"real"                 {printf("FLOAT\n");}
"texto"                {printf("STRING\n");}
"vazio"                {printf("VOID\n");}
"logico"               {printf("BOOLEAN\n");}

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
"("                    { printf("(\n"); }
")"                    { printf(")\n"); }
"{"                    { printf("{\n"); }
"}"                    { printf("}\n"); }
"["                    { printf("[\n"); }
"]"                    { printf("]\n"); }
";"                    { printf(";\n"); }
","                    { printf(",\n"); }
"="                    { printf("=\n"); }
"!"                    { printf("!\n"); }
"+"                    { printf("+\n"); }
"-"                    { printf("-\n"); }
"/"                    { printf("/\n"); }
"*"                    { printf("*\n"); }
">"                    { printf(">\n"); }
"<"                    { printf("<\n"); }
":"                    { printf(":\n"); }
“%”                    { return'%'; }

[a-zA-Z][a-zA-Z0-9\_]*   {printf("ID(%s)\n", yytext); }
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

int main(void)
{
  yylex();  
  return 0;
}