# Action Samples for deploying using Terraform

With Terraform workflows, you can automate your terraform templates to deploy to Azure.

Terraform templates use Azure Resource Manager to deploy resources to Azure. More details on Terraform Provider for Azure can be found [here](https://www.terraform.io/docs/providers/azurerm/index.html).

## Configure Azure credentials

To fetch the credentials required to authenticate with Azure, run the following command:

```sh
az ad sp create-for-rbac --name "myApp" --role contributor \
                            --scopes /subscriptions/{subscription-id}/resourceGroups/{resource-group} \
                            --sdk-auth

  # Replace {subscription-id}, {resource-group} with the subscription, resource group details

  # The command should output a JSON object similar to the example below

  {
    "clientId": "<GUID>",
    "clientSecret": "<GUID>",
    "subscriptionId": "<GUID>",
    "tenantId": "<GUID>",
    (...)
  }
```

Add the JSON output as secrets TF_VAR_agent_client_id, TF_VAR_agent_client_secret, TF_VAR_subscription_id, TF_VAR_tenant_id in the GitHub repository. For steps to create and storing secrets, please check [here](https://docs.github.com/en/actions/configuring-and-managing-workflows/creating-and-storing-encrypted-secrets)

The terraform deployment actions expects the terraform templates to be stored in the root directory. If the terraform templates are stored in a different directory, update the path to terraform actions. More information on terraform actions can be found [here](https://www.terraform.io/docs/github-actions/setup-terraform.html)

For additional help on how use Azure actions, please refer [here](https://github.com/Azure/Actions)

## Terraform Sample Templates

For additional terraform sample templates for Azure deployment, please refer to these [quick-start templates](https://github.com/Azure/terraform/tree/master/quickstart)

## GitHub Action Workflows

For more samples to get started with GitHub Action workflows to deploy to Azure refer [here](https://github.com/Azure/actions-workflow-samples)
