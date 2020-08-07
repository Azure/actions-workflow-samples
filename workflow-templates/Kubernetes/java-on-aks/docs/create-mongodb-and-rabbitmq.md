# Create MongoDB and RabbitMQ in Azure

This guide will walk you through HOW to create MongoDB and RabbitMQ in Azure.

## Prep the dev environment

Make your own copy of the setup environment variables bash script:
```bash
cp .scripts/setup-env-variables-azure-template.sh .scripts/setup-env-variables-azure.sh
```

Prep the dev environment by populating environment variables in 
`.scripts/setup-env-variables-azure.sh`
bash script:

```bash
# ====== Piggy Metrics Azure Coordinates
export RESOURCE_GROUP=INSERT-your-resource-group-name
export REGION=westus2
export AKS_CLUSTER=INSERT-your-AKS-cluster-name
export CONTAINER_REGISTRY=INSERT-your-Azure-Container-Registry-name

## ===== Mongo DB
export MONGODB_DATABASE=INSERT-your-mongodb-database-name
export MONGODB_USER=INSERT-your-cosmosdb-account-name

## ===== Rabbit MQ
export RABBITMQ_RESOURCE_GROUP=INSERT-your-rabbitmq-resource-group-name
export RABBITMQ_VM_NAME=INSERT-your-rabbitmq-virtual-machine-name
export RABBITMQ_VM_ADMIN_USERNAME=INSERT-your-rabbitmq-admin-user-name
```

Then export these environment variables from the 
`java-on-aks' directory:

```bash
pwd
/Users/selvasingh/GitHub/selvasingh/java-on-aks

source .scripts/setup-env-variables-azure.sh
```

## Create MongoDB
Create an instance of MongoDB:
```bash
# Change directory
cd java-on-aks

# Login into Azure
az login

# Create a Resource Group
az group create --name ${RESOURCE_GROUP} \
    --location ${REGION}

# Create a Cosmos DB account
az cosmosdb create --kind MongoDB \
    --resource-group ${RESOURCE_GROUP} \
    --name ${MONGODB_USER}
```
Cut and paste the resource `'id'` value from Azure CLI response into 
`setup-env-variables-azure.sh`, say for example:

```bash
"id": "/subscriptions/685ba005-af8d-4b04-8f16-a7bf38b2eb5a/resourceGroups/spring-cloud-0918/providers/Microsoft.DocumentDB/databaseAccounts/ ...
```

```bash
# Get Cosmos DB connection strings  
az cosmosdb list-connection-strings --resource-group ${RESOURCE_GROUP} \
    --name ${MONGODB_USER} 
```
Cut and paste the primary connection string as `MONGODB_URI` in `setup-env-variables-azure.sh` bash file. 

## Create RabbitMQ

Create an instance of Bitnami RabbitMQ Stack For Microsoft Azure, go to 
[https://portal.azure.com/#blade/Microsoft_Azure_Marketplace/MarketplaceOffersBlade/selectedMenuItemId/home/searchQuery/rabbitmq](https://portal.azure.com/#blade/Microsoft_Azure_Marketplace/MarketplaceOffersBlade/selectedMenuItemId/home/searchQuery/rabbitmq) 
and start:

![](../media/create-rabbitmq-on-azure-0.jpg)

Fill in the form, use the same value as `RABBITMQ_RESOURCE_GROUP`, 
`RABBITMQ_VM_NAME` and `RABBITMQ_VM_ADMIN_USERNAME`, and choose SSH. Select 'Standard DS3 v2' as 
the size:
![](../media/create-rabbitmq-on-azure-1.jpg)

Accept defaults:
![](../media/create-rabbitmq-on-azure-1-b.jpg)

Accept defaults:
![](../media/create-rabbitmq-on-azure-2.jpg)

Accept defaults in all subsequent screens, and proceed to create:
![](../media/create-rabbitmq-on-azure-3.jpg)

![](../media/create-rabbitmq-on-azure-4.jpg)

Open RabbitMQ client and administration ports:
```bash
# https://docs.bitnami.com/azure/infrastructure/rabbitmq/get-started/understand-default-config/
az vm open-port --port 5672 --name ${RABBITMQ_VM_NAME} \
    --resource-group ${RABBITMQ_RESOURCE_GROUP}
az vm open-port --port 15672 --name ${RABBITMQ_VM_NAME} \
    --resource-group ${RABBITMQ_RESOURCE_GROUP} --priority 1100
```

Find the public IP address of the Linux virtual machine where RabbitMQ is running and 
and set the `RABBITMQ_HOST` environment variable in 
`piggymetrics/.scripts/setup-env-variables-azure.sh`:
```bash
# Open an SSH connection, say
# First, export the environment variables
source .scripts/setup-env-variables-azure.sh
# Open an SSH connection
ssh selvasingh@${RABBITMQ_HOST}
``` 

You can adjust RabbitMQ to connect with clients from a different machine:
```bash
# https://docs.bitnami.com/azure/infrastructure/rabbitmq/administration/control-services/
sudo /opt/bitnami/ctlscript.sh status

# Stop RabbitMQ
sudo /opt/bitnami/ctlscript.sh stop

# Edit RabbitMQ configurtion file
# https://docs.bitnami.com/azure/infrastructure/rabbitmq/administration/connect-remotely/
# https://github.com/rabbitmq/rabbitmq-server/blob/master/docs/rabbitmq.config.example
sudo nano /opt/bitnami/rabbitmq/etc/rabbitmq/rabbitmq.config

# Particularly, change line 4 from
    {tcp_listeners, [{"127.0.0.1", 5672}, {"::1", 5672}]},
# TO
    {tcp_listeners, [{"0.0.0.0", 5672}, {"::1", 5672}]},

# Start RabbitMQ
sudo /opt/bitnami/ctlscript.sh start
```

You can get your RabbitMQ admin credentials by following the steps in
[https://docs.bitnami.com/azure/faq/get-started/find-credentials/](https://docs.bitnami.com/azure/faq/get-started/find-credentials/).
Particularly, open a file in the SSH terminal

```bash
cat ./bitnami_credentials
```

Note down the credentials and close the SSH connections. Onto your local 
development machine ...

From the `bitnami_credentials` file, populate the credentials in 
the `piggymetrics/.scripts/setup-env-variables-azure.sh` file
and export them to the environment:
```bash
# Rabbit MQ
export RABBITMQ_USERNAME=INSERT-your-rabbitmq-username
export RABBITMQ_PASSWORD=INSERT-your-rabbitmq-password

# export them
source .scripts/setup-env-variables-azure.sh
```


You should be able to reach the RabbitMQ admin console at:
```bash
open http://${RABBITMQ_HOST}:15672
```

![](../media/rabbitmq-admin-console.jpg)

## Re-prep the local dev environment

Re-prep the dev environment by populating environment variables in 
`piggymetrics/.scripts/setup-env-variables-azure.sh` bash scripts and export them to
your dev environment:

```bash
# ====== Piggy Metrics Azure Coordinates
export RESOURCE_GROUP=INSERT-your-resource-group-name
export REGION=westus2
export AKS_CLUSTER=INSERT-your-AKS-cluster-name
export CONTAINER_REGISTRY=INSERT-your-Azure-Container-Registry-name

## ===== Mongo DB
export MONGODB_DATABASE=INSERT-your-mongodb-database-name
export MONGODB_USER=INSERT-your-cosmosdb-account-name
export MONGODB_URI="INSERT-your-mongodb-connection-string"
export MONGODB_RESOURCE_ID=INSERT-your-mongodb-resource-id

## ===== Rabbit MQ
export RABBITMQ_RESOURCE_GROUP=INSERT-your-rabbitmq-resource-group-name
export RABBITMQ_VM_NAME=INSERT-your-rabbitmq-virtual-machine-name
export RABBITMQ_VM_ADMIN_USERNAME=INSERT-your-rabbitmq-admin-user-name

# Rabbit MQ
export RABBITMQ_HOST=INSERT-your-rabbitmq-host-public-ip-address
export RABBITMQ_PORT=5672
export RABBITMQ_USERNAME=INSERT-your-rabbitmq-username
export RABBITMQ_PASSWORD=INSERT-your-rabbitmq-password

```

Go back to [How to use AKS end-to-end for Java apps?](https://github.com/azure-samples/java-on-aks)