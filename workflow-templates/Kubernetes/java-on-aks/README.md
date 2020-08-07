---
page_type: sample
languages:
- java
products:
- Azure Kubernetes Service
description: "End-to-end experience for Java apps in Azure Kubernetes Service (AKS)"
urlFragment: "java-on-aks"
---

# End-to-end experience - Java on AKS

![](https://github.com/actions/java-on-aks/workflows/Build%20%26%20Deploy%20to%20AKS/badge.svg)

This guide walks you through how to deploy and manage Java apps on the Azure Kubernetes Service.

<!--

## Editor's checklist
- What will you experience (DONE)
- What you will need (DONE)
- Start here (DONE)
- Build Piggymetrics - Spring Cloud micro service apps (NOT NEEDED)
- Create Mongodb and RabbitMQ (DONE)
- Run Piggymetrics locally (NOT NEEDED)
- Create Azure Kubernetes Service and Azure Container Registry (DONE)
- Deploy Piggymetrics to Azure Kubernetes Service (DONE)
- Troubleshooting Java apps in Azure Kubernetes Service (DONE)
- Automate and rapidly deploy changes to Azure Kubernetes Service - using GitHub Actions or Azure Pipelines
- Rapidly deploy changes to Azure Kubernetes without disruption - blue-green deployments
- Scale out Java apps in Azure Kubernetes Service (DONE)
- Congratulations! (DONE)
- Resources 

-->

![](./media/java-on-aks.jpg)
<!--
![](./media/java.jpeg) ![](./media/kubernetes.png) ![](./media/aks-logo.png) ![](./media/acr.png) 
-->

## What will you experience

You will:
- Build Piggymetrics - build a proof-of-concept application, which demonstrates 
micro service architecture pattern using Spring Boot and Spring Cloud
- Create Mongodb and RabbitMQ on Azure
- Create Azure Kubernetes Service and Azure Container Registry
- Deploy Piggymetrics to Azure Kubernetes Service
- Troubleshoot Java apps in Azure Kubernetes Service
- Automate and rapidly deploy changes to Azure Kubernetes Service - using GitHub Actions or Azure Pipelines
- Rapidly deploy changes to Azure Kubernetes without disruption - blue-green deployments
- Scale out Java apps in Azure Kubernetes Service
- Learn about next steps to production

## What you will need

In order to deploy a Java Web app to cloud, you need 
an Azure subscription. If you do not already have an Azure 
subscription, you can activate your 
[MSDN subscriber benefits](https://azure.microsoft.com/pricing/member-offers/msdn-benefits-details/) 
or sign up for a 
[free Azure account]((https://azure.microsoft.com/pricing/free-trial/)).

In addition, you will need the following:

| [Azure CLI](http://docs.microsoft.com/cli/azure/overview) 
| [Java 8](https://www.azul.com/downloads/azure-only/zulu) 
| [Maven 3](http://maven.apache.org/) 
| [Git](https://github.com/) 
| [ACR Docker Credential Helper](https://github.com/Azure/acr-docker-credential-helper)
| [Docker](https://docs.docker.com/v17.09/engine/installation/)
| [Kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl/)
| [Helm](https://helm.sh/docs/intro/install/)
| [dos2unix](https://brewinstall.org/install-dos2unix-on-mac-with-brew/)
|

## IMPORTANT - Start Here

Clone this GitHub repo and change directory:
```bash
git clone https://github.com/Azure-Samples/java-on-aks.git

cd java-on-aks
```

## Create MongoDB and RabbitMQ

You can create MongoDB and RabbitMQ on Azure by following steps outlined [here](./docs/create-mongodb-and-rabbitmq.md)
and capture MongoDB and RabbitMQ coordinates and credentials in 
`setup-env-variables-azure.sh`. 

## Create Azure Container Registry and Azure Kubernetes Service

### Create Azure Container Registry
If you have not yet setup the development environment, 
make a copy of the setup environment variables bash script:
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
export MONGODB_URI="INSERT-your-mongodb-connection-string"
export MONGODB_RESOURCE_ID=INSERT-your-mongodb-resource-id

## ===== Rabbit MQ
export RABBITMQ_RESOURCE_GROUP=INSERT-your-rabbitmq-resource-group-name
export RABBITMQ_VM_NAME=INSERT-your-rabbitmq-virtual-machine-name
export RABBITMQ_ADMIN_USERNAME=INSERT-your-rabbitmq-admin-user-name

# Rabbit MQ
export RABBITMQ_HOST=INSERT-your-rabbitmq-host-public-ip-address
export RABBITMQ_PORT=5672
export RABBITMQ_USERNAME=INSERT-your-rabbitmq-username
export RABBITMQ_PASSWORD=INSERT-your-rabbitmq-password
```

Then, export these environment variables from the `java-on-aks` directory:

```bash
source .scripts/setup-env-variables-azure.sh
```

Create an Azure Container Registry instance using Azure CLI:
```bash
# Create a Resource Group, if you have not created one
az group create --name ${RESOURCE_GROUP} \
    --location ${REGION}
    
# Create Azure Container Registry
az acr create --name ${CONTAINER_REGISTRY} \
    --resource-group ${RESOURCE_GROUP} \
    --sku basic --location ${REGION}
    
# Log into Azure Container Registry
az acr login -n ${CONTAINER_REGISTRY}

```

### Create Azure Kubernetes Service

Create an Azure Kubernetes Service instance and attach the Azure Container Registry using Azure CLI:
```bash
az aks create --name ${AKS_CLUSTER} \
    --resource-group ${RESOURCE_GROUP} \
    --location ${REGION} \
    --attach-acr ${CONTAINER_REGISTRY} \
    --node-vm-size Standard_DS3_v2 \
    --node-count 5
```

Get access credentials for the AKS cluster:
```bash
az aks get-credentials --name ${AKS_CLUSTER} \
    --resource-group ${RESOURCE_GROUP}
```

### Auto instrument for monitoring Java apps on Azure Kubernetes Service

If you do not have an instance of Application Insights, see
 [how to create Application Insights](./docs/create-application-insights.md).

Download Java agent ([download link](https://github.com/microsoft/Application-Insights-K8s-Codeless-Attach/releases))
for auto instrumenting for monitoring Java apps on an Azure Kubernetes Service.

From a Linux or MacOS terminal, execute init.sh from the release.

```bash
source init.sh
```

Open the generated `values.yaml` file in an editor and fill up Kubernetes Cluster
 target namespace, say `default`, and Application Insights `Instrumentation Key`. Like this:
 
```yaml
namespaces: 
  - target : "default" # kubernetes namespace where the Java apps will be auto-instrumented
    iKey: "c197cf6b-WWWW-XXXX-YYYY-ZZZZZZZZZZZZ" # Instrumentation Key of the receiving Application Insights resource
```

Install the Java agent for auto instrumentation:
```bash
helm install ./helm-<version>.tgz -f values.yaml --generate-name
```

## Deploy Piggymetrics to Azure Kubernetes Service

### Build and push container images for micro service apps

Build Java apps, container images and push images to Azure Container Registry
using Maven and [Jib](https://github.com/GoogleContainerTools/jib/tree/master/jib-maven-plugin):
 
```bash
cd config
mvn compile jib:build \
    -Djib.container.environment=CONFIG_SERVICE_PASSWORD=${CONFIG_SERVICE_PASSWORD}

cd ../registry
mvn compile jib:build

cd ../gateway
mvn compile jib:build

cd ../auth-service
mvn compile jib:build

cd ../account-service
mvn compile jib:build \
    -Djib.container.environment=ACCOUNT_SERVICE_PASSWORD=${ACCOUNT_SERVICE_PASSWORD}

cd ../statistics-service
mvn compile jib:build \
    -Djib.container.environment=STATISTICS_SERVICE_PASSWORD=${STATISTICS_SERVICE_PASSWORD}

cd ../notification-service
mvn compile jib:build \
    -Djib.container.environment=NOTIFICATION_SERVICE_PASSWORD=${NOTIFICATION_SERVICE_PASSWORD}

```

Jib is configured to start from a production-ready distribution of Java. For example:
```xml
<plugin>
    <groupId>com.google.cloud.tools</groupId>
    <artifactId>jib-maven-plugin</artifactId>
    <version>1.8.0</version>
    <configuration>
        <from>
            <!-- production-ready distribution of Java -->
            <image>mcr.microsoft.com/java/jre-headless:8u232-zulu-alpine</image>
        </from>
        <to>
            <image>${CONTAINER_REGISTRY}.azurecr.io/${parent.artifactId}-${project.name}</image>
        </to>
        <container>
            <jvmFlags>
                <jvmFlag>-Xms2048m</jvmFlag>
                <jvmFlag>-Xmx2048m</jvmFlag>
            </jvmFlags>
            <ports>
                <port>${CONFIG_PORT}</port>
            </ports>
            <labels>
                <key1>${project.version}</key1>
            </labels>
        </container>
    </configuration>
</plugin>
```

### Prepare Kubernetes manifest files

Prepare Kubernetes manifest files using the supplied `bash` script:

```bash
# cd to kubernetes folder
cd ../kubernetes
source ../.scripts/prepare-kubernetes-manifest-files.sh

```
### Create Secrets in Kubernetes

You can create Secrets for deploying micro service apps in Kubernetes:
```bash
kubectl apply -f deploy/0-secrets.yaml

# you can view Secrets in Kubernetes using:
kubectl get secret piggymetrics -o yaml
```

### Deploy Spring Cloud Config Server

You can deploy the Spring Cloud Config Server to Kubernetes:
```bash
kubectl apply -f deploy/1-config.yaml
```

### Deploy Spring Cloud Service Registry

You can deploy the Spring Cloud Service Registry to Kubernetes:
```bash
kubectl apply -f deploy/2-registry.yaml
```

You can validate that a Spring Cloud Config Server is up and running by
invoking its REST API.

The Spring Cloud Config Server REST API has resources in the following form:

```bash
/{application}/{profile}[/{label}]
/{application}-{profile}.yml
/{label}/{application}-{profile}.yml
/{application}-{profile}.properties
/{label}/{application}-{profile}.properties
```

You can get IP addresses of Spring Cloud Config Server and Spring Cloud Service Registry 
using `kubectl`:

```bash
kubectl get services
NAME         TYPE           CLUSTER-IP    EXTERNAL-IP     PORT(S)          AGE
config       LoadBalancer   10.0.34.171   51.143.50.77    8888:31892/TCP   3m15s
kubernetes   ClusterIP      10.0.0.1      <none>          443/TCP          3h42m
registry     LoadBalancer   10.0.198.13   52.137.96.211   8761:31689/TCP   6s
```

Try:
```bash
open http://<EXTERNAL-IP-of-config>:8888/gateway/profile
open http://<EXTERNAL-IP-of-config>:8888/account-service/profile
open http://<EXTERNAL-IP-of-config>:8888/statistics-service/profile
open http://<EXTERNAL-IP-of-config>:8888/notification-service/profile
...
open http://<EXTERNAL-IP-of-config>:8888/notification-service/profile/development
...
```

![](./media/spring-cloud-config-server-running-in-kubernetes.jpg)

You can validate that a Spring Cloud Service Registry is up and running by 
opening the Service Registry Dashboard:

```bash
open http://<EXTERNAL-IP-of-registry>:8761/
```

![](./media/spring-cloud-service-registry-running-in-kubernetes-01.jpg)

### Deploy Spring Cloud Gateway

You can deploy the Spring Cloud Gateway to Kubernetes:
```bash
kubectl apply -f deploy/3-gateway.yaml
```

### Deploy 4 Spring Cloud micro service apps 

You can deploy Spring Cloud micro service apps to Kubernetes:

```bash
kubectl apply -f deploy/4-auth-service.yaml
kubectl apply -f deploy/5-account-service.yaml
kubectl apply -f deploy/6-statistics-service.yaml
kubectl apply -f deploy/7-notification-service.yaml
```

You can validate that Spring Cloud middleware components and micro service apps are running:

```bash
kubectl get services
NAME                   TYPE           CLUSTER-IP     EXTERNAL-IP     PORT(S)          AGE
account-service        ClusterIP      10.0.215.174   <none>          6000/TCP         108s
auth-service           ClusterIP      10.0.164.45    <none>          5000/TCP         2m26s
config                 LoadBalancer   10.0.34.171    51.143.50.77    8888:31892/TCP   24m
gateway                LoadBalancer   10.0.154.13    52.143.88.12    80:31412/TCP     4m3s
kubernetes             ClusterIP      10.0.0.1       <none>          443/TCP          4h3m
notification-service   ClusterIP      10.0.169.231   <none>          8000/TCP         63s
registry               LoadBalancer   10.0.198.13    52.137.96.211   8761:31689/TCP   21m
statistics-service     ClusterIP      10.0.217.229   <none>          7000/TCP         76s
```

You can also validate that by 
opening the Spring Cloud Service Registry Dashboard

```bash
open http://<EXTERNAL-IP-of-registry>:8761/
```
![](./media/spring-cloud-service-registry-running-in-kubernetes-02.jpg)

### Open Spring Cloud micro service apps running on Kubernetes

Open the Piggymetrics landing page by using the`gateway` app's `EXTERNAL-IP`.

```bash
open http://<EXTERNAL-IP-of-gateway>/
```

For example: 

![](./media/piggy-metrics-first-page.jpg)

![](./media/piggy-metrics-second-page.jpg)

![](./media/piggy-metrics-third-page.jpg)

![](./media/piggy-metrics-fourth-page.jpg)

## Troubleshooting micro service apps in Azure Kubernetes Service

With out-of-the-box support for aggregating logs, metrics, and 
distributed app traces into Azure Monitor, you can easily visualize 
how your applications are performing, detect and diagnose issues 
across micro service applications and their dependencies, drill 
into monitoring data for troubleshooting and gain better 
understanding of what end-users do with your apps.

### Debug in development machine
You can run Spring Cloud Config, Spring Cloud Service Registry, 
Spring Cloud Gateway and other Spring Cloud components on their dev machine. 
You can attach debuggers to Spring Cloud micro service apps and step through them. You can 
look at logs and metrics. Use Java Flight Recorder, etc.

### Stream logs from micro service apps in cloud to development machines
You can stream logs from micro service apps running on Kubernetes to your 
development machine using `kubectl`, like:
```bash
# Stream logs from Spring Cloud Config Server
kubectl logs -f --timestamps=true -l app=config

# Stream logs from Spring Cloud Service Registry
kubectl logs -f --timestamps=true -l app=registry

# Stream logs from Spring Cloud Gateway
kubectl logs -f --timestamps=true -l app=gateway

# Stream logs from Spring Cloud micro service apps
kubectl logs -f --timestamps=true -l app=auth-service
kubectl logs -f --timestamps=true -l app=account-service
kubectl logs -f --timestamps=true -l app=statistics-service
kubectl logs -f --timestamps=true -l app=notification-service
```

### Use aggregated logs and metrics in Azure Log Analytics

You can aggregate logs in Azure Log Analytics and retrieve them 
using Kusto queries. If you do not have a Log Analytics Workspace in Azure, 
see [how to create a Log Analytics Workspace](./docs/create-log-analytics.md)

You can onboard your Kubernetes cluster to Azure Monitor for monitoring, by clicking
on the `Logs` blade in the Azure Portal and choosing your Log Analytics Workspace:

![](./media/onboard-kubernetes-cluster-to-azure-monitor.jpg)


Then, you can view logs using Kusto queries in the `Logs` blade of your 
Log Analytics Workspace:
![](./media/view-logs-in-log-analytics-workspace.jpg)

Here are some sample Kusto queries for viewing logs for each of the micro service apps -
please replace `java-on-aks` with your Azure Kubernetes cluster name:

```sql
-- Logs for Spring Cloud Config Server
let ContainerIdList = KubePodInventory
| where ContainerName contains 'config'
| where ClusterId contains 'java-on-aks'
| distinct ContainerID;
ContainerLog
| where ContainerID in (ContainerIdList)
| where LogEntry !contains "AI:" 
| project LogEntrySource, LogEntry, TimeGenerated, Computer, Image, Name, ContainerID
| order by TimeGenerated desc
| render table


-- Logs for Spring Cloud Service Registry
let ContainerIdList = KubePodInventory
| where ContainerName contains 'registry'
| where ClusterId contains 'java-on-aks'
| distinct ContainerID;
ContainerLog
| where ContainerID in (ContainerIdList)
| where LogEntry !contains "AI:" 
| project LogEntrySource, LogEntry, TimeGenerated, Computer, Image, Name, ContainerID
| order by TimeGenerated desc
| render table


-- Logs for Spring Cloud Gateway
let ContainerIdList = KubePodInventory
| where ContainerName contains 'gateway'
| where ClusterId contains 'java-on-aks'
| distinct ContainerID;
ContainerLog
| where ContainerID in (ContainerIdList)
| where LogEntry !contains "AI:" 
| project LogEntrySource, LogEntry, TimeGenerated, Computer, Image, Name, ContainerID
| order by TimeGenerated desc
| render table


-- Logs for Account Service micro service app
let ContainerIdList = KubePodInventory
| where ContainerName contains 'account-service'
| where ClusterId contains 'java-on-aks'
| distinct ContainerID;
ContainerLog
| where ContainerID in (ContainerIdList)
| where LogEntry !contains "AI:" 
| project LogEntrySource, LogEntry, TimeGenerated, Computer, Image, Name, ContainerID
| order by TimeGenerated desc
| render table


-- Logs for Auth Service micro service app
let ContainerIdList = KubePodInventory
| where ContainerName contains 'auth-service'
| where ClusterId contains 'java-on-aks'
| distinct ContainerID;
ContainerLog
| where ContainerID in (ContainerIdList)
| where LogEntry !contains "AI:" 
| project LogEntrySource, LogEntry, TimeGenerated, Computer, Image, Name, ContainerID
| order by TimeGenerated desc
| render table

```
### Use Application Insights to monitor your micro service apps

You can use Application Insights to monitor your live web application. It will 
automatically detect performance anomalies. It includes powerful analytics tools to 
help you diagnose issues and to understand what users actually do with your app. It is designed to 
help you continuously improve performance and usability.

After some time, you can see distributed tracing in the 
configured Application Insights instance. Go to the `Application Map' blade in the Azure Portal:
![](./media/distributed-tracing.jpg)

Also, you can view the performance and call drill downs in the `Performance` blade:
![](./media/view-performance-in-app-insights.jpg)

## Automate and rapidly deploy changes to Azure Kubernetes Service - GitHub Actions or Azure Pipelines

### Prerequisites

There are some additional prerequisites for this automation:

| [GitHub Account](https://github.com/)
| [Azure DevOps Organization](https://docs.microsoft.com/en-us/azure/devops/pipelines/get-started/pipelines-sign-up?view=azure-devops)
|

### Azure Pipelines

Sign into Azure Pipelines and Create a Pipeline using the 
[`azure-pipelines.yml`](./azure-pipelines.yml) file. Create an Azure KeyVault and upload secrets.

![](./media/azure-pipelines-01.jpg)
![](./media/azure-pipelines-02.jpg) 

### GitHub Actions

You can configure a 
[Workflow to automate build and deploy](https://help.github.com/en/actions/automating-your-workflow-with-github-actions/configuring-a-workflow) 
in GitHub 
using the [`workflow.yml`](./.github/workflows/workflow.yml). Use the steps outlined in
[Creating and Encrypting Secrets in GitHub](https://help.github.com/en/actions/automating-your-workflow-with-github-actions/creating-and-using-encrypted-secrets)
and create secrets for every parameter in `.scripts/setup-env-variables-azure-template.sh`.

![](./media/github-actions-01.jpg)

## Rapidly deploy changes to Azure Kubernetes Service without disruption - blue-green deployments

- To be supplied

## Scale out micro service apps in Azure Kubernetes Service

You can scale out micro service apps in Azure Kubernetes Service:
```bash
kubectl scale deployment gateway --replicas=4

kubectl describe deployment gateway
Name:                   gateway
Namespace:              default
CreationTimestamp:      Sat, 07 Dec 2019 22:36:27 -0800
Labels:                 app=gateway
                        project=piggymetrics
                        tier=frontend
Annotations:            deployment.kubernetes.io/revision: 1
                        kubectl.kubernetes.io/last-applied-configuration:
                          {"apiVersion":"extensions/v1beta1","kind":"Deployment","metadata":{"annotations":{},"labels":{"app":"gateway","project":"piggymetrics","ti...
Selector:               app=gateway,project=piggymetrics,tier=frontend
Replicas:               4 desired | 4 updated | 4 total | 4 available | 0 unavailable
```

## Congratulations and Next Steps to Production

Congratulations!! 

You built, deployed, scaled out and setup monitoring for Spring Cloud micro service apps
using Spring Boot and Spring Cloud, Azure Kubernetes Service, Azure Container Registry,
Azure Monitor, Log Analytics and Application Insights.

To advance Java deployments on Kubernetes to production, you should think 
about the following next steps:
- Frame a scalable infrastructure with Azure Kubernetes Service and Azure Container Registry
to satisfy your deployments' business and technical requirements. See [Microservices architecture on Azure Kubernetes Service (AKS)](https://docs.microsoft.com/en-us/azure/architecture/reference-architectures/microservices/aks)
- Frame a plan to assume infrastructure management -- including load balancers, clustering, 
security, SSL offloading, domain name mapping, etc.
- Define an application lifecyle for apps on Azure Kubernetes Service and use them
 across developer and DevOps automation tools. This lifecyle should include a 
 source-to-container strategy
- Frame a plan to assume service management -- including configuration, managing secrets, backup & restore, 
monitoring & log shipping, upgrades, auto-restart, auto-scale or manual-scale, etc. If you are deploying 
Spring Cloud micro service apps, service management should include 
strategies for manually or dynamically scaling Spring Cloud middleware components - 
Spring Cloud Config Server,
Spring Cloud Service Registry, Spring Cloud Gateway, etc.

## Resources

- [Azure Kubernetes Story](https://docs.microsoft.com/en-us/azure/aks/)
- [Azure Container Registry](https://docs.microsoft.com/en-us/azure/container-registry/)
- [Production Ready and Supported Java Container Images](https://docs.microsoft.com/en-us/azure/java/jdk/java-jdk-docker-images)
- [Kusto Query Language](https://docs.microsoft.com/en-us/azure/kusto/query/)
- [`kubectl` Cheat Sheet 1](https://codefresh.io/kubernetes-tutorial/kubernetes-cheat-sheet/)
- [`kubectl` Cheat Sheet 2](https://kubernetes.io/docs/reference/kubectl/cheatsheet/)
- [Debugging Applications in Kubernetes Cluster](https://kubernetes.io/docs/tasks/debug-application-cluster/)
- [Triage Micro Service Applications using Application Map](https://docs.microsoft.com/en-us/azure/azure-monitor/app/app-map)
- [Azure for Java Cloud Developers](https://docs.microsoft.com/en-us/azure/java/)
- [Spring Cloud Azure](https://cloud.spring.io/spring-cloud-azure/)
- [Spring Cloud](https://spring.io/projects/spring-cloud)
- [Azure Pipelines - Build and Deploy to Azure Kubernetes Service](https://docs.microsoft.com/en-us/azure/devops/pipelines/ecosystems/kubernetes/aks-template)
- [Azure Pipelines - Azure Key Vault Task](https://docs.microsoft.com/en-us/azure/devops/pipelines/tasks/deploy/azure-key-vault)
- [GitHub Actions - Workflow to automate build and deploy](https://help.github.com/en/actions/automating-your-workflow-with-github-actions/configuring-a-workflow)
- ...

## Credits

This Java micro services sample is forked from 
[sqshq/Piggymetrics](https://github.com/sqshq/PiggyMetrics) - see [Piggymetrics README](./README-piggymetrics.md). 

## Contributing

This project welcomes contributions and suggestions.  Most contributions require you to agree to a
Contributor License Agreement (CLA) declaring that you have the right to, and actually do, grant us
the rights to use your contribution. For details, visit https://cla.opensource.microsoft.com.

When you submit a pull request, a CLA bot will automatically determine whether you need to provide
a CLA and decorate the PR appropriately (e.g., status check, comment). Simply follow the instructions
provided by the bot. You will only need to do this once across all repos using our CLA.

This project has adopted the [Microsoft Open Source Code of Conduct](https://opensource.microsoft.com/codeofconduct/).
For more information see the [Code of Conduct FAQ](https://opensource.microsoft.com/codeofconduct/faq/) or
contact [opencode@microsoft.com](mailto:opencode@microsoft.com) with any additional questions or comments.
