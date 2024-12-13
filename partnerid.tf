# Get Azure AD tenant details
data "azuread_client_config" "current" {}

# Get service principal details
data "azuread_service_principal" "sp" {
  display_name = var.service_principal_name
}

# Create or update Partner Admin Link
resource "azapi_resource" "partner_admin_link" {
  type      = "Microsoft.ManagementPartner/partners@2018-02-01"
  name      = var.partner_id
  parent_id = "/"

  body = {
    tenantId = data.azuread_client_config.current.tenant_id
    objectId = data.azuread_service_principal.sp.object_id
    partnerId = var.partner_id
  }
}

# Outputs
output "service_principal_details" {
  value = {
    display_name = data.azuread_service_principal.sp.display_name
    object_id    = data.azuread_service_principal.sp.object_id
  }
  description = "Details of the service principal"
}

output "partner_id" {
  value = var.partner_id
  description = "The configured Partner ID (MPN ID)"
}

output "tenant_id" {
  value = data.azuread_client_config.current.tenant_id
  description = "The current tenant ID"
}