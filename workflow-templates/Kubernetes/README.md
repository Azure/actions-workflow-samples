# Deploy to Kubernetes using GitHub Actions

We have released multiple actions to help you connect to a Kubernetes cluster running on-premises or on any cloud (including Azure Kubernetes Service – AKS), bake and deploy manifests, substitute artifacts, check rollout status, and handle secrets within the cluster. 
-	[Kubectl tool installer](https://github.com/Azure/setup-kubectl)(`azure/setup-kubectl`): Installs a specific version of kubectl on the runner.
-	[Kubernetes set context](https://github.com/Azure/k8s-set-context)(`azure/k8s-set-context`): Used for setting the target Kubernetes cluster context which will be used by other actions or run any kubectl commands.
-	[AKS set context](https://github.com/Azure/aks-set-context)(`azure/aks-set-context`): Used for setting the target Azure Kubernetes Service cluster context .
-	[Kubernetes create secret](https://github.com/Azure/k8s-create-secret)(`azure/k8s-create-secret`): Create a generic secret or docker-registry secret in the Kubernetes cluster.
-	[Kubernetes deploy](https://github.com/Azure/k8s-deploy)(`azure/ k8s-deploy`): Use this to bake and deploy manifests to Kubernetes clusters.
-	[Setup Helm](https://github.com/Azure/setup-helm)(`azure/setup-helm`): Install a specific version of Helm binary on the runner.
-	[Kubernetes bake](https://github.com/Azure/k8s-bake)(`azure/k8s-bake`): Use this action to bake manifest file to be used for deployments using helm2, kustomize or kompose.

# Action Samples for deploying to to Kubernetes 

Refer to [starter templates](https://github.com/Azure/actions-workflow-samples/tree/master/Kubernetes) to easily get started:
- [Deploy to AKS using Manifest files](https://github.com/Azure/actions-workflow-samples/blob/master/Kubernetes/build-and-deploy-docker-image-aks-using-manifests.yml) to build & a container image to ACR (Azure Container Registry) and deploy to AKS.
- [Deploy to AKS using Helm](https://github.com/Azure/actions-workflow-samples/blob/master/Kubernetes/build-and-deploy-docker-image-to-aks-using-helm.yml) to build & a container image to ACR (Azure Container Registry) and deploy to AKS.

The workflows contain primarily the below sections:

|  Section | Actions |
|------------|---------|
| Authentication     | Login to a private container registry (ACR) | 
| Build       | Build & push the container image | 
| Deploy | Set the target cluster context ; Create a generic/docker-registry secret in Kubernetes cluster ; Deploy to the Kubernetes cluster| 

# Build & Push container images
For containerized apps (single- or multi-containers) to create a complete workflow 
- use [Docker login](https://github.com/Azure/docker-login)(`azure/docker-login`) for authentication
And then run docker commands to build container images, push to the container registry (Docker Hub or Azure Container Registry) and then deploy the images to a Azure Web App or Azure Function for Containers, or to Kubernetes. 

# Deploy to Azure Kubernetes Service (AKS)

To deploy to a cluster on Azure Kubernetes Service, you could use [`azure/aks-set-context`](https://github.com/Azure/aks-set-context/) to communicate with the AKS cluster using Azure credentials, 
and then use `azure/k8s-create-secret` to create a pull image secret and finally use the `azure/k8s-deploy` to deploy the manifest files. 

## Configure Azure credentials:

To fetch the credentials required to authenticate with Azure, run the following command:

```sh
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
Add the json output as [a secret](https://developer.github.com/actions/managing-workflows/storing-secrets/) (let's say with the name `AZURE_CREDENTIALS`) in the GitHub repository. 


# Deploy to any Kubernetes cluster (On-Prem/ Any cloud)
To connect to a cluster on any Kubernetes cluster, you could use [`azure/k8s-set-context`](https://github.com/Azure/k8s-set-context/); 
and then use [`azure/k8s-create-secret`](https://github.com/Azure/k8s-create-secret/tree/master) or [`azure/k8s-deploy`](https://github.com/Azure/k8s-deploy/tree/master), or run any kubectl commands.

Use secret (https://developer.github.com/actions/managing-workflows/storing-secrets/) in workflow for kubeconfig or k8s-values.

PS: `kubeconfig` takes precedence (i.e. kubeconfig would be created using the value supplied in kubeconfig)

## Steps to get Kubeconfig of a K8s cluster: 

### For AKS
```sh
az aks get-credentials --name
                       --resource-group
                       [--admin]
                       [--file]
                       [--overwrite-existing]
                       [--subscription]
```
Refer to https://docs.microsoft.com/en-us/cli/azure/aks?view=azure-cli-latest#az-aks-get-credentials

### For any K8s cluster
Please refer to https://kubernetes.io/docs/concepts/configuration/organize-cluster-access-kubeconfig/


## Steps to get Service account: 

#### k8s-url: Run in your local shell to get server K8s URL
```sh
kubectl config view --minify -o jsonpath={.clusters[0].cluster.server}
```
#### k8s-secret: Run following sequential commands to get the secret value:
Get service account secret names by running
```sh
kubectl get sa <service-account-name> -n <namespace> -o=jsonpath={.secrets[*].name}
```

Use the output of the above command 
```sh
kubectl get secret <service-account-secret-name> -n <namespace> -o json
```
## Using secret for Kubeconfig or Service Account
Now add the values as [a secret](https://developer.github.com/actions/managing-workflows/storing-secrets/) in the GitHub repository. In the example below the secret name is `KUBE_CONFIG` and it can be used in the workflow by using the following syntax:
```yaml
 - uses: azure/k8s-set-context@v1
      with:
        kubeconfig: ${{ secrets.KUBE_CONFIG }}
```
