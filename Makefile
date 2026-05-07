BINARY := /usr/bin/pwd
SRC_FILES := $(wildcard src/*.c) $(wildcard include/*.h)

.PHONY: all count test test-valgrind test-gdb output help

all: help

count:
	@echo "=== Contagem de linhas por arquivo ==="
	@wc -l $(SRC_FILES)

test:
	@echo "=== Testes funcionais ==="
	@bash tests/test_basic.sh
	@bash tests/test_flags.sh

test-valgrind:
	@echo "=== Análise de memória (valgrind) ==="
	@bash tests/test_valgrind.sh

test-gdb:
	@echo "=== Stack trace (gdb) ==="
	gdb -batch \
		-ex "set args" \
		-ex "starti" \
		-ex "info proc mappings" \
		-ex continue \
		-ex quit \
		$(BINARY)

output:
	@bash tests/gerar_output.sh
	@echo "=== Output salvo em resultados.txt ==="

help:
	@echo "Targets disponíveis:"
	@echo "  count          - conta linhas de todos os arquivos-fonte"
	@echo "  test           - roda testes funcionais (test_basic + test_flags)"
	@echo "  test-valgrind  - análise de heap/memória com valgrind"
	@echo "  test-gdb       - exibe mapeamento de memória via gdb"
	@echo "  output         - gera resultados.txt com execução, testes e memória"
