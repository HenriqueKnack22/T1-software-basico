#!/usr/bin/env bash
# Análise de consumo de memória do pwd usando valgrind
set -euo pipefail

PWD_BIN=/usr/bin/pwd
MASSIF_OUT=/tmp/pwd_massif_$$.out

if ! command -v valgrind &>/dev/null; then
    echo "valgrind não encontrado. Instale com: sudo apt install valgrind"
    exit 1
fi

echo "=== memcheck: vazamentos de memória ==="
valgrind \
    --tool=memcheck \
    --leak-check=full \
    --show-leak-kinds=all \
    --track-origins=yes \
    --verbose \
    "$PWD_BIN" 2>&1

echo ""
echo "=== massif: consumo de heap ao longo do tempo ==="
valgrind \
    --tool=massif \
    --massif-out-file="$MASSIF_OUT" \
    "$PWD_BIN" > /dev/null 2>&1

if command -v ms_print &>/dev/null; then
    ms_print "$MASSIF_OUT" | head -40
else
    echo "ms_print não disponível. Arquivo de saída: $MASSIF_OUT"
fi

rm -f "$MASSIF_OUT"
