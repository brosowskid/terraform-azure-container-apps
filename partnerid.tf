# Get Azure AD tenant details
data "azuread_client_config" "current" {}

# Get service principal details
data "azuread_service_principal" "sp" {
  display_name = var.service_principal_name
}

locals {
  # Safely check if PAL exists and get its status
  pal_exists = can(data.azapi_resource.check_pal[0].id)
  pal_status = try(data.azapi_resource.check_pal[0].output, null)
  needs_update = !local.pal_exists
}

# Check Partner Admin Link status
data "azapi_resource" "check_pal" {
  count     = 1
  type      = "Microsoft.ManagementPartner/partners@2018-02-01"
  name      = var.partner_id
  parent_id = "/"
  response_export_values = ["*"]
}

# Create or update Partner Admin Link
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

output "pal_exists" {
  value = local.pal_exists
  description = "Whether the Partner Admin Link exists"
}

output "pal_status" {
  value = local.pal_status
  description = "Current Partner Admin Link status (null if it doesn't exist)"
}

output "needs_update" {
  value = local.needs_update
  description = "Whether the PAL needs to be created or updated"
}