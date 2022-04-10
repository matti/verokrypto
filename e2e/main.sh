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

_verokrypto --version

if [ -d ../vero ]; then
  for path in ../vero/*/*; do
    name=$(basename $path)
    kind=${name%%-*}
    _verokrypto process "$kind" "$path"
    cat "$path" | _verokrypto process "$kind" -
  done
fi

echo ""
echo "OK"