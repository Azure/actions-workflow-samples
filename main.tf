# Resource group for shared infra
resource "azurerm_resource_group" "rg" {
  name     = "testresourcegroup"
  location = "eastus"
}
