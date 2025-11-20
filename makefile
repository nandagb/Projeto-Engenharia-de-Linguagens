all: compilador

compilador: lex.yy.c sintatico.tab.c 
	gcc ./output/lex.yy.c ./output/sintatico.tab.c ./lib/*.c -o ./output/parser

lex.yy.c: lexico.l
	flex -o ./output/lex.yy.c lexico.l

sintatico.tab.c: sintatico.y  
	bison -d -v --debug -b ./output/sintatico sintatico.y

clean:
	rm -rf ./output/lex.yy.c ./output/sintatico.tab.* ./output/parser output.txt ./output/sintatico.output ./output/output.c

parse: all
	./output/parser < ./input/teste.txt