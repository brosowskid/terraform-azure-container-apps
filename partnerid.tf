# Get Azure AD tenant details
data "azuread_client_config" "current" {}

# Get service principal details
data "azuread_service_principal" "sp" {
  display_name = var.service_principal_name
}

# Create or update Partner Admin Link
resource "azapi_resource" "partner_admin_link" {
  type                      = "Microsoft.ManagementPartner/partners@2018-02-01"
  name                      = var.partner_id
  parent_id                 = "/"
  schema_validation_enabled = false

  # Use ignore_changes to prevent Terraform from trying to update an existing PAL
  lifecycle {
    ignore_changes = [
      body
    ]
  }

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

# output "pal_status" {
#   value = azapi_resource.partner_admin_link.output
#   description = "Current Partner Admin Link status"
# }

output "pal_status" {
  value = try({
    raw_output = jsondecode(azapi_resource.partner_admin_link.output)
    properties = try(jsondecode(azapi_resource.partner_admin_link.output).properties, {})
    state = try(jsondecode(azapi_resource.partner_admin_link.output).properties.state, "Unknown")
    partner_name = try(jsondecode(azapi_resource.partner_admin_link.output).properties.partnerName, "Unknown")
    created_time = try(jsondecode(azapi_resource.partner_admin_link.output).properties.createdTime, "Unknown")
    updated_time = try(jsondecode(azapi_resource.partner_admin_link.output).properties.updatedTime, "Unknown")
    version = try(jsondecode(azapi_resource.partner_admin_link.output).properties.version, "Unknown")
    resource_id = azapi_resource.partner_admin_link.id
    etag = azapi_resource.partner_admin_link.etag
    type = azapi_resource.partner_admin_link.type
  }, {})
  description = "Detailed Partner Admin Link status"
}

output "pal_configuration_status" {
  value = {
    is_configured = can(azapi_resource.partner_admin_link.id)
    last_updated = timestamp()
    service_principal = data.azuread_service_principal.sp.display_name
    mpn_id = var.partner_id
  }
  description = "Configuration status of Partner Admin Link"
}