## Starter Action Workflows to deploy to Azure

[GitHub Actions for Azure](https://github.com/Azure/actions) help you easily create workflows to build, test, package, release and deploy to Azure, following a push or pull request.

You use Azure starter templates present in this repo to easily create GitHub CI/CD workflows targeting Azure, to deploy your apps created with popular languages and frameworks such as .NET, Node.js, Java, PHP, Ruby or Python, in containers or running on any operating system.

## Guidelines to select/author a new sample workflow

**Folder Structure:**
These workflow samples to automate your deployment workflows targeting various Azure services are organised under folders of same names. For example: `/AppService/asp.net-core-webapp-on-azure.yml`

- [**/AppService** ](https://github.com/Azure/actions-workflow-samples/tree/master/AppService) Samples to configure and deploy web applications that scale with your business, to [Azure App Service](https://azure.microsoft.com/en-us/services/app-service/web/)

- [**/FunctionApp**](https://github.com/Azure/actions-workflow-samples/tree/master/FunctionApp) Samples to build and deploy serverless apps to [Azure Functions](https://azure.microsoft.com/en-us/services/functions/)

- [**/Kubernetes**](https://github.com/Azure/actions-workflow-samples/tree/master/Kubernetes) Samples to deploy to any Kubernetes cluster on-premise or any cloud including [Azure Kubernetes service](https://azure.microsoft.com/en-us/services/kubernetes-service/)

- [**/Database**](https://github.com/Azure/actions-workflow-samples/tree/master/Database) Samples to deploy to a database on Azure, [Azure SQl database](https://azure.microsoft.com/en-us/services/sql-database/) or [Azure MySQL database](https://azure.microsoft.com/en-us/services/mysql/)

- [**/AzurePipelines**](https://github.com/Azure/actions-workflow-samples/tree/master/AzurePipelines) Samples to trigger a CD run in Azure Pipelines from a GitHub Action workflow

- [**/AzureCLI**](https://github.com/Azure/actions-workflow-samples/tree/master/AzureCLI) Samples to run Azure CLI sripts to provision and manage Azure resources from a GitHub Action workflow

**Naming Notation:**
* `os-ecosystem-ServiceName-on-azure`: example, linux-container-functionapp-on-azure.yml
* OS in the name is optional if the action workflow sample is OS agnostic and doesnt significantly change between OS (Linux/Windows) 
* Ecosystem can be a language (.NET, Nodejs, java, Python, Ruby etc.) or Docker/Container Or Database flavours like SQL/MySQL etc.

**Workflow structure**
* Include 'name' for every workflow to indicate the purpose of the workflow
* Ensure that starter workflows run on: push by default.  
* For all secrets to be defined in the workflow, use UPPER_CASE with underscore delimiters instead of snake_case or camelCase.
* Include a commented **Configuration section** which incldes hyperlinks to documentation for the Actions used and other pre-reqs.
* Define environment variables as part of configuration.  We think this will help provide visibility into the things that need to be configured as part of te workflow.
* Ensure all Azure actions referenced in the workflow are pointing to a released version of the action and not from the master. For list of all released GitHub actions for Azure, please refer to https://github.com/Azure/actions

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
