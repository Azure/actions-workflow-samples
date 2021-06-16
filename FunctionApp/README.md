# Action Samples for deploying to Azure Functions

Use `Azure/functions-action` to automate your workflows to deploy to [Azure Functions](https://azure.microsoft.com/en-us/services/functions/).

If you are looking for a GitHub Action to deploy your customized container image into an Azure Functions container, use [`azure/functions-container-action`](https://github.com/Azure/functions-container-action).

# End-to-End Workflow

## Workflow Templates

| Templates  | Windows |  Linux |
|------------|---------|--------|
| DotNet     | [windows-dotnet-functionapp-on-azure.yml](https://github.com/Azure/actions-workflow-samples/tree/master/FunctionApp/windows-dotnet-functionapp-on-azure.yml) | [linux-dotnet-functionapp-on-azure.yml](https://github.com/Azure/actions-workflow-samples/tree/master/FunctionApp/linux-dotnet-functionapp-on-azure.yml) |
| Node       | [windows-node.js-functionapp-on-azure.yml](https://github.com/Azure/actions-workflow-samples/tree/master/FunctionApp/windows-node.js-functionapp-on-azure.yml) | [linux-node.js-functionapp-on-azure.yml](https://github.com/Azure/actions-workflow-samples/tree/master/FunctionApp/linux-node.js-functionapp-on-azure.yml) |
| PowerShell | [windows-powershell-functionapp-on-azure.yml](https://github.com/Azure/actions-workflow-samples/tree/master/FunctionApp/windows-powershell-functionapp-on-azure.yml) | - |
| Java       | [windows-java-functionapp-on-azure.yml](https://github.com/Azure/actions-workflow-samples/tree/master/FunctionApp/windows-java-functionapp-on-azure.yml) | [linux-java-functionapp-on-azure.yml](https://github.com/Azure/actions-workflow-samples/tree/master/FunctionApp/linux-java-functionapp-on-azure.yml) |
| Python     | - | [linux-python-functionapp-on-azure.yml](https://github.com/Azure/actions-workflow-samples/tree/master/FunctionApp/linux-python-functionapp-on-azure.yml) |

If you are have extension project(s) in your repo, these templates will **NOT** resolve the **extensions.csproj** in your project. If you want to use binding extensions (e.g. Blob/Queue/EventHub Triggers), please consider [registering Azure Functions binding extensions](https://docs.microsoft.com/en-us/azure/azure-functions/functions-bindings-register) in your host.json.

Alternatively, you can add a `- run: dotnet build --output ./bin` step **before** functions-action step.

## Using Publish Profile as Deployment Credential (recommended)
You may want to get the publish profile from your function app.
Using publish profile as deployemnt credential is recommended if you are not the owner of your Azure subscription.

1. In Azure portal, go to your function app.
2. Click **Get publish profile** and download **.PublishSettings** file.
3. Open the **.PublishSettings** file and copy the content.
4. Paste the XML content to your Github Repository > Settings > Secrets > Add a new secret > **AZURE_FUNCTIONAPP_PUBLISH_PROFILE**
5. Use the above template to create the `.github/workflows/your-workflow.yml` file in your project repository.
6. Change variable values in `env:` section according to your function app.
7. Commit and push your project to GitHub repository, you should see a new GitHub workflow initiated in **Actions** tab.

## Using Azure Service Principle for RBAC as Deployment Credential (deprecated)
You may want to create an [Azure Service Principal for RBAC](https://docs.microsoft.com/en-us/azure/role-based-access-control/overview) and add them as a GitHub Secret in your repository.
1. Download Azure CLI from [here](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli?view=azure-cli-latest), run `az login` to login with your Azure credentials.
2. Run Azure CLI command
```
   az ad sp create-for-rbac --name "myApp" --role contributor \
                            --scopes /subscriptions/{subscription-id}/resourceGroups/{resource-group}/providers/Microsoft.Web/sites/{app-name} \
                            --sdk-auth

  # Replace {subscription-id}, {resource-group}, and {app-name} with the names of your subscription, resource group, and Azure function app.
  # The command should output a JSON object similar to this:

  {
    "clientId": "<GUID>",
    "clientSecret": "<GUID>",
    "subscriptionId": "<GUID>",
    "tenantId": "<GUID>",
    (...)
  }
```
3. Copy and paste the json response from above Azure CLI to your Github Repository > Settings > Secrets > Add a new secret > **AZURE_RBAC_CREDENTIALS**
4. Use [Windows DotNet Function App RBAC](https://github.com/Azure/actions-workflow-samples/blob/master/FunctionApp/windows-dotnet-functionapp-on-azure-rbac.yml) template as a reference to build your workflow in `.github/workflows/` directory.
5. Change variable values in `env:` section according to your function app.
6. Commit and push your project to GitHub repository, you should see a new GitHub workflow initiated in **Actions** tab.
