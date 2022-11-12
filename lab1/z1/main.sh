#!/usr/bin/sh

## Global Variables for defaults
RAND="$(openssl rand -hex 4)"
PREFIX="wus-lab1-zad1-zesp9-${RAND}"

RESOURCE_GROUP="${PREFIX}-rg"
LOCATION="westeurope"

mkdir -p "./rgnames"
RESOURCE_GROUP_FILENAME="./rgnames/${PREFIX}.rgname"
echo "$RESOURCE_GROUP" >"$RESOURCE_GROUP_FILENAME"

VNET_NAME="${PREFIX}-vnet"
VNET_SUBNET_NAME="${PREFIX}-subnet"
VM_SIZE="Standard_B1ms"

VM_USER="adminek"
VM_PASSWORD="Aa1_$(openssl rand -hex 16)"
VM_IMAGE="UbuntuLTS"

VM_FE="${PREFIX}-vm-fe"
VM_FE_PUBLIC_IP_NAME="${VM_FE}-public-ip"
VM_FE_PRIVATE_IP="10.0.0.4"

VM_BE="${PREFIX}-vm-be"
VM_BE_PUBLIC_IP_NAME="${VM_BE}-public-ip"
VM_BE_PRIVATE_IP="10.0.0.5"

VM_DB="${PREFIX}-vm-db"
VM_DB_PRIVATE_IP="10.0.0.6"

STORAGE_ACCOUNT="wuslab1zad1$RAND"
CONTAINER_NAME="$PREFIX-container"
CONTAINER_URI="https://$STORAGE_ACCOUNT.blob.core.windows.net/$CONTAINER_NAME"

FE_INIT_SCRIPT_NAME="fe_init.sh"
BE_INIT_SCRIPT_NAME="be_init.sh"
DB_INIT_SCRIPT_NAME="db_init.sh"
FE_INIT_SCRIPT_URL="$CONTAINER_URI/$FE_INIT_SCRIPT_NAME"
BE_INIT_SCRIPT_URL="$CONTAINER_URI/$BE_INIT_SCRIPT_NAME"
DB_INIT_SCRIPT_URL="$CONTAINER_URI/$DB_INIT_SCRIPT_NAME"

## Az Login check
if az account list 2>&1 | grep -q 'az login'
then
    printf >&2 "\n--> Warning: You have to login first with the 'az login' command before you can run this lab tool\n"
    az login -o table
fi

print_stage() {
	echo >&2 "========== $1 =========="
}

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

## Create frontend VM
print_stage "[ASYNC] CREATING FRONTEND VM"

az vm create \
--resource-group "$RESOURCE_GROUP" \
--name "$VM_FE" \
--size "$VM_SIZE" \
--admin-username "$VM_USER" \
--admin-password "$VM_PASSWORD" \
--image "$VM_IMAGE" \
--subnet "$VNET_SUBNET_NAME" \
--private-ip-address "$VM_FE_PRIVATE_IP" \
--public-ip-sku Standard \
--public-ip-address "$VM_FE_PUBLIC_IP_NAME" \
--vnet-name "$VNET_NAME" \
--no-wait \

## Create backend VM
print_stage "[ASYNC] CREATING BACKEND VM"

az vm create \
--resource-group "$RESOURCE_GROUP" \
--name "$VM_BE" \
--size "$VM_SIZE" \
--admin-username "$VM_USER" \
--admin-password "$VM_PASSWORD" \
--image "$VM_IMAGE" \
--subnet "$VNET_SUBNET_NAME" \
--private-ip-address "$VM_BE_PRIVATE_IP" \
--public-ip-sku Standard \
--public-ip-address "$VM_BE_PUBLIC_IP_NAME" \
--vnet-name "$VNET_NAME" \
--no-wait \

## Create database VM
print_stage "[ASYNC] CREATING DATABASE VM"

az vm create \
--resource-group "$RESOURCE_GROUP" \
--name "$VM_DB" \
--size "$VM_SIZE" \
--admin-username "$VM_USER" \
--admin-password "$VM_PASSWORD" \
--image "$VM_IMAGE" \
--subnet "$VNET_SUBNET_NAME" \
--private-ip-address "$VM_DB_PRIVATE_IP" \
--public-ip-sku Standard \
--public-ip-address "" `# disable public address` \
--vnet-name "$VNET_NAME" \
--no-wait \

VM_IDS="$(az vm list -g "$RESOURCE_GROUP" --query "[].id" -o tsv)"

## Wait for all VMs to be ready
print_stage "WAITING FOR VM CREATION"

# shellcheck disable=SC2086 # want to split ids here
az vm wait --created --ids $VM_IDS

## Get public ip addresses
print_stage "FETCHING PUBLIC IPS"

VM_FE_PUBLIC_IP=$(
	az network public-ip show \
	--resource-group "$RESOURCE_GROUP" \
	--name "$VM_FE_PUBLIC_IP_NAME" \
	--query "ipAddress" \
	--output tsv \
)

VM_BE_PUBLIC_IP=$(
	az network public-ip show \
	--resource-group "$RESOURCE_GROUP" \
	--name "$VM_BE_PUBLIC_IP_NAME" \
	--query "ipAddress" \
	--output tsv \
)

## Open ports for VMs
print_stage "OPENING PORTS FOR VMS"

az vm open-port \
--resource-group "$RESOURCE_GROUP" \
--name "$VM_FE" \
--port 22,4200 \

az vm open-port \
--resource-group "$RESOURCE_GROUP" \
--name "$VM_BE" \
--port 22,9966 \

az vm open-port \
--resource-group "$RESOURCE_GROUP" \
--name "$VM_DB" \
--port 22,3306  \

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
	"fe_public_ip": "$VM_FE_PUBLIC_IP",
	"be_public_ip": "$VM_BE_PUBLIC_IP",
	"fe_private_ip": "$VM_FE_PRIVATE_IP",
	"be_private_ip": "$VM_BE_PRIVATE_IP",
	"db_private_ip": "$VM_DB_PRIVATE_IP",
	"vm_user": "$VM_USER",
	"vm_password": "$VM_PASSWORD"
}
EOF

## Add initialization extensions to VMs
print_stage "[ASYNC] CREATING EXTENSION FOR FRONTEND VM INITIALIZATION"

az vm extension set \
  --resource-group "$RESOURCE_GROUP" \
  --vm-name "$VM_FE" \
  --name customScript \
  --publisher Microsoft.Azure.Extensions \
  --protected-settings '{
		"storageAccountName": "'"$STORAGE_ACCOUNT"'",
		"storageAccountKey": "'"$STORAGE_ACCOUNT_KEY"'",
		"fileUris": ["'"$FE_INIT_SCRIPT_URL"'"],
		"commandToExecute": "'"./$FE_INIT_SCRIPT_NAME $VM_BE_PUBLIC_IP"'"
	}' \
  --no-wait \

print_stage "[ASYNC] CREATING EXTENSION FOR BACKEND VM INITIALIZATION"

az vm extension set \
  --resource-group "$RESOURCE_GROUP" \
  --vm-name "$VM_BE" \
  --name customScript \
  --publisher Microsoft.Azure.Extensions \
  --protected-settings '{
		"storageAccountName": "'"$STORAGE_ACCOUNT"'",
		"storageAccountKey": "'"$STORAGE_ACCOUNT_KEY"'",
		"fileUris": ["'"$BE_INIT_SCRIPT_URL"'"],
		"commandToExecute": "'"./$BE_INIT_SCRIPT_NAME $VM_DB_PRIVATE_IP"'"
	}' \
  --no-wait \

print_stage "[ASYNC] CREATING EXTENSION FOR DATABASE VM INITIALIZATION"

az vm extension set \
  --resource-group "$RESOURCE_GROUP" \
  --vm-name "$VM_DB" \
  --name customScript \
  --publisher Microsoft.Azure.Extensions \
  --protected-settings '{
		"storageAccountName": "'"$STORAGE_ACCOUNT"'",
		"storageAccountKey": "'"$STORAGE_ACCOUNT_KEY"'",
		"fileUris": ["'"$DB_INIT_SCRIPT_URL"'"],
		"commandToExecute": "'"./$DB_INIT_SCRIPT_NAME"'"
	}' \
  --no-wait \

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
	"fe_public_ip": "$VM_FE_PUBLIC_IP",
	"be_public_ip": "$VM_BE_PUBLIC_IP",
	"fe_private_ip": "$VM_FE_PRIVATE_IP",
	"be_private_ip": "$VM_BE_PRIVATE_IP",
	"db_private_ip": "$VM_DB_PRIVATE_IP",
	"vm_user": "$VM_USER",
	"vm_password": "$VM_PASSWORD"
}
EOF

## Done
print_stage "DONE"
echo >&2 "Petclinic accesible at http://$VM_FE_PUBLIC_IP:4200"
echo >&2 "Run ./cleanup.sh to remove the resource group"