variable "resource_group_name" {
  type    = string
  default = "testresourcegroup"
}

variable "location" {
  type    = string
  default = "eastus"
}

variable "agent_client_id" {
  type = string
}

variable "agent_client_secret" {
  type = string
}

variable "subscription_id" {
  type = string
}

variable "tenant_id" {
  type = string
}
