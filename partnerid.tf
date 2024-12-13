# Variables
variable "partner_id" {
  type        = string
  description = "The Microsoft Partner Network ID (MPN ID)"
default = "564945"
}

variable "service_principal_name" {
  type        = string
  description = "The display name of the service principal to link"
  default = "tfc-deployment-sp"
}

# Data source to get the service principal details
data "azuread_service_principal" "sp" {
  display_name = var.service_principal_name
}

# Get Azure AD access token using the provider's authentication
data "azurerm_client_config" "current" {}

# Check Partner Admin Link status
resource "null_resource" "check_pal" {
  triggers = {
    partner_id = var.partner_id
  }

  provisioner "local-exec" {
    command = "az rest --method GET --uri 'https://management.azure.com/providers/microsoft.managementpartner/partners/${var.partner_id}?api-version=2018-02-01' --output json > pal_status.json || echo '{\"error\": {\"code\": \"NotFound\"}}' > pal_status.json"
    environment = {
      AZURE_CLIENT_ID       = coalesce(data.azurerm_client_config.current.client_id, "")
      AZURE_TENANT_ID       = coalesce(data.azurerm_client_config.current.tenant_id, "")
      AZURE_SUBSCRIPTION_ID = coalesce(data.azurerm_client_config.current.subscription_id, "")
    }
  }
}

# Create/Update Partner Admin Link
resource "null_resource" "partner_admin_link" {
  depends_on = [null_resource.check_pal]

  triggers = {
    service_principal_id = data.azuread_service_principal.sp.id
    partner_id          = var.partner_id
  }

  provisioner "local-exec" {
    command = <<-EOT
      az rest --method PUT \
        --uri "https://management.azure.com/providers/microsoft.managementpartner/partners/${var.partner_id}?api-version=2018-02-01" \
        --body '{"partnerId": "${var.partner_id}"}' \
        --output json > pal_result.json
    EOT
    
    environment = {
      AZURE_CLIENT_ID       = coalesce(data.azurerm_client_config.current.client_id, "")
      AZURE_TENANT_ID       = coalesce(data.azurerm_client_config.current.tenant_id, "")
      AZURE_SUBSCRIPTION_ID = coalesce(data.azurerm_client_config.current.subscription_id, "")
    }
  }
}

# Outputs
output "service_principal_id" {
  value = data.azuread_service_principal.sp.id
}

output "partner_id" {
  value = var.partner_id
}

locals {
  pal_status = fileexists("pal_status.json") ? jsondecode(file("pal_status.json")) : null
  pal_result = fileexists("pal_result.json") ? jsondecode(file("pal_result.json")) : null
}

output "pal_status" {
  value = local.pal_status
  description = "Current status of the Partner Admin Link configuration"
}

output "pal_result" {
  value = local.pal_result
  description = "Result of the Partner Admin Link configuration"
}