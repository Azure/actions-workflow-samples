name: Multijob workflow to build and deploy Docker app to Azure

on: push

# CONFIGURATION
# For help, go to https://github.com/Azure/Actions
#
# Set up the following secrets in your repository:
#   AZURE_CREDENTIALS, REGISTRY_USERNAME, REGISTRY_PASSWORD, AZURE_DEVOPS_TOKEN
# 2. Change these variables for your configuration:
env:
  CONTAINER_REGISTRY: actionregistry.azurecr.io   # set this to Container Registry name

jobs:
  build-in-actions-workflow:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@master
              
   # Authentication
    - uses: azure/login@v1
      with:
        creds: ${{ secrets.AZURE_CREDENTIALS  }}
    - uses: azure/docker-login@v1
      with:
        login-server: ${{ env.CONTAINER_REGISTRY }}
        username: ${{ secrets.REGISTRY_USERNAME }}
        password: ${{ secrets.REGISTRY_PASSWORD }}
    
    # Build and push container
    - run: |
        docker build . -t ${{ env.CONTAINER_REGISTRY }}/nodejsapp:latest
        docker push ${{ env.CONTAINER_REGISTRY }}/nodejsapp:latest
       
    
  deploy-using-azure-pipelines:
    needs: build-in-actions-workflow
    runs-on: ubuntu-latest
    steps:
    - name: 'Trigger an Azure Pipeline to deploy the app to PRODUCTION'
      uses: Azure/pipelines@releases/v1
      with:
        azure-devops-project-url: 'https://dev.azure.com/OrganizationName/ProjectName'
        azure-pipeline-name: 'WebApp_Azure_Prod' 
        azure-devops-token: '${{ secrets.AZURE_DEVOPS_TOKEN }}'
