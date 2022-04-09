#!/usr/bin/env bash
set -euo pipefail

_verokrypto() {
  output=$(mktemp)
  if >"$output" 2>&1 exe/verokrypto $@; then
    echo "ok: exe/verokrypto $@"
  else
    echo "FAIL: exe/verokrypto $@"
    cat "$output"
    exit 1
  fi
}

if [ -d ../vero ]; then
  _verokrypto process coinex ../vero/a/coinex-execution-history.xlsx
fi

echo ""
echo "OK"