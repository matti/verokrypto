#!/usr/bin/env bash
set -euo pipefail

BASE_DATA="../verokrypto-data"
KOINLY_DATA_PATH="${BASE_DATA}/koinly"

_debug() {
  >&2 echo -e "+ $*"
}

_out() {
  >&2 echo -e "👾 $*"
}

_tee() {
  local filename="$1"

  tee "${filename}" >/dev/null # &2 for debug
}

_verokrypto() {
  local args; args=("$@")

  exe/verokrypto "${args[@]}"
}

_verodata_status() {
  git -C "${BASE_DATA}" status
}

_process() {
  local wallet_name="$1"
  local source_file_paths=("${@:2}")
  local tempdir; tempdir="$(mktemp -d)"

  local csv_temp_file="${tempdir}/${wallet_name}.csv"
  local koinly_csv_file="${KOINLY_DATA_PATH}/${wallet_name}.csv"

  _out "${koinly_csv_file}"

  _verokrypto process "${wallet_name}" "${source_file_paths[@]}" | _tee "${csv_temp_file}"

  mv -v "${csv_temp_file}" "${koinly_csv_file}"
}


_southxchange() {
  local wallet_name="southxchange"
  local tempdir; tempdir="$(mktemp -d)"

  local btc_temp_path="${tempdir}/${wallet_name}-btc.csv"
  local rtm_temp_path="${tempdir}/${wallet_name}-rtm.csv"
  local merged_temp_path="${tempdir}/${wallet_name}.csv"
  local btc_path="${BASE_DATA}/southxchange/sxc-btc-transactions.csv"
  local rtm_path="${BASE_DATA}/southxchange/sxc-rtm-transactions.csv"

  _out "${wallet_name}"

  # btc -> rtm transactions
  _verokrypto process "${wallet_name}" "${btc_path}" "${rtm_path}" | _tee "${btc_temp_path}"

  # rtm -> btc transactions
  _verokrypto process "${wallet_name}" "${rtm_path}" "${btc_path}" | _tee "${rtm_temp_path}"

  # merged tranasctions by timestamp
  _verokrypto csv "${btc_temp_path}" "${rtm_temp_path}" | _tee "${merged_temp_path}"

  mv -v "${tempdir}"/*.csv "${KOINLY_DATA_PATH}"
}

_raptoreum_main() {
  _process raptoreum \
    "${BASE_DATA}"/raptoreum/rtm-wallet-main.csv \
    "${BASE_DATA}"/raptoreum/labels-received.yaml \
    "${BASE_DATA}"/raptoreum/labels-sent.yaml \
    "${BASE_DATA}"/raptoreum/prices-missing.csv \
  ;
}

_tradeogre() {
  local wallet_name="tradeogre"
  local tempdir; tempdir="$(mktemp -d)"

  local deposits_temp_path="${tempdir}/${wallet_name}-deposits.csv"
  local trades_temp_path="${tempdir}/${wallet_name}-trades.csv"
  local withdrawals_temp_path="${tempdir}/${wallet_name}-withdrawals.csv"
  local merged_temp_path="${tempdir}/${wallet_name}.csv"

  local deposits_path="${BASE_DATA}/tradeogre/export_deposits.csv"
  local trades_path="${BASE_DATA}/tradeogre/export_trades.csv"
  local withdrawals_path="${BASE_DATA}/tradeogre/export_withdrawals.csv"

  _out "${wallet_name}"

  _verokrypto process "tradeogre:deposits" "${deposits_path}" | _tee "${deposits_temp_path}"
  _verokrypto process "tradeogre:trades" "${trades_path}" | _tee "${trades_temp_path}"
  _verokrypto process "tradeogre:withdrawals" "${withdrawals_path}" | _tee "${withdrawals_temp_path}"

  # merge
  _verokrypto csv "${deposits_temp_path}" "${trades_temp_path}" "${withdrawals_temp_path}" | tee "${merged_temp_path}"

  mv -v "${tempdir}"/*.csv "${KOINLY_DATA_PATH}"
}

_raptoreum_main

_process coinbase \
  ${BASE_DATA}/coinbase/"Coinbase-559bd29d66363615790000aa-TransactionsHistoryReport-2023-01-06-10-16-15.csv" \
;

_tradeogre

_southxchange

_verodata_status

_out "Next: Commit changes to git in ${BASE_DATA}"