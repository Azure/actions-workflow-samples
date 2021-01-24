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
  
## Choose a sample workflow template

### Get started using a sample app

If you are a new user, to simplify the onboarding experience with deploying web applications, we’ve included **sample code** repositories in the below table which can help you get started in four easy steps:

1. Fork the sample repository (example, [Node sample](https://github.com/Azure-Samples/node_express_app)).
2. Click on **Deploy to Azure** in the readme file within the repo which redirects to Azure portal to create a new Web App for Node.
3. Configure the required GitHub Repo [secrets](https://help.github.com/en/actions/configuring-and-managing-workflows/creating-and-storing-encrypted-secrets).
4. Update the workflow YAML file already present inside the folder: `.github/workflows/`, with the Web App configuration and commit the changes.

These steps will trigger a new CI/CD workflow in **Actions** tab that builds and deploys the app to Azure using GitHub Actions.

### Get started with your app

If you already have an app in GitHub that you want to deploy, you can create a workflow for that code using the following steps:

1. Provision a web app in Azue portal or by following the tutorial [Azure Web Apps Quickstart](https://docs.microsoft.com/en-us/azure/app-service/overview#next-steps)
2. Choose a workflow **template** from the below table based on **runtime** of your app and copy the contents.
3. Create a new **workflow.yml** file  with the template contents under the path: `.github/workflows/` in your code repository.
4. Configure the required GitHub Repo [secrets](https://help.github.com/en/actions/configuring-and-managing-workflows/creating-and-storing-encrypted-secrets).
5. Update the workflow YAML file present inside the folder: `.github/workflows/`, with the Web App configuration and commit the changes to trigger a new workflow.


|  Runtime | Template |Sample Code|
|------------|---------|---------|
| DotNet     | [dotnet.yml](https://github.com/Azure/actions-workflow-samples/blob/master/AppService/asp.net-webapp-on-azure.yml) | https://github.com/Azure-Samples/dotnet-sample |
| DotNet Core    | [dotnet_core.yml](https://github.com/Azure/actions-workflow-samples/blob/master/AppService/asp.net-core-webapp-on-azure.yml) | https://github.com/Azure-Samples/dotnet_core_sample |
| Node       | [node.yml](https://github.com/Azure/actions-workflow-samples/blob/master/AppService/node.js-webapp-on-azure.yml) | https://github.com/Azure-Samples/node_express_app |
| Java | [java_jar.yml](https://github.com/Azure/actions-workflow-samples/blob/master/AppService/java-jar-webapp-on-azure.yml) |https://github.com/Azure-Samples/java-spring-petclinic |
| Java      | [java_war.yml](https://github.com/Azure/actions-workflow-samples/blob/master/AppService/java-war-webapp-on-azure.yml) |https://github.com/Azure-Samples/Java-application-petstore-ee7|
| Python     | [python.yml](https://github.com/Azure/actions-workflow-samples/blob/master/AppService/python-webapp-on-azure.yml) | https://github.com/Azure-Samples/pythonSample_thecatsaidno|
| DOCKER     | [docker.yml](https://github.com/Azure/actions-workflow-samples/blob/master/AppService/docker-webapp-container-on-azure.yml) | https://github.com/Azure-Samples/Node_express_container|
| DOCKER DotNet Core & SQL | [docker_dotnet_core_sql.yml](https://github.com/Azure/actions-workflow-samples/blob/master/AppService/docker-webapp-container-on-azure.yml) | https://github.com/Azure-Samples/dotnetcore-containerized-sqldb-ghactions|


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
      uses: azure/webapps-deploy@v2
      with: 
        app-name: node-rn
        publish-profile: ${{ secrets.azureWebAppPublishProfile }}
        

```

#### Configure deployment credentials:

For any credentials like Azure Service Principal, Publish Profile etc add them as [secrets](https://help.github.com/en/actions/configuring-and-managing-workflows/creating-and-storing-encrypted-secrets) in the GitHub repository and then use them in the workflow.

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

For any credentials like Azure Service Principal, Publish Profile etc add them as [secrets](https://help.github.com/en/actions/configuring-and-managing-workflows/creating-and-storing-encrypted-secrets) in the GitHub repository and then use them in the workflow.

The above example uses user-level credentials i.e., Azure Service Principal for deployment. 

Follow the steps to configure the secret:
  * Define a new secret variable under your repository **Settings** -> **Secrets** -> **New secret**.  Provide a secret variable **Name**, for example 'AZURE_CREDENTIALS'. 
  * Run the below [az cli](https://docs.microsoft.com/en-us/cli/azure/?view=azure-cli-latest) command and Store the output as the **Value** of the secret variable
  * Below *az ad* command scopes the service principal to a specific resource group *{resource-group}* within a specific Azure subscription *{subscription-id}*
```bash  

   az ad sp create-for-rbac --name "myApp" --role contributor \
                            --scopes /subscriptions/{subscription-id}/resourceGroups/{resource-group} \
                            --sdk-auth
                            
  # Replace {subscription-id}, {resource-group} with the subscription, resource group details

  # The command should output a JSON object similar to this:

  {
    "clientId": "<GUID>",
    "clientSecret": "<GUID>",
    "subscriptionId": "<GUID>",
    "tenantId": "<GUID>",
    (...)
  }
  
```
 * You can also further scope down the Azure Credentials to a specific Azure resource, for example - a Web App by specifying the path to the specic resource in the *--scopes* attribute. Below script is for scoping the credentials to a web app of name *{app-name}*
```bash
   az ad sp create-for-rbac --name "myApp" --role contributor \
                            --scopes /subscriptions/{subscription-id}/resourceGroups/{resource-group}/providers/Microsoft.Web/sites/{app-name} \
                            --sdk-auth

  # Replace {subscription-id}, {resource-group}, and {app-name} with the names of your subscription, resource group, and Azure Web App.
```
  * Now in the workflow file in your branch: `.github/workflows/workflow.yml` replace the secret in Azure login action with your secret (Refer to the example above)
  
