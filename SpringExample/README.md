# Java-Example-App

This workflow can be used as an example for developers wanting to deploy Java apps using Github actions.

# The workflow:
This example workflow will:
   1. Create a k8's cluster on AKS 
   2. Build your applications image
   3. Create and push your image to ACR (Azure Container Registry 
   4. Pull your image from ACR, and deploy your application on AKS 

Workflows are defined in a `.yaml` file. The workflow file can be named anything, but it _must_ be inside a directory `./.github/workflows/`

# Using variables and secrets in your `.yaml` workflow
You can define secrets and variables by navigating to your github repository's `settings` page. You can define a new secrets variables by selecting "New Repository Secret"
Once you define your secrets, you can reference them with the syntax `${{ secrets.VARIABLE_NAME }}`

You can now pass these values as arguments to your workflow actions, without having to define them in plain text. To use this workflow, make sure to define the required secrets in your Github repository.
If you do not currently have the values needed to run this example, they can be created by running the script `./setup.sh -c <<cluster name> -g <<resource group name>> -s <<subscription id>> -r <<region>>
`. The script will output the values needed. You can define these as secrets and pass them
as arguments like seen below:

```yaml
   steps:
    - uses: actions/checkout@v2
    - uses: gambtho/aks_create_action@main
    with:
      CLUSTER_NAME: ${{ secrets.CLUSTER_NAME }}
      RESOURCE_GROUP_NAME: ${{ secrets.RESOURCE_GROUP_NAME }}
      STORAGE_ACCOUNT_NAME: ${{ secrets.STORAGE_ACCOUNT_NAME }}
      STORAGE_CONTAINER_NAME: ${{ secrets.STORAGE_CONTAINER_NAME }}
      STORAGE_ACCESS_KEY: ${{ secrets.STORAGE_ACCESS_KEY }}
      ARM_CLIENT_ID: ${{ secrets.ARM_CLIENT_ID }}
      ARM_CLIENT_SECRET: ${{ secrets.ARM_CLIENT_SECRET }}
      ARM_SUBSCRIPTION_ID: ${{ secrets.ARM_SUBSCRIPTION_ID }}
      ARM_TENANT_ID: ${{ secrets.ARM_TENANT_ID }}
      CREATE_ACR: true
```

# aks-set-context
This example workflow leverages the `aks-set-context` action, which requires the use of azure credentials.
The purpose of this action is to set cluster context before other actions like `azure/k8s-deploy`, `azure/k8s-create-secret` or any kubectl commands (in script) that can be run subsequently in the workflow.

To generate the  credentials needed for this action
run the following command, and copy the output into your Github actions secret variables:

`az ad sp create-for-rbac --sdk-auth`

```yaml
uses: azure/aks-set-context@v1
    with:
    creds: '${{ secrets.AZURE_CREDENTIALS }}' # Azure credentials
    resource-group: '<resource group name>'
    cluster-name: '<cluster name>'
```


az ad sp create-for-rbac --sdk-auth


# Defining your deployment
You will define your k8's deployment in a yaml file, as you would other kubernetes deployments. For more details on Kubernetes deployments,
see https://kubernetes.io/docs/tutorials/kubernetes-basics/deploy-app/deploy-intro/ 

The file path of your deployment will be passed as a `manifests` argument to the following `azure/k8s-deploy@v1` action. In the example the path is `k8/deployment.yaml`. Be sure to update this
if your pathname differs. 

```yaml
- uses: azure/k8s-deploy@v1
    with:
      manifests: |
        k8s/deployment.yaml
      images: |
        ${{ secrets.CLUSTER_NAME }}.azurecr.io/${{ secrets.APP_NAME }}:${{ github.sha }}
      imagepullsecrets: |
        ${{ secrets.SECRET_NAME }}
      namespace: ${{ secrets.NAMESPACE }}

```





