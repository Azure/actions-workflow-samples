provider "azurerm" {
  version = "~> 1.44.0"

  tenant_id       = var.tenant_id
  subscription_id = var.subscription_id
  client_id       = var.agent_client_id
  client_secret   = var.agent_client_secret
}
