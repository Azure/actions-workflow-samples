# Action Samples for deploying to Azure Web apps 

With [`Azure/webapps-deploy`](https://github.com/Azure/webapps-deploy) action, you can automate your workflows to deploy to [Azure Web Apps](https://azure.microsoft.com/en-us/services/app-service/web/) and [Azure Web App for Containers](https://azure.microsoft.com/en-us/services/app-service/containers/).

Also use [`Azure/appservice-settings`](https://github.com/Azure/appservice-settings) to configure App settings, connection strings and other general settings in bulk using JSON syntax on your Azure WebApp (Windows or Linux) or any of its deployment slots.

# End-to-End Sample Workflows

## Dependencies on other Github Actions

* [Checkout](https://github.com/actions/checkout) Checkout your Git repository content into Github Actions agent.
* Authenticate using [Azure Web App Publish Profile](https://github.com/projectkudu/kudu/wiki/Deployment-credentials#site-credentials-aka-publish-profile-credentials) or using [Azure Login](https://github.com/Azure/login)
* To build app code in a specific language based environment, use setup actions 
  * [Setup DotNet](https://github.com/actions/setup-dotnet) Sets up a dotnet environment by optionally downloading and caching a version of dotnet by SDK version and adding to PATH .
  * [Setup Node](https://github.com/actions/setup-node) sets up a node environment by optionally downloading and caching a version of node - npm by version spec and add to PATH
  * [Setup Python](https://github.com/actions/setup-python) sets up Python environment by optionally installing a version of python and adding to PATH.
  * [Setup Java](https://github.com/actions/setup-java) sets up Java app environment optionally downloading and caching a version of java by version and adding to PATH. Downloads from [Azul's Zulu distribution](http://static.azul.com/zulu/bin/).
* To build and deploy a containerized app, use [docker-login](https://github.com/Azure/docker-login) to log in to a private container registry such as [Azure Container registry](https://azure.microsoft.com/en-us/services/container-registry/). 
Once login is done, the next set of Actions in the workflow can perform tasks such as building, tagging and pushing containers. 
  
## Deploy a webapp using GitHub Actions

### Get code

If you already have an app in GitHub that you want to deploy, you can create a workflow for that code. If you are a new user, choose from the below table, a sample code repo based on **runtime** and fork in GitHub.

### Create Azure Web App 
Provision a web app by following the tutorial [Azure Web Apps Quickstart](https://docs.microsoft.com/en-us/azure/app-service/overview#next-steps)

### Choose a sample workflow template
1. Pick a template from the below table depending on your Azure web app **runtime** and place the template to `.github/workflows/` in your project repository.
2. Change `app-name` to your Web app name.
3. Commit and push your project to GitHub repository, you should see a new GitHub Action initiated in **Actions** tab.
 

|  Runtime | Template |Sample Code|
|------------|---------|---------|
| DotNet     | [dotnet.yml](https://github.com/Azure/actions-workflow-samples/blob/master/AppService/asp.net-webapp-on-azure.yml) | https://github.com/Azure-Samples/dotnet-sample |
| DotNet Core    | [dotnet_core.yml](https://github.com/Azure/actions-workflow-samples/blob/master/AppService/asp.net-core-webapp-on-azure.yml) | https://github.com/Azure-Samples/dotnet_core_sample |
| Node       | [node.yml](https://github.com/Azure/actions-workflow-samples/blob/master/AppService/node.js-webapp-on-azure.yml) | https://github.com/Azure-Samples/node_express_app |
| Java | [java_jar.yml](https://github.com/Azure/actions-workflow-samples/blob/master/AppService/java-jar-webapp-on-azure.yml) |https://github.com/Azure-Samples/java-spring-petclinic |
| Java      | [java_war.yml](https://github.com/Azure/actions-workflow-samples/blob/master/AppService/java-war-webapp-on-azure.yml) |https://github.com/Azure-Samples/Java-application-petstore-ee7|
| Python     | [python.yml](https://github.com/Azure/actions-workflow-samples/blob/master/AppService/python-webapp-on-azure.yml) | https://github.com/Azure-Samples/pythonSample_thecatsaidno|
| DOCKER     | [docker.yml](https://github.com/Azure/actions-workflow-samples/blob/master/AppService/docker-webapp-container-on-azure.yml) | https://github.com/Azure-Samples/Node_express_container|


### Sample workflow to build and deploy a Node.js Web app to Azure using publish profile

```yaml

# File: .github/workflows/workflow.yml

on: push

jobs:
  build-and-deploy:
    runs-on: ubuntu-latest
    steps:
    # checkout the repo
    - name: 'Checkout Github Action' 
      uses: actions/checkout@master
    
    - name: Setup Node 10.x
      uses: actions/setup-node@v1
      with:
        node-version: '10.x'
    - name: 'npm install, build, and test'
      run: |
        npm install
        npm run build --if-present
        npm run test --if-present
       
    - name: 'Run Azure webapp deploy action using publish profile credentials'
      uses: azure/webapps-deploy@v1
      with: 
        app-name: node-rn
        publish-profile: ${{ secrets.azureWebAppPublishProfile }}
        

```

#### Configure deployment credentials:

For any credentials like Azure Service Principal, Publish Profile etc add them as [secrets](https://developer.github.com/actions/managing-workflows/storing-secrets/) in the GitHub repository and then use them in the workflow.

The above example uses app-level credentials i.e., publish profile file for deployment. 

Follow the steps to configure the secret:
  * Download the publish profile for the WebApp from the portal (Get Publish profile option)
  * Define a new secret under your repository settings, Add secret menu
  * Paste the contents for the downloaded publish profile file into the secret's value field
  * Now in the workflow file in your branch: `.github/workflows/workflow.yml` replace the secret for the input `publish-profile:` of the deploy Azure WebApp action (Refer to the example above)
    

### Sample workflow to build and deploy a Node.js app to Azure WebApp for container using Azure service principal

  * [Azure Login](https://github.com/Azure/login) Login with your Azure credentials for Web app deployment authentication. Once login is done, the next set of Azure actions in the workflow can re-use the same session within the job.

```yaml

on: [push]

name: Linux_Container_Node_Workflow

jobs:
  build-and-deploy:
    runs-on: ubuntu-latest
    steps:
    # checkout the repo
    - name: 'Checkout Github Action' 
      uses: actions/checkout@master
    
    - name: 'Login via Azure CLI'
      uses: azure/login@v1
      with:
        creds: ${{ secrets.AZURE_CREDENTIALS }}
    
    - uses: azure/docker-login@v1
      with:
        login-server: contoso.azurecr.io
        username: ${{ secrets.REGISTRY_USERNAME }}
        password: ${{ secrets.REGISTRY_PASSWORD }}
    
    - run: |
        docker build . -t contoso.azurecr.io/nodejssampleapp:${{ github.sha }}
        docker push contoso.azurecr.io/nodejssampleapp:${{ github.sha }} 
      
    - uses: azure/webapps-deploy@v2
      with:
        app-name: 'node-rnc'
        images: 'contoso.azurecr.io/nodejssampleapp:${{ github.sha }}'
    
    - name: Azure logout
      run: |
        az logout

```

#### Configure deployment credentials:

For any credentials like Azure Service Principal, Publish Profile etc add them as [secrets](https://help.github.com/en/articles/virtual-environments-for-github-actions#creating-and-using-secrets-encrypted-variables) in the GitHub repository and then use them in the workflow.

The above example uses user-level credentials i.e., Azure Service Principal for deployment. 

Follow the steps to configure the secret:
  * Define a new secret under your repository settings, Add secret menu
  * Paste the contents of the below [az cli](https://docs.microsoft.com/en-us/cli/azure/?view=azure-cli-latest) command as the value of secret variable, for example 'AZURE_CREDENTIALS'
```bash  

   az ad sp create-for-rbac --name "myApp" --role contributor \
                            --scopes /subscriptions/{subscription-id}/resourceGroups/{resource-group} \
                            --sdk-auth
                            
  # Replace {subscription-id}, {resource-group} with the subscription, resource group details of the WebApp
  
  # The command should output a JSON object similar to this:

  {
    "clientId": "<GUID>",
    "clientSecret": "<GUID>",
    "subscriptionId": "<GUID>",
    "tenantId": "<GUID>",
    (...)
  }
  
```
  * You can further scope down the Azure Credentials to the Web App using scope attribute. For example, 
  ```
   az ad sp create-for-rbac --name "myApp" --role contributor \
                            --scopes /subscriptions/{subscription-id}/resourceGroups/{resource-group}/providers/Microsoft.Web/sites/{app-name} \
                            --sdk-auth

  # Replace {subscription-id}, {resource-group}, and {app-name} with the names of your subscription, resource group, and Azure Web App.
```
  * Now in the workflow file in your branch: `.github/workflows/workflow.yml` replace the secret in Azure login action with your secret (Refer to the example above)
  
