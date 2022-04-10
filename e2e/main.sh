#!/usr/bin/env bash
set -euo pipefail

_verokrypto() {
  output=$1
  args=${@:2}
  if >"$output" exe/verokrypto $args; then
    echo "ok: exe/verokrypto $args"
  else
    echo "FAIL: exe/verokrypto $args"
    cat "$output"
    exit 1
  fi
}

_verokrypto --version

if [ -d ../vero ]; then
  csvs=$(mktemp -d)
  for path in ../vero/*/*; do
    name=$(basename $path)
    kind=${name%%-*}
    _verokrypto "$csvs/$name" process "$kind" "$path"
  done
  ls $csvs/*

  _verokrypto "$csvs/merged.csv" csv $csvs/*

  cp "$csvs/merged.csv" .
fi

echo ""
echo "OK"