variable "project" {
  description = "Project name used for resource naming"
  type        = string
  default     = "partnerid"
}

variable "environment" {
  description = "Environment name (e.g., dev, prod, stage)"
  type        = string
  default     = "dev"
}

variable "location" {
  description = "Azure region where resources will be created"
  type        = string
  default     = "West Europe"
}

variable "location_short" {
  description = "Short form of Azure region for resource naming (e.g., weu)"
  type        = string
  default     = "weu"
}

# variable "tags" {
#   description = "Tags to apply to all resources"
#   type        = map(string)
#   default     = {}
# }

# variable "pipeline_image" {
#   description = "Docker image for the pipeline container"
#   type        = string
# }

# # Network configuration
# variable "vnet_address_space" {
#   description = "Address space for the virtual network"
#   type        = string
#   default     = "10.0.0.0/16"
# }

# variable "apps_subnet_prefix" {
#   description = "Address prefix for the apps subnet"
#   type        = string
#   default     = "10.0.0.0/23"
# }

# variable "infrastructure_subnet_prefix" {
#   description = "Address prefix for the infrastructure subnet"
#   type        = string
#   default     = "10.0.2.0/23"
# }

# # Container Apps configuration
# variable "webui_cpu" {
#   description = "CPU cores for WebUI container"
#   type        = number
#   default     = 1.0
# }

# variable "webui_memory" {
#   description = "Memory for WebUI container"
#   type        = string
#   default     = "2Gi"
# }

# variable "webui_port" {
#   description = "Port for WebUI container"
#   type        = number
#   default     = 8080
# }

# variable "pipeline_cpu" {
#   description = "CPU cores for Pipeline container"
#   type        = number
#   default     = 1.0
# }

# variable "pipeline_memory" {
#   description = "Memory for Pipeline container"
#   type        = string
#   default     = "2Gi"
# }

# # Log Analytics configuration
# variable "log_retention_days" {
#   description = "Number of days to retain logs"
#   type        = number
#   default     = 30
# }

# variable "log_analytics_sku" {
#   description = "SKU for Log Analytics Workspace"
#   type        = string
#   default     = "PerGB2018"
# }


variable "tfc_azure_dynamic_credentials" {
  description = "Object containing Azure dynamic credentials configuration"
  type = object({
    default = object({
      client_id_file_path  = string
      oidc_token_file_path = string
    })
  })
  ephemeral = true
}

provider "azurerm" {
  features {}
  // use_cli should be set to false to yield more accurate error messages on auth failure.
  use_cli = false
  // use_oidc must be explicitly set to true when using multiple configurations.
  use_oidc             = true
  client_id_file_path  = var.tfc_azure_dynamic_credentials.default.client_id_file_path
  oidc_token_file_path = var.tfc_azure_dynamic_credentials.default.oidc_token_file_path
}