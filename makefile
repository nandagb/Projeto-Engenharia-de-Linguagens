all: compilador

# Dependências apontam para os arquivos na pasta output
compilador: ./output/lex.yy.c ./output/sintatico.tab.c 
	gcc ./output/lex.yy.c ./output/sintatico.tab.c ./lib/*.c -o ./output/parser

# Alvo atualizado para incluir o caminho
./output/lex.yy.c: lexico.l
	flex -o ./output/lex.yy.c lexico.l

# Alvo atualizado para incluir o caminho
./output/sintatico.tab.c: sintatico.y  
	bison -d -v --debug -b ./output/sintatico sintatico.y

clean:
	rm -rf ./output/*
	# Dica: use rm -rf ./output/* para limpar tudo dentro da pasta

parse: all
	./output/parser < ./input/test.txt

q1: all
	./output/parser < ./input/problemas/Q1.txt

q2: all
	./output/parser < ./input/problemas/Q2.txt

q3: all
	./output/parser < ./input/problemas/Q3.txt

q4: all
	./output/parser < ./input/problemas/Q4.txt