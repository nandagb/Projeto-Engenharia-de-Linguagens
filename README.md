# Projeto-Engenharia-de-Linguagens
Repositório para o projeto de Engenharia de Linguagens, um compilador

Para rodar no powershell
flex lexico.l 
gcc lex.yy.c -o lexer 
Get-Content codigo_fonte.txt | ./lexer.exe
