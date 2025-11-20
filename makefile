all: compilador

compilador: lex.yy.c sintatico.tab.c 
	gcc lex.yy.c sintatico.tab.c ./lib/*.c -o parser

lex.yy.c: lexico.l
	flex lexico.l

sintatico.tab.c: sintatico.y  
	bison -d -v sintatico.y

clean:
	rm -rf lex.yy.c sintatico.tab.* parser output.txt sintatico.output