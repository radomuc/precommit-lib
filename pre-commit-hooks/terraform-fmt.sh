#!/bin/bash
# vim: expandtab softtabstop=2 tabstop=2 shiftwidth=2 smartindent autoindent

################################################################################
# checkov pre-commit hook
################################################################################
# Author: Radomir Ochtyra <radomir.ochtyra@lurse.de>
# Create: 29.10.2022
# Update: 29.10.2022
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

PROG_TF="terraform"

function run {
    local L_PROG_ARGS=()
    local L_FILES=()
    local L_DELIMITER_EXIST=0

    for a in "$@"; do
      if [ "$a" == "--" ]; then
        L_DELIMITER_EXIST=1
        break
      fi
    done

    local L_FOUND=0
    if [ "$L_DELIMITER_EXIST" -ne 0 ]; then
      for a in "$@"; do
        if [ "$a" == "--" ]; then
          L_FOUND=1
          continue
        fi

        if [ "$L_FOUND" -ne 0 ]; then
          L_FILES+=("$a")
        else
          L_PROG_ARGS+=("$a")
        fi
      done
    else
      for a in "$@"; do
        if [ "${a:0:1}" == "-" ]; then
          L_PROG_ARGS+=("$a")
        else
          L_FILES+=("$a")
        fi
      done
    fi

    echo -e "DEBUG: ""${L_FILES[@]}"" | xargs -n1 terraform ""${L_PROG_ARGS[@]}"
    echo -e "${L_FILES[@]}" | xargs -n1 "$PROG_TF" fmt "${L_PROG_ARGS[@]}"
}

run "$@"
