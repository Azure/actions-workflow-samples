# How to run Piggymetrics locally

This guide will walk you through how to run the Piggymetrics microservice apps
locally on a development machine.

## Setup the local environment

```bash

cd piggymetrics
source .scripts/setup-env-variables-development.sh

```

## Build Piggymetrics and for running locally

Build it using the Maven `development` profile:

```bash
mvn clean package -DskipTests -Denv=development
```

## Start Spring Cloud Config Server

Open a new console and run Spring Cloud Config Server:

```bash
# Change directory to the config module
cd piggymetrics/config
# Setup environment variables
source ../.scripts/setup-env-variables-development.sh
# Run
mvn spring-boot:run
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

Try:
```bash
open http://localhost:8888/gateway/profile
open http://localhost:8888/account-service/profile
open http://localhost:8888/statistics-service/profile
open http://localhost:8888/notification-service/profile
...
open http://localhost:8888/notification-service/profile/development
...

```

![](../media/spring-cloud-config-server-running-locally.jpg)

You may also try:
```bash
open http://localhost:8888/auth-service/profile
```

## Start Spring Cloud Service Registry

Open a new console and run Spring Cloud Service Registry:

```bash
# Change directory to the registry module
cd piggymetrics/registry
# Setup environment variables
source ../.scripts/setup-env-variables-development.sh
# Run
mvn spring-boot:run -Dspring.profiles.active=development
```

You can validate that a Spring Cloud Service Registry is up and running by 
opening the Service Registry Dashboard:

```bash
open http://localhost:8761/
```

![](../media/spring-cloud-registry-running-locally-01.jpg)

## Start Spring Cloud Gateway

Open a new console and run Spring Cloud Service Registry:

```bash
# Change directory to the gateway module
cd piggymetrics/gateway
# Setup environment variables
source ../.scripts/setup-env-variables-development.sh
# Run
mvn spring-boot:run -Dspring.profiles.active=development
```

## Start `account-service`

Open a new console and run `account-service`:

```bash
# Change directory to the account-service module
cd piggymetrics/account-service
# Setup environment variables
source ../.scripts/setup-env-variables-development.sh
# Run
mvn spring-boot:run -Dspring.profiles.active=development
```

## Start `auth-service`

Open a new console and run `auth-service`:

```bash
# Change directory to the auth-service module
cd piggymetrics/auth-service
# Setup environment variables
source ../.scripts/setup-env-variables-development.sh
# Run
mvn spring-boot:run -Dspring.profiles.active=development
```

## Start `statistics-service`

Open a new console and run `statistics-service`:

```bash
# Change directory to the statistics-service module
cd piggymetrics/statistics-service
# Setup environment variables
source ../.scripts/setup-env-variables-development.sh
# Run
mvn spring-boot:run -Dspring.profiles.active=development
```

## Start `notification-service`

Open a new console and run `notification-service`:

```bash
# Change directory to the notification-service module
cd piggymetrics/notification-service
# Setup environment variables
source ../.scripts/setup-env-variables-development.sh
# Run
mvn spring-boot:run -Dspring.profiles.active=development
```

## Validate that microservice apps are running

You can validate that a Spring Cloud Service Registry and multiple 
 microservice apps are up and running by 
opening the Service Registry Dashboard:

```bash
open http://localhost:8761/
```

![](../media/spring-cloud-registry-running-locally-02.jpg)

Open the Piggymetrics app:

```bash
open http://localhost:4000/
```

![](../media/piggy-metrics-running-locally-01.jpg)

![](../media/piggy-metrics-running-locally-02.jpg)

![](../media/piggy-metrics-running-locally-03.jpg)

## Congratulations !!

Go back to [how to use the Azure Spring Cloud service end to end?](https://github.com/azure-samples/azure-spring-cloud)
