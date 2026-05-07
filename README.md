# T1 — Análise do utilitário pwd.c - Henrique Knack

Trabalho de análise do código-fonte do utilitário `pwd` do GNU Coreutils,
produzindo um relatório em LaTeX sobre histórico, idiomas, blocos de código
e análise de memória.

## Dependências

| Ferramenta | Uso |
|------------|-----|
| `make` | orquestrar targets |
| `bash` | executar scripts de teste |
| `gdb` | mapeamento de memória |
| `strace` | rastrear chamadas de sistema |
| `valgrind` | análise de heap (opcional) |
| `pdflatex` + `texlive-lang-portuguese` + `texlive-latex-extra` | compilar o relatório |

Instalação das dependências no Ubuntu/Debian:

```bash
sudo apt install make gdb strace valgrind \
     texlive-latex-extra texlive-lang-portuguese
```

## Estrutura

```
.
├── src/
│   ├── pwd.c           # fonte principal (GNU Coreutils)
│   ├── xgetcwd.c       # envoltório de getcwd (gnulib)
│   ├── root-dev-ino.c  # comparação de inodes
│   └── getcwd.c        # implementação robusta (glibc)
├── include/
│   ├── xgetcwd.h
│   └── root-dev-ino.h
├── tests/
│   ├── test_basic.sh   # 5 testes funcionais
│   ├── test_flags.sh   # 4 testes de flags -L / -P
│   └── test_valgrind.sh
├── Makefile
└── relatorio.tex
```

## Comandos disponíveis

```bash
make              # exibe esta ajuda
make test         # roda os 9 testes funcionais
make test-valgrind# análise de heap com valgrind
make test-gdb     # mapeamento de memória via gdb
make count        # conta linhas de cada arquivo-fonte
```

## Compilar o relatório PDF

```bash
pdflatex relatorio.tex   # primeira passagem
pdflatex relatorio.tex   # segunda passagem (resolve referências cruzadas)
```

O arquivo `relatorio.pdf` será gerado no diretório raiz do projeto.

## Rodar os testes manualmente

```bash
bash tests/test_basic.sh
bash tests/test_flags.sh
```

Saída esperada (9 testes, 0 falhas):

```
--- test_basic.sh ---
PASS: saída padrão == $PWD
PASS: código de saída 0
PASS: sem barra final
PASS: saída termina com newline
PASS: funciona em tmpdir
Resultado: 5 passou(aram), 0 falhou(aram)

--- test_flags.sh ---
PASS: pwd -P resolve symlink para caminho real
PASS: pwd -L preserva caminho com symlink
PASS: pwd -L com $PWD=link retorna caminho lógico
PASS: -P e -L divergem em symlink
Resultado: 4 passou(aram), 0 falhou(aram)
```
