# Get Azure AD tenant details
data "azuread_client_config" "current" {}

# Get service principal details
data "azuread_service_principal" "sp" {
  display_name = var.service_principal_name
}

data "azuread_service_principal" "sp1" {
  display_name = var.service_principal_name1
}

data "azuread_service_principal" "sp2" {
  display_name = var.service_principal_name2
}

# Create or update Partner Admin Link
resource "azapi_update_resource" "partner_admin_link" {
  type                      = "Microsoft.ManagementPartner/partners@2018-02-01"
  name                      = var.partner_id
  parent_id                 = "/"

  # # Use ignore_changes to prevent Terraform from trying to update an existing PAL
  lifecycle {
    ignore_changes = [
      body
    ]
  }

    body = {      # Added jsonencode to ensure proper JSON formatting
    partnerId = var.partner_id
    tenantId  = data.azuread_client_config.current.tenant_id
    objectId  = data.azuread_service_principal.sp.object_id
    state     = "Active"   # Added explicit state property from API schema
  }
}

# Create or update Partner Admin Link
resource "azapi_update_resource" "partner_admin_link1" {
  type                      = "Microsoft.ManagementPartner/partners@2018-02-01"
  name                      = var.partner_id
  parent_id                 = "/"

  # # Use ignore_changes to prevent Terraform from trying to update an existing PAL
  lifecycle {
    ignore_changes = [
      body
    ]
  }

    body = {      # Added jsonencode to ensure proper JSON formatting
    partnerId = var.partner_id
    tenantId  = data.azuread_client_config.current.tenant_id
    objectId  = data.azuread_service_principal.sp1.object_id
    state     = "Active"   # Added explicit state property from API schema
  }
}

resource "azapi_update_resource" "partner_admin_link2" {
  type                      = "Microsoft.ManagementPartner/partners@2018-02-01"
  name                      = var.partner_id
  parent_id                 = "/"

  # # Use ignore_changes to prevent Terraform from trying to update an existing PAL
  lifecycle {
    ignore_changes = [
      body
    ]
  }

    body = {      # Added jsonencode to ensure proper JSON formatting
    partnerId = var.partner_id
    tenantId  = data.azuread_client_config.current.tenant_id
    objectId  = data.azuread_service_principal.sp2.object_id
    state     = "Active"   # Added explicit state property from API schema
  }
}

# # Outputs
# output "service_principal_details" {
#   value = {
#     display_name = data.azuread_service_principal.sp.display_name
#     object_id    = data.azuread_service_principal.sp.object_id
#   }
#   description = "Details of the service principal"
# }

# output "partner_id" {
#   value       = var.partner_id
#   description = "The configured Partner ID (MPN ID)"
# }

# output "tenant_id" {
#   value       = data.azuread_client_config.current.tenant_id
#   description = "The current tenant ID"
# }

# output "pal_configuration_status" {
#   value = {
#     is_configured     = can(azapi_resource.partner_admin_link.id)
#     service_principal = data.azuread_service_principal.sp.display_name
#     mpn_id            = var.partner_id
#   }
#   description = "Configuration status of Partner Admin Link"
# }