#!/bin/bash

usage="$(basename "$0") [-h] [-c CLUSTER_NAME] [-g RESOURCE_GROUP_NAME] [-s SUBSCRIPTION_ID] [-r REGION]
Creates a service principal and storage account for using terraform on Azure
where:
    -h  show this help text
    -c  desired cluster name
    -g  desired resource group name
    -s  subscription id for cluster
    -r  region for cluster"

while getopts h:c:g:s:r: flag
do
    case "${flag}" in
        h) echo "$usage"; exit;;
        c) cluster_name=${OPTARG};;
        g) resource_group_name=${OPTARG};;
        s) subscription=${OPTARG};;
        r) region=${OPTARG};;
        :) printf "missing argument for -%s\n" "$OPTARG" >&2; echo "$usage" >&2; exit 1;;
        \?) printf "illegal option: -%s\n" "$OPTARG" >&2; echo "$usage" >&2; exit 1;;
    esac
done

# mandatory arguments
if [ ! "$cluster_name" ] || [ ! "$resource_group_name" ] || [ ! "$subscription" ] || [ ! "$region" ]; then
  echo "all arguments must be provided"
  echo "$usage" >&2; exit 1
fi

echo "Arguments provided:"
echo "Cluster Name: $cluster_name";
echo "Resource Group Name: $resource_group_name";
echo "Subscription: $subscription";
echo "Region: $region";

STORAGE_ACCOUNT_NAME=$(echo "${resource_group_name}" | tr '[:upper:]' '[:lower:]')$RANDOM
CONTAINER_NAME=$(echo "${cluster_name}" | tr '[:upper:]' '[:lower:]')tstate

az account set --subscription $subscription &> /dev/null
# Create resource group
az group create --location $region --resource-group $resource_group_name &> /dev/null

#Create service principal and give it access to group
SP_OUTPUT=$(az ad sp create-for-rbac --name $resource_group_name --role contributor --scopes /subscriptions/$subscription/resourceGroups/$resource_group_name --sdk-auth)
echo $SP_OUTPUT
ARM_CLIENT_ID=$(echo $SP_OUTPUT | jq -r .clientId)
ARM_CLIENT_SECRET=$(echo $SP_OUTPUT | jq -r .clientSecret)
ARM_TENANT_ID=$(echo $SP_OUTPUT | jq -r .tenantId)


# Create storage account
az storage account create --resource-group $resource_group_name --name $STORAGE_ACCOUNT_NAME --sku Standard_LRS --encryption-services blob

# Get storage account key
ACCOUNT_KEY=$(az storage account keys list --resource-group $resource_group_name --account-name $STORAGE_ACCOUNT_NAME --query '[0].value' -o tsv)

# Create blob container
az storage container create --name $CONTAINER_NAME --account-name $STORAGE_ACCOUNT_NAME --account-key $ACCOUNT_KEY

echo "____________________________________________________________"
echo "____________________________________________________________"
echo "the following should be passed to the action"
echo "CLUSTER_NAME: $cluster_name";
echo "RESOURCE_GROUP_NAME: $resource_group_name";
echo "STORAGE_ACCOUNT_NAME: $STORAGE_ACCOUNT_NAME"
echo "STORAGE_CONTAINER_NAME: $CONTAINER_NAME"
echo "STORAGE_ACCESS_KEY: $ACCOUNT_KEY"
echo "ARM_CLIENT_ID: $ARM_CLIENT_ID"
echo "ARM_CLIENT_SECRET: $ARM_CLIENT_SECRET"
echo "ARM_SUBSCRIPTION_ID: $subscription"
echo "ARM_TENANT_ID: $ARM_TENANT_ID"