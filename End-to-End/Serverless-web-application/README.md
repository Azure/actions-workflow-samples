# Action samples for deploying Serverless Web Application architecture

This sample references an architecture of a serverless web application. The application serves static Angular.JS content from Azure Blob Storage (Static Website), and implements REST APIs for CRUD of a to do list with Azure Functions. The API reads data from Cosmos DB and returns the results to the web app. The GitHub workflow uses Azure Bicep for Infrastructure as Code to deploy and configure Azure resources.

## Workflows

This repo contains three GitHub workflow samples. A walk-through and complete artifacts, including sample codes and Bicep files, can be found [here](https://github.com/Azure-Samples/serverless-web-application).

* [Create Azure Resource (IaC)](azure-infra-cicd.yml) workflow validates Bicep files and creates Azure resources necessary to host the sample solution. The Bicep file will create the following resources as a pre-requisite to the next two workflows:

    - Azure API Management.
    - Azure CDN.
    - Azure Cosmos DB for MongolDB.
    - Azure Functions (Windows).
    - Azure Key Vault option to BYO.
    - Azure Storage Account for hosting Static Website.

* [Build and publish .NET](functions-api-cicd.yml) workflow build .NET Core application and publish it to Azure Function. It also import the HTTP Trigger Functions as API's to the API Management using Bicep. This requires that Functions must be able to generate an OpenAPI specification.

* [Build and publish Angular (SPA)](spa-cicd.yml) workflow build Angular application and publish it to Azure Storage Account as a static website. This workflow will register both client and API applications in Azure Active Directory tenant of your subscription for authentication. It also purge Azure CDN to refresh static web content.

## Contributing

This project has adopted the [Microsoft Open Source Code of Conduct](https://opensource.microsoft.com/codeofconduct/). For more information see the [Code of Conduct FAQ](https://opensource.microsoft.com/codeofconduct/faq/) or contact [opencode@microsoft.com](mailto:opencode@microsoft.com) with any additional questions or comments.