#
# Build stage
#
FROM maven:3.6.0-jdk-11-slim AS build
COPY src /create-cosmosdb-action/src
COPY pom.xml /create-cosmosdb-action/
RUN mvn -f /create-cosmosdb-action/pom.xml clean package

#
# Package stage
#
FROM openjdk:11-jre-slim
COPY --from=build /create-cosmosdb-action/target/action-0.0.1-SNAPSHOT.jar /usr/local/lib/action.jar
EXPOSE 8080
ENTRYPOINT ["java","-jar","/usr/local/lib/action.jar"]

#/Users/marcushines/devpomelopment/create-cosmosdb-action