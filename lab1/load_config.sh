#!/bin/bash

function unique {
    echo "$@" | tr ' ' '\n' | sort -u
}

error() {
    echo >&2 "$1"
    exit 1
}

require_args() {
    local n_args=$1; shift
    local param_name=$1; shift

    if [ "$#" -lt "$n_args" ]; then
        error "$param_name requires $n_args arguments!"
    fi
}

load_config() {
    export CONFIG_NUM=

    export FE_VM=
    export LB_VM=
    export BE_VMS=()
    export DB_VMS=()

    export FE_PORT=
    export LB_PORT=
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
            --lb|--loadbalancer)
                shift;
                require_args 2 lb "$@"
                LB_VM="$1"; shift
                LB_PORT="$1"; shift
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
        2)
            if [ "${#BE_VMS[@]}" -ne 1 ]; then
                error "config 2 requires exactly 1 backend"
            elif [ "${#DB_VMS[@]}" -ne 2 ]; then
                error "config 2 requires exactly 2 databases"
            fi
            ;;
        4)
            if [ -z "$LB_VM" ]; then
                error "config 4 requires a load balancer"
            elif [ "${#BE_VMS[@]}" -ne 2 ]; then
                error "config 4 requires exactly 2 backends"
            elif [ "${#DB_VMS[@]}" -ne 2 ]; then
                error "config 4 requires exactly 2 databases"
            fi
            ;;
        *)
            error "config $CONFIG_NUM unimplemented";;
    esac

    mapfile -t ALL_VMS < <(unique "$FE_VM" "${BE_VMS[@]}" "${DB_VMS[@]}")
    if [ -n "$LB_VM" ]; then
        ALL_VMS+=("$LB_VM")
    fi
    export ALL_VMS
}
