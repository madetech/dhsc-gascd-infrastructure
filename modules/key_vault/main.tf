variable "environment" {}
variable "resource_prefix" {}
variable "resource_group_name" {}
variable "location" {}
variable "tenant_id" {}
variable "adf_object_id" {}

resource "azuread_group" "secret_readers" {
  display_name     = format("%s - %s", "GASCD Beta - Secret readers", upper(var.environment))
  security_enabled = true
}

resource "azuread_group" "kv_admins" {
  display_name     = format("%s - %s", "GASCD Beta - Key vault admin", upper(var.environment))
  security_enabled = true
}

resource "azuread_group_member" "adf_secret_read" {
  group_object_id  = azuread_group.secret_readers.object_id
  member_object_id = var.adf_object_id
}

resource "azurerm_key_vault" "key_vault" {
  name                      = "${var.resource_prefix}-kv-${var.environment}"
  location                  = var.location
  resource_group_name       = var.resource_group_name
  tenant_id                 = var.tenant_id
  sku_name                  = "standard"
  purge_protection_enabled  = false
  enable_rbac_authorization = true
}


resource "azurerm_role_assignment" "kv_admins" {
  scope                = azurerm_key_vault.key_vault.id
  role_definition_name = "Key Vault Administrator"
  principal_id         = azuread_group.kv_admins.object_id
}

resource "azurerm_role_assignment" "kv_secret_readers" {
  scope                = azurerm_key_vault.key_vault.id
  role_definition_name = "Key Vault Secrets User"
  principal_id         = azuread_group.secret_readers.object_id
}
