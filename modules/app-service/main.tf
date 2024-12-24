variable "environment" {}
variable "location" {}
variable "dap_acr_id" {}
variable "dap_acr_registry_url" {}
variable "docker_image" {}
variable "resource_prefix" {}
variable "tenant_id" {}
variable "function_app_url" {}
variable "app_sp_client_id" {}
variable "app_sp_secret_display_name" {}
variable "function_sp_client_id" {}
variable "app_registration_app_id" {}
variable "app_registration_function_app_id" {}

# App service resources
resource "azurerm_resource_group" "frontend_rg" {
  name     = "${var.resource_prefix}-${var.environment}-rg"
  location = var.location
}
resource "azurerm_user_assigned_identity" "dap_alpha_assigned_identity" {
  name                = "${var.resource_prefix}-${var.environment}-ai"
  resource_group_name = azurerm_resource_group.frontend_rg.name
  location            = azurerm_resource_group.frontend_rg.location
}

resource "azurerm_service_plan" "dap_alpha_service_plan" {
  name                = "${var.resource_prefix}-${var.environment}-service-plan"
  resource_group_name = azurerm_resource_group.frontend_rg.name
  location            = azurerm_resource_group.frontend_rg.location
  os_type             = "Linux"
  sku_name            = "B2"
}


resource "azurerm_linux_web_app" "dap-alpha-app" {
  name                = "${var.resource_prefix}-${var.environment}-app"
  resource_group_name = azurerm_resource_group.frontend_rg.name
  location            = var.location
  service_plan_id     = azurerm_service_plan.dap_alpha_service_plan.id

  site_config {
    always_on                               = false
    container_registry_use_managed_identity = true
    application_stack {
      docker_image_name   = var.docker_image
      docker_registry_url = "https://${var.dap_acr_registry_url}"
    }
  }
  identity {
    type         = "SystemAssigned, UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.dap_alpha_assigned_identity.id]
  }
  app_settings = {
    "CONTAINER_PORT"    = 80
    "FUNCTION_BASE_URL" = var.function_app_url
  }
  auth_settings_v2 {
    auth_enabled           = true
    require_authentication = true
    default_provider       = "azureactivedirectory"
    active_directory_v2 {
      client_id                  = var.app_sp_client_id
      tenant_auth_endpoint       = "https://login.microsoftonline.com/${var.tenant_id}/v2.0/"
      client_secret_setting_name = var.app_sp_secret_display_name
      login_parameters = {
        "scope" = "openid offline_access api://${var.app_registration_function_app_id}/user_impersonation"
      }
    }
    login {
      token_store_enabled = true
    }
  }
}

resource "azuread_application_redirect_uris" "app_dap_alpha_auth_redirect_uris" {
  application_id = var.app_registration_app_id
  type           = "Web"
  redirect_uris = [
    "https://${azurerm_linux_web_app.dap-alpha-app.default_hostname}/.auth/login/aad/callback"
  ]
}

resource "azurerm_role_assignment" "webapp_scheduling_acr_pull" {
  scope                            = var.dap_acr_id
  role_definition_name             = "AcrPull"
  principal_id                     = azurerm_linux_web_app.dap-alpha-app.identity[0].principal_id
  skip_service_principal_aad_check = false
}
