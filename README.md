# Projeto — Engenharia de Linguagens

Um compilador simples (analisador léxico) implementado com Flex, criado como trabalho da disciplina Engenharia de Linguagens.

O repositório contém um analisador léxico (`flex`) e um exemplo de código-fonte que implementa dois algoritmos de ordenação:

- MergeSort
- QuickSort

Esses exemplos servem para testar e demonstrar a linguagem/gramática definida no analisador léxico.

## Estrutura do repositório

- `lexico.l` — arquivo fonte do Flex (especificação léxica)
- `codigo_fonte.txt` — código de exemplo que o lexer analisa

## Pré-requisitos

- Flex (lex)
- GCC (para compilar o gerado `lex.yy.c`)

Observação: em Windows recomenda-se usar o WSL ou ter ferramentas compatíveis instaladas.

## Como executar

Windows (PowerShell)

```powershell
flex lexico.l
gcc lex.yy.c -o lexer.exe
Get-Content codigo_fonte.txt | .\lexer.exe
```

WSL / Linux

```bash
flex lexico.l
gcc lex.yy.c -o lexer
./lexer < codigo_fonte.txt
```

Dica: se o `gcc` gerar `lex.yy.c` com dependências, verifique mensagens do Flex e instale os pacotes necessários.

## Saída esperada

O analisador imprimirá tokens reconhecidos a partir de `codigo_fonte.txt`. O formato exato da saída depende das ações definidas em `lexico.l`.