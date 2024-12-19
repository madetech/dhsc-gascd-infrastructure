variable "resource_prefix" {}
variable "resource_group_name" {}
variable "location" {}
variable "environment" {}

# define cognitive account
resource "azurerm_cognitive_account" "openai" {
  name                = "${var.resource_prefix}-openai-model-${var.environment}"
  location            = var.location
  resource_group_name = var.resource_group_name
  kind                = "OpenAI"
  sku_name            = "S0"
}

# define deployment of gpt4o model
resource "azurerm_cognitive_deployment" "gpt_4o" {
  name = "${var.resource_prefix}-GPT-4o-${var.environment}"
  cognitive_account_id = azurerm_cognitive_account.openai.id
  model {
    format  = "OpenAI"
    name    = "gpt-4o"
    version = "2024-05-13"
  }
  sku {
    name = "GlobalStandard"
    capacity = 10
  }

}

# returning the key for the model 
output "openai_key" {
  value = azurerm_cognitive_account.openai.primary_access_key
}

# returning the model endpoint
output "openai_endpoint" {
  value = azurerm_cognitive_account.openai.endpoint
}