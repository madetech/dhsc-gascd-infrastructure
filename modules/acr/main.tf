variable "acr_rg" {
  type     = string
  nullable = false
}
variable "resource_prefix" {}
variable "environment" {}
variable "acr_location" {}

resource "azurerm_container_registry" "acr" {
  name                = "${var.resource_prefix}acr${var.environment}"
  resource_group_name = var.acr_rg
  location            = var.acr_location
  sku                 = "Basic"
  admin_enabled       = false
}

output "acr_id" {
  value = azurerm_container_registry.acr.id
}

output "registry_url" {
  value = azurerm_container_registry.acr.login_server
}
