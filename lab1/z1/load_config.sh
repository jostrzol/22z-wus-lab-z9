#!/bin/bash

function unique {
    echo "$@" | tr ' ' '\n' | sort -u
}

error() {
    echo >&2 "$1"
    exit 1
}

require_args() {
    n_args=$1; shift
    param_name=$1; shift

    if [ "$#" -lt "$n_args" ]; then
        error "$param_name requires $n_args arguments!"
    fi
}

load_config() {
    export CONFIG_NUM=

    export FE_VM=
    export BE_VMS=()
    export DB_VMS=()

    export FE_PORT=
    export BE_PORTS=()
    export DB_PORTS=()

    while [ "$#" -ne 0 ]; do
        case "$1" in
            --conf|--config)
                shift;
                require_args 1 conf "$@"
                CONFIG_NUM="$1"; shift
                ;;
            --fe|--frontend)
                shift;
                require_args 2 fe "$@"
                FE_VM="$1"; shift
                FE_PORT="$1"; shift
                ;;
            --be|--backend)
                shift;
                require_args 2 be "$@"
                BE_VMS+=("$1"); shift
                BE_PORTS+=("$1"); shift
                ;;
            --db|--database)
                shift;
                require_args 2 db "$@"
                DB_VMS+=("$1"); shift
                DB_PORTS+=("$1"); shift
                ;;
            -*)
                error "option '$1' unrecognized";;
            *)
                error "script takes no positional arguments";;
        esac
    done

    if [ -z "$CONFIG_NUM" ]; then
        error "config not specified"
    fi

    if [ -z "$FE_VM" ]; then
        error "frontend not specified"
    fi

    case "$CONFIG_NUM" in
        1)
            if [ "${#BE_VMS[@]}" -ne 1 ]; then
                error "config 1 requires exactly 1 backend"
            elif [ "${#DB_VMS[@]}" -ne 1 ]; then
                error "config 1 requires exactly 1 database"
            fi
            ;;
        *)
            error "config $CONFIG_NUM unimplemented";;
    esac

    mapfile -t ALL_VMS < <(unique "$FE_VM" "${BE_VMS[@]}" "${DB_VMS[@]}")
    export ALL_VMS
}
