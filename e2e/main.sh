#!/usr/bin/env bash
set -euo pipefail

_verokrypto() {
  output=$1
  args=${*:2}
  if >"$output" exe/verokrypto $args; then
    echo "ok: exe/verokrypto $args"
  else
    echo "FAIL: exe/verokrypto $args"
    cat "$output"
    exit 1
  fi
}

_verokrypto /dev/null --version

if [ -d ../vero ]; then
  csvs=$(mktemp -d)
  for source_path in ../vero/*/*; do
    source=${source_path##*/}
    mkdir -p "$csvs/$source"

    for csv_path in $source_path/*; do
      csv_basename=${csv_path##*/}
      kind=${csv_basename%%-*}
      name=${csv_basename%%.*}
      case $name in
        southxchange-*)
          _verokrypto "$csvs/$source/$name.csv" process "$kind" "$csv_path" $source_path/*
        ;;
        *)
          _verokrypto "$csvs/$source/$name.csv" process "$kind" "$csv_path"
        ;;
      esac
    done

    _verokrypto "$csvs/$source/merged.csv" csv $csvs/$source/*
    cp "$csvs/$source/merged.csv" "$source.csv"

    echo "$csvs/$source"
  done
fi

echo ""
echo "OK"