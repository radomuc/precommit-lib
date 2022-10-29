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

function run {
    terraform fmt "$@"
}

run "$@"
