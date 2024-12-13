# Get Azure AD tenant details
data "azuread_client_config" "current" {}

# Get service principal details
data "azuread_service_principal" "sp" {
  display_name = var.service_principal_name
}

# Check Partner Admin Link status
data "azapi_resource" "check_pal" {
  type                   = "Microsoft.ManagementPartner/partners@2018-02-01"
  name                   = var.partner_id
  parent_id             = "/"
  response_export_values = ["*"]
}

locals {
  current_pal = try(data.azapi_resource.check_pal.output, null)
  is_pal_active = try(jsondecode(local.current_pal).properties.state == "Active", false)
  needs_update = !local.is_pal_active || (
    try(jsondecode(local.current_pal).properties.objectId, "") != data.azuread_service_principal.sp.object_id ||
    try(jsondecode(local.current_pal).properties.partnerId, "") != var.partner_id
  )
}

# Create or update Partner Admin Link only if needed
resource "azapi_resource" "partner_admin_link" {
  count                     = local.needs_update ? 1 : 0
  type                      = "Microsoft.ManagementPartner/partners@2018-02-01"
  name                      = var.partner_id
  parent_id                 = "/"
  schema_validation_enabled = false

  body = {
    tenantId  = data.azuread_client_config.current.tenant_id
    objectId  = data.azuread_service_principal.sp.object_id
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

output "pal_status" {
  value = try(jsondecode(data.azapi_resource.check_pal.output), {})
  description = "Current Partner Admin Link status"
}

output "needs_update" {
  value = local.needs_update
  description = "Indicates whether PAL needs to be created or updated"
}