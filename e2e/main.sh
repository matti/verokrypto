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

_verokrypto /dev/null --version

if [ -d ../vero ]; then
  csvs=$(mktemp -d)
  for source_path in ../vero/*/*; do
    source=${source_path##*/}

    for csv_path in $source_path/*; do
      csv_basename=${csv_path##*/}
      kind=${csv_basename%%-*}

      echo ve process $kind $csv_path
      mkdir -p "$csvs/$source"
      _verokrypto "$csvs/$source/$csv_basename" process "$kind" "$csv_path"
    done
  done

  #   source=${name%%-*}
  #   kind=${source%%:*}
  #   echo $name $source $kind
  #   _verokrypto "$csvs/$name" process "$source" "$path"
  # done
  # ls $csvs/*

  # _verokrypto "$csvs/merged.csv" csv $csvs/*

  # cp "$csvs/merged.csv" .
fi

echo ""
echo "OK"