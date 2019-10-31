## Starter Action Workflows to deploy to Azure

These are the workflow files for helping GitHub developers to easily get started with GitHub Actions to automate their deployment workflows targeting Azure. 

Each workflow must be written in YAML and have a `.yml` extension. 

For example: `asp.net-core-webapp-on-azure.yml`

## Guidelines to author a new sample workflow

**Naming Notation:**
* `os-ecosystem-ServiceName-on-azure`: example, linux-container-functionapp-on-azure.yml
*  Specifying OS in the anme is optional if the action workflow sample is OS agnostic and doesnt significantly change between OS (Linux/Windows) 
* ecosystem can be a language (.NET, Nodejs, java, Python, Ruby etc.) or Docker/Container Or Database flavours like SQL/MySQL etc.

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
