#!/bin/bash

trim() {
    local var="$*"
    var="${var#"${var%%[![:space:]]*}"}"
    var="${var%"${var##*[![:space:]]}"}"
    printf '%s' "$var"
}

describe_vm() {
    local vm=$1
    local name=$2
    local private_ip=$3
    local port=$4

    cat <<EOF
{
    "vm": "$vm",
    "name": "$name",
    "private_ip": "$private_ip",
    "port": "$port"
}
EOF

}

describe_vms() {
    local first=y
    for vm in "${!VM_PORTS[@]}"; do
        [ $first != y ] && echo ","
        first=n
        describe_vm "$vm" "${VM_NAMES[$vm]}" "${VM_PRIVATE_IPS[$vm]}" "${VM_PORTS[$vm]}"
    done
}

print_info() {
cat <<EOF | jq
{
    "id": "$PREFIX",
    "resource_group": "$RESOURCE_GROUP",
    "fe_public_ip": "$PUBLIC_IP",
    "vms": [$(describe_vms)],
    "vm_user": "$VM_USER",
    "vm_password": "$VM_PASSWORD"
}
EOF
}
