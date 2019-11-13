# Action Samples for deploying to Azure Functions

Use `Azure/functions-action` to automate your workflows to deploy to [Azure Functions](https://azure.microsoft.com/en-us/services/functions/).

If you are looking for a GitHub Action to deploy your customized container image into an Azure Functions container, use [`azure/functions-container-action`](https://github.com/Azure/functions-container-action).

# End-to-End Workflows

## Create Azure function app and Deploy using GitHub Actions (RBAC)
1. Follow the tutorial [Azure Functions Quickstart](https://docs.microsoft.com/en-us/azure/azure-functions/functions-create-first-function-vs-code)
2. Pick a template from the following table depends on your Azure Functions **runtime** and **OS type** and place the template to `.github/workflows/` in your project repository.
3. Change `app-name` to your function app name.
4. Commit and push your project to GitHub repository, you should see a new GitHub workflow initiated in **Actions** tab.

| Templates  | Windows |  Linux |
|------------|---------|--------|
| DotNet     | [windows-dotnet-functionapp-on-azure.yml](https://github.com/Azure/actions-workflow-samples/blob/master/FunctionApp/windows-dotnet-functionapp-on-azure.yml) | [linux-dotnet-functionapp-on-azure.yml](https://github.com/Azure/actions-workflow-samples/blob/master/FunctionApp/linux-dotnet-functionapp-on-azure.yml) |
| Node       | [windows-node.js-functionapp-on-azure.yml](https://github.com/Azure/actions-workflow-samples/blob/master/FunctionApp/windows-node.js-functionapp-on-azure.yml) | [linux-node.js-functionapp-on-azure.yml](https://github.com/Azure/actions-workflow-samples/blob/master/FunctionApp/linux-node.js-functionapp-on-azure.yml) |
| PowerShell | [windows-powershell-functionapp-on-azure.yml](https://github.com/Azure/actions-workflow-samples/blob/master/FunctionApp/windows-powershell-functionapp-on-azure.yml) | - |
| Java       | [windows-java-functionapp-on-azure.yml](https://github.com/Azure/actions-workflow-samples/blob/master/FunctionApp/windows-java-functionapp-on-azure.yml) | - |
| Python     | - | [linux-python-functionapp-on-azure.yml](https://github.com/Azure/actions-workflow-samples/blob/master/FunctionApp/linux-python-functionapp-on-azure.yml) |
| DOCKER     | - | [linux-container-functionapp-on-azure.yml ](https://github.com/Azure/actions-workflow-samples/blob/master/FunctionApp/linux-container-functionapp-on-azure.yml) |


## Dependencies on other Github Actions
* [Checkout](https://github.com/actions/checkout) Checkout your Git repository content into GitHub Actions agent.
* [Azure Login](https://github.com/Azure/actions) Login with your Azure credentials for function app deployment authentication.
* To build app code in a specific language based environment, use setup actions 
  * [Setup DotNet](https://github.com/actions/setup-dotnet) Build your DotNet core function app or function app extensions.
  * [Setup Node](https://github.com/actions/setup-node) Resolve Node function app dependencies using npm.
  * [Setup Python](https://github.com/actions/setup-python) Resolve Python function app dependencies using pip.
  * [Setup Java](https://github.com/actions/setup-java) Resolve Java function app dependencies using maven.
* To build and deploy a containerized app, use [docker-login](https://github.com/Azure/docker-login) to log in to a private container registry such as [Azure Container registry](https://azure.microsoft.com/en-us/services/container-registry/). 
Once login is done, the next set of Actions in the workflow can perform tasks such as building, tagging and pushing containers. 

## Using Publish Profile as Deployment Credential
You may want to get the publish profile from your function app. Using publish profile as deployemnt credential is recommended
if you are not the owner of your Azure subscription.
1. In Azure portal, go to your function app.
2. Click **Get publish profile** and download **.PublishSettings** file.
3. Open the **.PublishSettings** file and copy the content.
4. Paste the XML content to your Github Repository > Settings > Secrets > Add a new secret > **SCM_CREDENTIALS**

## Create Azure function app and Deploy using GitHub Actions (Publish Profile)
1. Follow the tutorial [Azure Functions Quickstart](https://docs.microsoft.com/en-us/azure/azure-functions/functions-create-first-function-vs-code)
2. Use the following template to create the `.github/workflows/` file in your project repository.
3. Change `app-name` to your function app name.
4. Commit and push your project to GitHub repository, you should see a new GitHub workflow initiated in **Actions** tab.
```yaml
name: Linux_Node_Workflow_ScmCred

on:
  push:
    branches:
    - master

jobs:
  build-and-deploy:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@master
    - uses: actions/setup-node@v1
      with:
        node-version: '10.x'
    - name: 'run npm'
      run: |
        npm install
        npm run build --if-present
        npm run test --if-present
    - uses: Azure/functions-action@v1
      id: fa
      with:
        app-name: PLEASE_REPLACE_THIS_WITH_YOUR_FUNCTION_APP_NAME
        publish-profile: ${{ secrets.SCM_CREDENTIALS }}

```

## Using Azure Service Principle for RBAC as Deployment Credential
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
3. Paste the json response from above Azure CLI to your Github Repository > Settings > Secrets > Add a new secret > **AZURE_CREDENTIALS**
