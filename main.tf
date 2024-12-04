# Azure Provider configuration
provider "azurerm" {
  features {}
}

# Resource Group
resource "azurerm_resource_group" "rg" {
  name     = "rg-${var.project}-${var.environment}-${var.location_short}"
  location = var.location
  tags     = var.tags
}

# Virtual Network
resource "azurerm_virtual_network" "vnet" {
  name                = "vnet-${var.project}-${var.environment}-${var.location_short}"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  address_space       = ["10.0.0.0/16"]
  tags                = var.tags
}

# Subnet for Container Apps Environment
resource "azurerm_subnet" "apps" {
  name                 = "snet-apps-${var.project}-${var.environment}-${var.location_short}"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.0.0/23"]

  delegation {
    name = "container-apps"
    service_delegation {
      name    = "Microsoft.App/environments"
      actions = ["Microsoft.Network/virtualNetworks/subnets/join/action"]
    }
  }
}

# Infrastructure Subnet (for potential future use)
resource "azurerm_subnet" "infrastructure" {
  name                 = "snet-infra-${var.project}-${var.environment}-${var.location_short}"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.2.0/23"]
}

# Log Analytics Workspace
resource "azurerm_log_analytics_workspace" "law" {
  name                = "law-${var.project}-${var.environment}-${var.location_short}"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
  tags                = var.tags
}

# Container Apps Environment
resource "azurerm_container_app_environment" "env" {
  name                           = "cae-${var.project}-${var.environment}-${var.location_short}"
  location                       = azurerm_resource_group.rg.location
  resource_group_name           = azurerm_resource_group.rg.name
  log_analytics_workspace_id    = azurerm_log_analytics_workspace.law.id
  infrastructure_subnet_id      = azurerm_subnet.apps.id
  internal_load_balancer_enabled = false
  tags                          = var.tags
}

# Open WebUI Container App
resource "azurerm_container_app" "webui" {
  name                         = "ca-webui-${var.project}-${var.environment}-${var.location_short}"
  container_app_environment_id = azurerm_container_app_environment.env.id
  resource_group_name         = azurerm_resource_group.rg.name
  revision_mode               = "Single"

  template {
    container {
      name   = "open-webui"
      image  = "open-webui/open-webui:latest"
      cpu    = 1.0
      memory = "2Gi"
    }
  }

  ingress {
    external_enabled = true
    target_port     = 8080
    traffic_weight {
      percentage      = 100
      latest_revision = true
    }
  }

  tags = var.tags
}

# Pipeline Container App
resource "azurerm_container_app" "pipeline" {
  name                         = "ca-pipeline-${var.project}-${var.environment}-${var.location_short}"
  container_app_environment_id = azurerm_container_app_environment.env.id
  resource_group_name         = azurerm_resource_group.rg.name
  revision_mode               = "Single"

  template {
    container {
      name   = "pipeline"
      image  = var.pipeline_image
      cpu    = 1.0
      memory = "2Gi"
    }
  }

  tags = var.tags
}