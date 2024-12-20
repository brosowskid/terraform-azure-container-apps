# Variables
variable "partner_id" {
  type        = string
  description = "The Microsoft Partner Network ID (MPN ID)"
  default     = "714306"
}

variable "service_principal_name" {
  type        = string
  description = "The display name of the service principal to link"
  default     = "tfc-deployment-sp"
}

variable "service_principal_name1" {
  type        = string
  description = "The display name of the service principal to link"
  default     = "tfm-deployment-sp"
}

variable "service_principal_name2" {
  type        = string
  description = "The display name of the service principal to link"
  default     = "jenkins-oidc"
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
      version = "~> 2.0"
    }
  }
}