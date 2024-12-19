variable "environment" {}
variable "resource_prefix" {}
variable "resource_group_name" {}
variable "location" {}
variable "data_factory_identity_id" {}

# Create databricks workspace 
resource "azurerm_databricks_workspace" "dbx_workspace" {
  name                = "${var.resource_prefix}-dbx-ai-${var.environment}"
  resource_group_name = var.resource_group_name
  location            = var.location
  sku                 = "premium"
  custom_parameters {
    storage_account_name = "${var.resource_prefix}dbxaidbfs${var.environment}"
    no_public_ip = false
  }
}

resource "azurerm_role_assignment" "af_dbx_access" {
  scope                = azurerm_databricks_workspace.dbx_workspace.id
  role_definition_name = "Contributor"
  principal_id         = var.data_factory_identity_id
}


output "workspace_url" {
  value = azurerm_databricks_workspace.dbx_workspace.workspace_url
}

output "workspace_id" {
  value = azurerm_databricks_workspace.dbx_workspace.id
}
