variable "environment" {}
variable "resource_prefix" {}
variable "resource_group_name" {}
variable "location" {}
variable "data_factory_identity_id" {}

# Create drop storage account
resource "azurerm_storage_account" "drop_datalake" {
  name                     = "${var.resource_prefix}stdrop${var.environment}"
  resource_group_name      = var.resource_group_name
  location                 = var.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  is_hns_enabled           = true # This enables DataLake Gen2.
  allow_nested_items_to_be_public = false
}

# Create containers for the drop storage account 
resource "azurerm_storage_container" "datalake_drop_restricted" {
  name                 = "restricted"
  storage_account_name = azurerm_storage_account.drop_datalake.name
}

resource "azurerm_storage_container" "datalake_drop_unrestricted" {
  name                 = "unrestricted"
  storage_account_name = azurerm_storage_account.drop_datalake.name
}

# Let the Data Factory access the drop storage account
resource "azurerm_role_assignment" "drop_adf_lake_access" {
  scope                = azurerm_storage_account.drop_datalake.id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = var.data_factory_identity_id
}

# Create bronze storage account
resource "azurerm_storage_account" "bronze_datalake" {
  name                     = "${var.resource_prefix}stbronze${var.environment}"
  resource_group_name      = var.resource_group_name
  location                 = var.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  is_hns_enabled           = true # This enables DataLake Gen2.
  allow_nested_items_to_be_public = false
}

# Create containers for the bronze storage account
resource "azurerm_storage_container" "datalake_bronze_restricted" {
  name                 = "restricted"
  storage_account_name = azurerm_storage_account.bronze_datalake.name
}

resource "azurerm_storage_container" "datalake_bronze_unrestricted" {
  name                 = "unrestricted"
  storage_account_name = azurerm_storage_account.bronze_datalake.name
}

# Let the Data Factory access the bronze storage account
resource "azurerm_role_assignment" "bronze_adf_lake_access" {
  scope                = azurerm_storage_account.bronze_datalake.id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = var.data_factory_identity_id
}

# Create silver storage account
resource "azurerm_storage_account" "silver_datalake" {
  name                     = "${var.resource_prefix}stsilver${var.environment}"
  resource_group_name      = var.resource_group_name
  location                 = var.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  is_hns_enabled           = true # This enables DataLake Gen2.
  allow_nested_items_to_be_public = false
}

# Create containers for the silver storage account
resource "azurerm_storage_container" "datalake_silver_restricted" {
  name                 = "restricted"
  storage_account_name = azurerm_storage_account.silver_datalake.name
}

resource "azurerm_storage_container" "datalake_silver_unrestricted" {
  name                 = "unrestricted"
  storage_account_name = azurerm_storage_account.silver_datalake.name
}

# Let the Data Factory access the silver storage account
resource "azurerm_role_assignment" "silver_adf_lake_access" {
  scope                = azurerm_storage_account.silver_datalake.id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = var.data_factory_identity_id
}

# Create gold storage account
resource "azurerm_storage_account" "gold_datalake" {
  name                     = "${var.resource_prefix}stgold${var.environment}"
  resource_group_name      = var.resource_group_name
  location                 = var.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  is_hns_enabled           = true # This enables DataLake Gen2.
  allow_nested_items_to_be_public = false
}

# Create containers for the gold storage account
resource "azurerm_storage_container" "datalake_gold_restricted" {
  name                 = "restricted"
  storage_account_name = azurerm_storage_account.gold_datalake.name
}

resource "azurerm_storage_container" "datalake_gold_unrestricted" {
  name                 = "unrestricted"
  storage_account_name = azurerm_storage_account.gold_datalake.name
}

# Let the Data Factory access the gold storage account
resource "azurerm_role_assignment" "gold_adf_lake_access" {
  scope                = azurerm_storage_account.gold_datalake.id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = var.data_factory_identity_id
}

# Create platinum storage account
resource "azurerm_storage_account" "platinum_datalake" {
  name                     = "${var.resource_prefix}stplatinum${var.environment}"
  resource_group_name      = var.resource_group_name
  location                 = var.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  is_hns_enabled           = true # This enables DataLake Gen2.
  allow_nested_items_to_be_public = false
}

# Create containers for the platinum storage account
resource "azurerm_storage_container" "datalake_platinum_restricted" {
  name                 = "restricted"
  storage_account_name = azurerm_storage_account.platinum_datalake.name
}

resource "azurerm_storage_container" "datalake_platinum_unrestricted" {
  name                 = "unrestricted"
  storage_account_name = azurerm_storage_account.platinum_datalake.name
}

# Let the Data Factory access the platinum storage account
resource "azurerm_role_assignment" "platinum_adf_lake_access" {
  scope                = azurerm_storage_account.platinum_datalake.id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = var.data_factory_identity_id
}

output "drop_storage_account_name" {
  value = azurerm_storage_account.drop_datalake.name
}

output "drop_primary_access_key" {
  value = azurerm_storage_account.drop_datalake.primary_access_key
}

output "bronze_storage_account_name" {
  value = azurerm_storage_account.bronze_datalake.name
}

output "bronze_primary_access_key" {
  value = azurerm_storage_account.bronze_datalake.primary_access_key
}

output "silver_storage_account_name" {
  value = azurerm_storage_account.silver_datalake.name
}

output "silver_primary_access_key" {
  value = azurerm_storage_account.silver_datalake.primary_access_key
}

output "gold_storage_account_name" {
  value = azurerm_storage_account.gold_datalake.name
}

output "gold_primary_access_key" {
  value = azurerm_storage_account.gold_datalake.primary_access_key
}

output "platinum_storage_account_name" {
  value = azurerm_storage_account.platinum_datalake.name
}

output "platinum_primary_access_key" {
  value = azurerm_storage_account.platinum_datalake.primary_access_key
}