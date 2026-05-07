#!/usr/bin/env bash
# Testa as flags -L (logical) e -P (physical) do pwd com symlinks
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

echo "--- test_flags.sh ---"

# Cria um diretório real e um symlink apontando para ele
REAL_DIR=$(mktemp -d)
LINK_DIR="/tmp/t1_pwdtest_link_$$"
ln -s "$REAL_DIR" "$LINK_DIR"

# 1. pwd -P resolve o caminho físico (sem symlink)
RESULT=$(cd "$LINK_DIR" && $PWD_BIN -P)
check "pwd -P resolve symlink para caminho real" "$REAL_DIR" "$RESULT"

# 2. pwd -L preserva o caminho lógico (com symlink)
RESULT=$(cd "$LINK_DIR" && $PWD_BIN -L)
check "pwd -L preserva caminho com symlink" "$LINK_DIR" "$RESULT"

# 3. pwd -L funciona quando PWD é explicitamente definido como o caminho lógico
# (pwd -L usa a variável de ambiente $PWD; o shell nem sempre a define como o link)
RESULT=$(cd "$LINK_DIR" && PWD="$LINK_DIR" $PWD_BIN -L)
check "pwd -L com \$PWD=link retorna caminho lógico" "$LINK_DIR" "$RESULT"

# 4. pwd -P e -L divergem quando há symlink
P_RESULT=$(cd "$LINK_DIR" && $PWD_BIN -P)
L_RESULT=$(cd "$LINK_DIR" && $PWD_BIN -L)
if [ "$P_RESULT" != "$L_RESULT" ]; then
    check "-P e -L divergem em symlink" "ok" "ok"
else
    check "-P e -L divergem em symlink" "ok" "iguais (inesperado)"
fi

# Limpeza
rm "$LINK_DIR"
rmdir "$REAL_DIR"

echo ""
echo "Resultado: ${PASS} passou(aram), ${FAIL} falhou(aram)"
[ "$FAIL" -eq 0 ]
