#!/bin/bash
# vim: expandtab softtabstop=2 tabstop=2 shiftwidth=2 smartindent autoindent

################################################################################
# checkov pre-commit hook
################################################################################
# Author: Radomir Ochtyra <radomir.ochtyra@lurse.de>
# Create: 06.09.2022
# Update: 24.09.2022
################################################################################

function realrelpath {
    local L_PATH=""
    local L_DIR=""

    if [ $# -ne 0 ]; then
        L_PATH="$1"
    else
        L_PATH="${BASH_SOURCE[0]}"
    fi

    while [ -h "$L_PATH" ]; do
        L_DIR="$(cd -P "$(dirname "$L_PATH")" > /dev/null 2>&1 && pwd)"
        L_PATH="$(readlink "$L_PATH")"
        [[ "$L_PATH" != /* ]] && L_PATH="${L_DIR}/${L_PATH}"
    done

    echo "$L_PATH"
}

SCRIPTRELDIR="$(dirname "$(realrelpath ${BASH_SOURCE[0]})")"
SCRIPTABSDIR="$(readlink -f ${SCRIPTRELDIR})"
SCRIPTDIR="$SCRIPTRELDIR"

function run {
  local L_NATIVE_ARGS=()
  local L_FILES=()
  local L_STOP=0
  local L_ARG=""
  local L_F=""

  for L_ARG in "$@"; do
    if [ "$L_ARG" == "--" ]; then
      L_STOP=1
      continue
    fi

    if [ "$L_STOP" -eq 0 ]; then
      L_NATIVE_ARGS+=("$L_ARG")
    else
      L_FILES+=("$L_ARG")
    fi
  done

  for L_F in "${L_FILES[@]}"; do
    checkov --external-checks-dir "$SCRIPTDIR/../additional-tf-checks/" "${L_NATIVE_ARGS[@]}" -f "$L_F"
  done
}

run "$@"
