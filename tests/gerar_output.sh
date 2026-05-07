#!/usr/bin/env bash
set -euo pipefail

PWD_BIN=/usr/bin/pwd
OUT=resultados.txt

sep() { printf '%0.s=' {1..60}; echo; }
section() { echo; sep; echo "  $1"; sep; }

exec > "$OUT" 2>&1

echo "Análise do utilitário pwd — resultados de execução"
echo "Gerado em: $(date '+%Y-%m-%d %H:%M:%S')"

# ------------------------------------------------------------------
section "1. EXECUÇÃO DO PROGRAMA"

echo ""
echo "--- Diretório atual ---"
echo "$ pwd"
$PWD_BIN

echo ""
echo "--- Flag -P (caminho físico, resolve symlinks) ---"
LINK=$(mktemp -d)/link_demo
ln -sf /tmp "$LINK"
echo "$ ln -sf /tmp $LINK"
echo "$ cd $LINK && pwd -P"
(cd "$LINK" && $PWD_BIN -P)
echo "$ cd $LINK && pwd -L"
(cd "$LINK" && $PWD_BIN -L)
rm -f "$LINK"
rmdir "$(dirname "$LINK")"

echo ""
echo "--- Diretório temporário ---"
TMPD=$(mktemp -d)
echo "$ cd $TMPD && pwd"
(cd "$TMPD" && $PWD_BIN)
rmdir "$TMPD"

echo ""
echo "--- Ajuda (--help, primeiras 5 linhas) ---"
echo "$ pwd --help"
$PWD_BIN --help 2>&1 | head -5

# ------------------------------------------------------------------
section "2. TESTES AUTOMATIZADOS"

echo ""
bash tests/test_basic.sh
echo ""
bash tests/test_flags.sh

# ------------------------------------------------------------------
section "3. ANÁLISE DE MEMÓRIA"

echo ""
echo "--- strace: chamadas brk (heap) ---"
echo "$ strace -e trace=brk pwd"
strace -e trace=brk $PWD_BIN 2>&1

echo ""
echo "--- gdb: mapeamento de memória (info proc mappings) ---"
echo "$ gdb -batch -ex 'break *0x2e50' -ex run -ex 'info proc mappings' /usr/bin/pwd"
gdb -batch \
    -ex "set debuginfod enabled off" \
    -ex "break *0x2e50" \
    -ex "run" \
    -ex "info proc mappings" \
    -ex "quit" \
    $PWD_BIN 2>&1 \
  | grep -v "^This GDB\|^  <https\|^Enable\|^Debuginfod\|^To make\|^warning\|^A debugging\|^Inferior\|^Quit\|^\s*$" \
  || true

echo ""
echo "--- size: seções do binário ---"
echo "$ size $PWD_BIN"
size $PWD_BIN

sep
echo "Arquivo gerado: $OUT"
