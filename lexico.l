%{
  #include <stdio.h>  
%}

%%

[ \t\n]               ;
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