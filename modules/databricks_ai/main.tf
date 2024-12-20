variable "environment" {}
variable "resource_prefix" {}
variable "resource_group_name" {}
variable "workspace_url" {}
variable "azure_msi_flag" {}
variable "workspace_id" {}
variable "storage_account_name" {} # Alpha lake
variable "string_value" {}         # Alpha lake
variable "drop_storage_account_name" {}
variable "drop_primary_access_key" {}
variable "bronze_storage_account_name" {}
variable "bronze_primary_access_key" {}
variable "silver_storage_account_name" {}
variable "silver_primary_access_key" {}
variable "gold_storage_account_name" {}
variable "gold_primary_access_key" {}
variable "spark_version" {}
variable "spark_version_gpu" {}

terraform {
  required_providers {
    databricks = {
      source  = "databricks/databricks"
      version = "1.38.0"
    }
  }
}

provider "databricks" {
  host                        = var.workspace_url
  azure_workspace_resource_id = var.workspace_id
  azure_use_msi               = var.azure_msi_flag
}

resource "databricks_secret_scope" "dbx_secret_scope" {
  name = "infrascope"
}

# Alpha lake
resource "databricks_secret" "dbx_secret_datalake" {
  scope        = databricks_secret_scope.dbx_secret_scope.name
  key          = "datalake_access_key"
  string_value = var.string_value
}

# Drop storage account
resource "databricks_secret" "dbx_secret_drop_datalake" {
  scope        = databricks_secret_scope.dbx_secret_scope.name
  key          = "drop_datalake_access_key"
  string_value = var.drop_primary_access_key
}

# Bronze storage account
resource "databricks_secret" "dbx_secret_bronze_datalake" {
  scope        = databricks_secret_scope.dbx_secret_scope.name
  key          = "bronze_datalake_access_key"
  string_value = var.bronze_primary_access_key
}

# Silver storage account
resource "databricks_secret" "dbx_secret_silver_datalake" {
  scope        = databricks_secret_scope.dbx_secret_scope.name
  key          = "silver_datalake_access_key"
  string_value = var.silver_primary_access_key
}

# Gold storage account
resource "databricks_secret" "dbx_secret_gold_datalake" {
  scope        = databricks_secret_scope.dbx_secret_scope.name
  key          = "gold_datalake_access_key"
  string_value = var.gold_primary_access_key
}

# AI cluster
resource "databricks_cluster" "dbx_ai_cpu_cluster" {
  cluster_name            = "${var.resource_prefix}-dbx-ai-cpu-cluster-${var.environment}"
  spark_version           = var.spark_version
  node_type_id            = "Standard_DS3_v2"
  driver_node_type_id     = "Standard_DS3_v2"
  enable_elastic_disk     = true
  autotermination_minutes = 60
  is_pinned               = true
  autoscale {
    min_workers = 1
    max_workers = 3
  }
  spark_conf = {
    format("%s.%s.%s", "fs.azure.account.key", var.storage_account_name, "dfs.core.windows.net")        = "{{secrets/infrascope/datalake_access_key}}" # Alpha lake
    format("%s.%s.%s", "fs.azure.account.key", var.drop_storage_account_name, "dfs.core.windows.net")   = "{{secrets/infrascope/drop_datalake_access_key}}"
    format("%s.%s.%s", "fs.azure.account.key", var.bronze_storage_account_name, "dfs.core.windows.net") = "{{secrets/infrascope/bronze_datalake_access_key}}"
    format("%s.%s.%s", "fs.azure.account.key", var.silver_storage_account_name, "dfs.core.windows.net") = "{{secrets/infrascope/silver_datalake_access_key}}"
    format("%s.%s.%s", "fs.azure.account.key", var.gold_storage_account_name, "dfs.core.windows.net")   = "{{secrets/infrascope/gold_datalake_access_key}}"
  }
  spark_env_vars = {
    "ENV" = var.environment
  }
  depends_on = [
    databricks_secret.dbx_secret_bronze_datalake, databricks_secret.dbx_secret_drop_datalake,
    databricks_secret.dbx_secret_silver_datalake, databricks_secret.dbx_secret_gold_datalake,
  databricks_secret.dbx_secret_datalake, databricks_secret.dbx_secret_drop_datalake]
}

#data "databricks_spark_version" "gpu_ml" {
#  gpu = true
#  ml  = true
#}
#
#resource "databricks_cluster" "dbx_ai_gpu_cluster" {
#  cluster_name            = "${var.resource_prefix}-dbx-ai-gpu-cluster-${var.environment}"
#  spark_version           = var.spark_version_gpu # Ensure compatibility with ML workloads
#  node_type_id            = "Standard_NC12s_v3"   # GPU-enabled node type, adjust based on GPU needs currently is 2 V100 GPUs
#  driver_node_type_id     = "Standard_NC12s_v3"   # This will need be changed later to run with databricks_node_type instead
#  enable_elastic_disk     = true
#  autotermination_minutes = 60 # Adjust to allow longer inference jobs
#  is_pinned               = true
#  autoscale {
#    min_workers = 1
#    max_workers = 3
#  }
#  spark_conf = {
#    format("%s.%s.%s", "fs.azure.account.key", var.storage_account_name, "dfs.core.windows.net")        = "{{secrets/infrascope/datalake_access_key}}"
#    format("%s.%s.%s", "fs.azure.account.key", var.drop_storage_account_name, "dfs.core.windows.net")   = "{{secrets/infrascope/drop_datalake_access_key}}"
#    format("%s.%s.%s", "fs.azure.account.key", var.bronze_storage_account_name, "dfs.core.windows.net") = "{{secrets/infrascope/bronze_datalake_access_key}}"
#    format("%s.%s.%s", "fs.azure.account.key", var.silver_storage_account_name, "dfs.core.windows.net") = "{{secrets/infrascope/silver_datalake_access_key}}"
#    format("%s.%s.%s", "fs.azure.account.key", var.gold_storage_account_name, "dfs.core.windows.net")   = "{{secrets/infrascope/gold_datalake_access_key}}"
#  } # Might need to add init_scripts here in theory cluster should come preloaded with dependencies
#  depends_on = [
#    databricks_secret.dbx_secret_bronze_datalake, databricks_secret.dbx_secret_drop_datalake,
#    databricks_secret.dbx_secret_silver_datalake, databricks_secret.dbx_secret_gold_datalake,
#  databricks_secret.dbx_secret_datalake, databricks_secret.dbx_secret_drop_datalake]
#}

resource "databricks_directory" "AIModel" {
  path = "/AImodels_notebooks"
}
