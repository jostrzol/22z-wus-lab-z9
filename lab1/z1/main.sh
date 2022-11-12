#!/usr/bin/sh

## Global Variables for defaults
PREFIX="wus-lab1-zad1-zesp9-$(openssl rand -hex 4)"

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
VM_FE_INIT_CMD_PATH="./fe_init.sh"

VM_BE="${PREFIX}-vm-be"
VM_BE_PUBLIC_IP_NAME="${VM_BE}-public-ip"
VM_BE_PRIVATE_IP="10.0.0.5"
VM_BE_INIT_CMD_PATH="./be_init.sh"

VM_DB="${PREFIX}-vm-db"
VM_DB_PRIVATE_IP="10.0.0.6"
VM_DB_INIT_CMD_PATH="./db_init.sh"


## Az Login check
if az account list 2>&1 | grep -q 'az login'
then
    printf >&2 "\n--> Warning: You have to login first with the 'az login' command before you can run this lab tool\n"
    az login -o table
fi

## Create Resource Group
az group create \
--location "$LOCATION" \
--resource-group "$RESOURCE_GROUP"

## Create Vnet
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


## Wait for all VMs to be ready

# word-splittig wanted here
# shellcheck disable=SC2046
az vm wait --created --ids $(az vm list -g "$RESOURCE_GROUP" --query "[].id" -o tsv)

## Open ports for VMs
az vm open-port \
--resource-group "$RESOURCE_GROUP" \
--name "$VM_FE" \
--port 22,80,4200 \

az vm open-port \
--resource-group "$RESOURCE_GROUP" \
--name "$VM_BE" \
--port 22,9966 \

az vm open-port \
--resource-group "$RESOURCE_GROUP" \
--name "$VM_DB" \
--port 22,3306  \

## Invoke initialization commands
# az vm run-command invoke \
# --command-id "RunShellScript" \
# --resource-group "$RESOURCE_GROUP" \
# --name "$VM_FE" \
# --scripts @"$VM_FE_INIT_CMD_PATH" \
# --no-wait \
#
# az vm run-command invoke \
# --command-id "RunShellScript" \
# --resource-group "$RESOURCE_GROUP" \
# --name "$VM_BE" \
# --parameters "$VM_DB_PRIVATE_IP" \
# --scripts @"$VM_BE_INIT_CMD_PATH" \
# --no-wait \
#
# az vm run-command invoke \
# --command-id "RunShellScript" \
# --resource-group "$RESOURCE_GROUP" \
# --name "$VM_DB" \
# --scripts @"$VM_DB_INIT_CMD_PATH" \
# --no-wait \
#
# # Wait for all init commands to complete
#
# # word-splittig wanted here
# # shellcheck disable=SC2046
# az vm run-command wait --created --ids $(az vm run-command list -g "$RESOURCE_GROUP" --query "[].id" -o tsv)

## Get FE public ip address
VM_FE_PUBLIC_IP=$(
	az network public-ip show \
	--resource-group "$RESOURCE_GROUP" \
	--name "$VM_FE_PUBLIC_IP_NAME" \
	--query "ipAddress" \
	--output tsv \
)

## Get FE public ip address
VM_BE_PUBLIC_IP=$(
	az network public-ip show \
	--resource-group "$RESOURCE_GROUP" \
	--name "$VM_BE_PUBLIC_IP_NAME" \
	--query "ipAddress" \
	--output tsv \
)

# Print setup info
echo >&2 "========== SETUP INFO =========="
cat <<EOF
{
	"id": "$PREFIX",
	"resource_group": "$RESOURCE_GROUP",
	"fe_public_ip": "$VM_FE_PUBLIC_IP",
	"fe_private_ip": "$VM_FE_PRIVATE_IP",
	"be_public_ip": "$VM_BE_PUBLIC_IP",
	"be_private_ip": "$VM_BE_PRIVATE_IP",
	"db_private_ip": "$VM_DB_PRIVATE_IP",
	"vm_user": "$VM_USER",
	"vm_password": "$VM_PASSWORD"
}
EOF
