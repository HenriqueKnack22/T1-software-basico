#!/usr/bin/env bash
# Testa comportamento básico do pwd (usa /usr/bin/pwd para garantir o binário do coreutils)
set -euo pipefail

PASS=0
FAIL=0
PWD_BIN=/usr/bin/pwd

check() {
    local desc="$1" expected="$2" actual="$3"
    if [ "$actual" = "$expected" ]; then
        printf "PASS: %s\n" "$desc"
        PASS=$((PASS + 1))
    else
        printf "FAIL: %s\n  esperado: '%s'\n  obtido:   '%s'\n" "$desc" "$expected" "$actual"
        FAIL=$((FAIL + 1))
    fi
}

echo "--- test_basic.sh ---"

# 1. Saída padrão deve ser igual a $PWD
check "saída padrão == \$PWD" "$PWD" "$($PWD_BIN)"

# 2. Código de saída 0 em diretório válido
$PWD_BIN > /dev/null
check "código de saída 0" "0" "$?"

# 3. Saída não deve conter barra final (exceto raiz)
RESULT=$($PWD_BIN)
if [ "$RESULT" != "/" ]; then
    [[ "$RESULT" != */ ]] && check "sem barra final" "ok" "ok" || check "sem barra final" "ok" "falhou"
fi

# 4. Saída termina com newline (via printf e wc)
LINES=$($PWD_BIN | wc -l)
check "saída termina com newline" "1" "$LINES"

# 5. Funciona em subdiretório temporário
TMPDIR_CREATED=$(mktemp -d)
RESULT=$(cd "$TMPDIR_CREATED" && $PWD_BIN)
check "funciona em tmpdir" "$TMPDIR_CREATED" "$RESULT"
rmdir "$TMPDIR_CREATED"

echo ""
echo "Resultado: ${PASS} passou(aram), ${FAIL} falhou(aram)"
[ "$FAIL" -eq 0 ]
