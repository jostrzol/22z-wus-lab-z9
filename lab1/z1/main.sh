#!/usr/bin/bash

# shellcheck source=./lab1/z1/load_config.sh
source ./load_config.sh
load_config || exit $?

## Global Variables for defaults
RAND="$(openssl rand -hex 4)"
PREFIX="wus-lab1-zad1-zesp9-${RAND}"

RESOURCE_GROUP="${PREFIX}-rg"
LOCATION="westeurope"

VNET_NAME="${PREFIX}-vnet"
VNET_SUBNET_NAME="${PREFIX}-subnet"
VM_SIZE="Standard_B1ms"

VM_USER="adminek"
VM_PASSWORD="Aa1_$(openssl rand -hex 16)"
VM_IMAGE="UbuntuLTS"

declare -A VM_PRIVATE_IPS
declare -A VM_NAMES
for vm in "${ALL_VMS[@]}"; do
    last_part=$((vm + 3))
    VM_PRIVATE_IPS[$vm]="10.0.0.$last_part"
    VM_NAMES[$vm]="${PREFIX}-vm-$vm"
done

PUBLIC_IP_NAME="${PREFIX}-public-ip"

trim() {
    local var="$*"
    var="${var#"${var%%[![:space:]]*}"}"
    var="${var%"${var##*[![:space:]]}"}"
    printf '%s' "$var"
}

declare -A VM_PORTS
APP_VMS=("$FE_VM" "${BE_VMS[@]}" "${DB_VMS[@]}")
APP_PORTS=("$FE_PORT" "${BE_PORTS[@]}" "${DB_PORTS[@]}")

for i in "${!APP_VMS[@]}"; do
    vm="${APP_VMS[$i]}"
    port="${APP_PORTS[$i]}"
    VM_PORTS[$vm]=$(trim "${VM_PORTS[$vm]} $port")
done

STORAGE_ACCOUNT="wuslab1zad1$RAND"
CONTAINER_NAME="$PREFIX-container"
CONTAINER_URI="https://$STORAGE_ACCOUNT.blob.core.windows.net/$CONTAINER_NAME"

FE_INIT_SCRIPT_NAME="fe_init.sh"
BE_INIT_SCRIPT_NAME="be_init.sh"
DB_INIT_SCRIPT_NAME="db_init.sh"

## Az Login check
if az account list 2>&1 | grep -q 'az login'
then
    printf >&2 "\n---login using 'az login' command first\n"
    az login -o table
fi

print_stage() {
    echo >&2 "====================<( $1 )"
}

## Save resource group
mkdir -p "./rgnames"
RESOURCE_GROUP_FILENAME="./rgnames/${PREFIX}.rgname"
echo "$RESOURCE_GROUP" >"$RESOURCE_GROUP_FILENAME"

## Create Resource Group
print_stage "CREATING RESOURCE GROUP"

az group create \
--location "$LOCATION" \
--resource-group "$RESOURCE_GROUP"

## Create Vnet
print_stage "CREATING VNET"

az network vnet create \
--resource-group "$RESOURCE_GROUP" \
--name "$VNET_NAME" \
--address-prefixes 10.0.0.0/16

az network vnet subnet create \
--resource-group "$RESOURCE_GROUP" \
--vnet-name "$VNET_NAME" \
--name "$VNET_SUBNET_NAME" \
--address-prefixes 10.0.0.0/24

## Creating VMs
print_stage "CREATING VMS"

for vm in "${ALL_VMS[@]}"; do
    print_stage "[ASYNC] CREATING VM $vm"

    if [ "$vm" = "$FE_VM" ]; then
        public_ip="$PUBLIC_IP_NAME"
    else
        public_ip=""
    fi

    az vm create \
    --resource-group "$RESOURCE_GROUP" \
    --name "${VM_NAMES[$vm]}" \
    --size "$VM_SIZE" \
    --admin-username "$VM_USER" \
    --admin-password "$VM_PASSWORD" \
    --image "$VM_IMAGE" \
    --subnet "$VNET_SUBNET_NAME" \
    --private-ip-address "${VM_PRIVATE_IPS[$vm]}" \
    --public-ip-sku Standard \
    --public-ip-address "$public_ip" \
    --vnet-name "$VNET_NAME" \
    --no-wait
done

VM_IDS="$(az vm list -g "$RESOURCE_GROUP" --query "[].id" -o tsv)"

## Wait for all VMs to be ready
print_stage "WAITING FOR VM CREATION"

# shellcheck disable=SC2086 # want to split ids here
az vm wait --created --ids $VM_IDS

## Get public ip address
print_stage "FETCHING PUBLIC IPS"

PUBLIC_IP=$(
    az network public-ip show \
    --resource-group "$RESOURCE_GROUP" \
    --name "$PUBLIC_IP_NAME" \
    --query "ipAddress" \
    --output tsv \
)

## Open ports for VMs
print_stage "OPENING PORTS FOR VMS"

for vm in "${!VM_PORTS[@]}"; do
    ports="22,$(echo "${VM_PORTS[$vm]}" | tr ' ' ',')"

    print_stage "OPENING PORTS $ports FOR VM $vm"

    az vm open-port \
    --resource-group "$RESOURCE_GROUP" \
    --name "${VM_NAMES[$vm]}" \
    --port "$ports"
done

## Upload initialization files
print_stage "UPLOADING INIT FILES"

STORAGE_ACCOUNT_ID="$(
    az storage account create \
    --name "$STORAGE_ACCOUNT" \
    --resource-group "$RESOURCE_GROUP" \
    --query "id" \
    --output tsv \
)"

STORAGE_ACCOUNT_KEY="$(
    az storage account keys list \
    --resource-group "$RESOURCE_GROUP" \
    --account-name "$STORAGE_ACCOUNT" \
    --query "[0].value" \
    --output tsv \
)"

STORAGE_ACCOUNT_CONNECTION_STRING="$(
    az storage account show-connection-string \
    --ids "$STORAGE_ACCOUNT_ID" \
    --query "connectionString" \
    --output tsv \
)"

az storage container create \
--name "$CONTAINER_NAME" \
--connection-string "$STORAGE_ACCOUNT_CONNECTION_STRING" \

az storage blob upload-batch \
--source "$(pwd)" \
--destination "$CONTAINER_NAME" \
--connection-string "$STORAGE_ACCOUNT_CONNECTION_STRING" \
--pattern "??_init.sh" \

# Print setup info
print_stage "SETUP INFO"
cat <<EOF
{
    "id": "$PREFIX",
    "resource_group": "$RESOURCE_GROUP",
    "fe_public_ip": "$PUBLIC_IP",
    "vm_user": "$VM_USER",
    "vm_password": "$VM_PASSWORD"
}
EOF

## Add initialization extensions to VMs
print_stage "CREATING EXTENSIONS ACCORDING TO CONFIG $CONFIG_NUM"

add_extension() {
    vm=$1
    script=$2
    shift; shift

    print_stage "[ASYNC] EXECUTING $script TO VM $vm WITH ARGS $*"

    az vm extension set \
        --resource-group "$RESOURCE_GROUP" \
        --vm-name "${VM_NAMES[$vm]}" \
        --name customScript \
        --publisher Microsoft.Azure.Extensions \
        --protected-settings '{
            "storageAccountName": "'"$STORAGE_ACCOUNT"'",
            "storageAccountKey": "'"$STORAGE_ACCOUNT_KEY"'",
            "fileUris": ["'"$CONTAINER_URI/$script"'"],
            "commandToExecute": "'"./$script $*"'"
        }' \
        --no-wait
}

case "$CONFIG_NUM" in
    1)
        BE_VM="${BE_VMS[0]}"
        DB_VM="${DB_VMS[0]}"

        add_extension "$FE_VM" "$FE_INIT_SCRIPT_NAME" "${VM_PRIVATE_IPS[$BE_VM]}"
        add_extension "$BE_VM" "$BE_INIT_SCRIPT_NAME" "${VM_PRIVATE_IPS[$DB_VM]}"
        add_extension "$DB_VM" "$DB_INIT_SCRIPT_NAME"
        ;;
    *)
        echo >&2 "Configuration not implemented!" && exit
        ;;
esac

# shellcheck disable=SC2086 # want to split ids here
EXTENSION_IDS=$(az vm extension list --ids $VM_IDS --query "[].id" -o tsv)

# Waiting for extensions to execute
print_stage "WAITING FOR EXTENSIONS TO EXECUTE"

# shellcheck disable=SC2086 # want to split ids here
az vm extension wait --created --ids $EXTENSION_IDS

# Print setup info
print_stage "SETUP INFO"
cat <<EOF
{
    "id": "$PREFIX",
    "resource_group": "$RESOURCE_GROUP",
    "fe_public_ip": "$PUBLIC_IP",
    "vm_user": "$VM_USER",
    "vm_password": "$VM_PASSWORD"
}
EOF

## Done
print_stage "DONE"
echo >&2 "Petclinic accesible at http://$PUBLIC_IP:4200 (it may require a moment to initialize)"
echo >&2 "Run ./cleanup.sh to remove the resource group"
