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

provider "azapi" {
}

# Provider configuration
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">=3.0.0"
    }
    azuread = {
      source  = "hashicorp/azuread"
      version = ">=2.0.0"
    }
    azapi = {
      source  = "Azure/azapi"  # Corrected source path
      version = ">=1.5.0"
    }
  }
}

# Data source to get the service principal details
data "azuread_service_principal" "sp" {
  display_name = var.service_principal_name
}

# Check if Partner Admin Link exists
data "azapi_resource" "check_pal" {
  type      = "microsoft.managementpartner/partners@2018-02-01"
  name      = var.partner_id
  parent_id = ""

  response_export_values = ["*"]
}

# Create or update Partner Admin Link
resource "azapi_resource" "partner_admin_link" {
  type      = "microsoft.managementpartner/partners@2018-02-01"
  name      = var.partner_id
  parent_id = ""

  body = jsonencode({
    properties = {
      objectId = data.azuread_service_principal.sp.id
      partnerId = var.partner_id
      tenantId = data.azuread_service_principal.sp.application_tenant_id
    }
  })
}

# Outputs
output "service_principal_id" {
  value = data.azuread_service_principal.sp.id
}

output "partner_id" {
  value = var.partner_id
}

output "pal_status" {
  value = {
    exists = can(data.azapi_resource.check_pal.id)
    state  = can(data.azapi_resource.check_pal.id) ? jsondecode(data.azapi_resource.check_pal.output).state : "NotFound"
  }
  description = "Current status of the Partner Admin Link configuration"
}

output "pal_result" {
  value = jsondecode(azapi_resource.partner_admin_link.output)
  description = "Result of the Partner Admin Link configuration"
}