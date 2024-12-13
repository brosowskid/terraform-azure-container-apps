# Variables
variable "partner_id" {
  type        = string
  description = "The Microsoft Partner Network ID (MPN ID)"
  default     = "564945"
}

variable "service_principal_name" {
  type        = string
  description = "The display name of the service principal to link"
  default     = "tfc-deployment-sp"
}

provider "azapi" {
}

# Provider configuration
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">=4.1.0"
    }
    azuread = {
      source  = "hashicorp/azuread"
      version = ">=2.0.0"
    }
    azapi = {
      source  = "Azure/azapi" # Corrected source path
      version = ">=1.5.0"
    }
  }
}