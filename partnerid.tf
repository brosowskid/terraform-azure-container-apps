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

# Get service principal details
data "azuread_service_principal" "sp" {
  display_name = var.service_principal_name
}

# Create or update Partner Admin Link
resource "azapi_resource" "partner_admin_link" {
  type      = "Microsoft.ManagementPartner/partners@2018-02-01"
  name      = var.partner_id
  parent_id = "/"  # Root level as it's a tenant-wide resource

  body = jsonencode({
    partnerId = var.partner_id
  })
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