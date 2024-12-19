variable "environment" {}
variable "resource_prefix" {}

# App registration for function authentication
resource "azuread_application_registration" "function_auth" {
  display_name                       = "${var.resource_prefix}-funcauth-${var.environment}"
  implicit_id_token_issuance_enabled = true
  requested_access_token_version     = 2
}

resource "azuread_service_principal" "function_auth" {
  client_id = azuread_application_registration.function_auth.client_id
}

resource "time_rotating" "sp_function_auth_rotation" {
  rotation_days = 30
}

resource "azuread_service_principal_password" "function_auth" {
  service_principal_id = azuread_service_principal.function_auth.object_id
  display_name         = "${var.resource_prefix}-funcauth-secret-${var.environment}"
  rotate_when_changed = {
    rotation = time_rotating.sp_function_auth_rotation.id
  }
}

resource "azuread_application_identifier_uri" "function_api_uri" {
  application_id = azuread_application_registration.function_auth.id
  identifier_uri = "api://${azuread_application_registration.function_auth.client_id}"
}

# App registration for app service authentication

resource "azuread_application_registration" "app_auth" {
  display_name                       = "${var.resource_prefix}-auth-${var.environment}"
  implicit_id_token_issuance_enabled = true
  requested_access_token_version     = 2
}

resource "azuread_service_principal" "app_auth" {
  client_id = azuread_application_registration.app_auth.client_id
}

resource "time_rotating" "sp_app_auth_rotation" {
  rotation_days = 30
}

resource "azuread_service_principal_password" "app_auth" {
  service_principal_id = azuread_service_principal.app_auth.object_id
  display_name         = "${var.resource_prefix}-auth-secret-${var.environment}"
  rotate_when_changed = {
    rotation = time_rotating.sp_app_auth_rotation.id
  }
}

# Grant permission to the function app service principal
resource "azuread_service_principal_delegated_permission_grant" "app_auth_function" {
  service_principal_object_id          = azuread_service_principal.app_auth.object_id
  resource_service_principal_object_id = azuread_service_principal.function_auth.object_id
  claim_values                         = ["user_impersonation"]
}

resource "azuread_service_principal_delegated_permission_grant" "function_auth_app" {
  service_principal_object_id          = azuread_service_principal.function_auth.object_id
  resource_service_principal_object_id = azuread_service_principal.app_auth.object_id
  claim_values                         = ["user_impersonation"]
}

output "function_sp_client_id" {
  value = azuread_service_principal.function_auth.client_id
}
output "function_sp_secret_display_name" {
  value = azuread_service_principal_password.function_auth.display_name
}
output "app_sp_client_id" {
  value = azuread_service_principal.app_auth.client_id
}
output "app_sp_secret_display_name" {
  value = azuread_service_principal_password.app_auth.display_name
}
output "app_registration_app_id" {
  value = azuread_application_registration.app_auth.id
}
output "app_registration_function_id" {
  value = azuread_application_registration.function_auth.id
}
output "app_registration_app_client_id" {
  value = azuread_application_registration.app_auth.client_id
}
output "app_registration_function_app_id" {
  value = azuread_application_registration.function_auth.client_id
}
