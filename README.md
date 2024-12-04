# Azure Container Apps with Open WebUI and Pipeline

This repository contains Terraform configurations for deploying Azure Container Apps with VNet integration. The infrastructure includes two containerized applications: Open WebUI and a Pipeline service.

## Architecture

### Network Configuration
- **Virtual Network**: 10.0.0.0/16
  - Apps Subnet: 10.0.0.0/23 (Container Apps)
  - Infrastructure Subnet: 10.0.2.0/23 (Future use)

### Components
- Resource Group
- Virtual Network with dedicated subnets
- Log Analytics Workspace
- Container Apps Environment
- Two Container Apps:
  - Open WebUI (External access)
  - Pipeline (Internal service)

## Prerequisites

- Azure Subscription
- Terraform >= 1.0
- Azure CLI
- Proper Azure permissions (Contributor or higher)

## Quick Start

1. **Clone the repository**
   ```bash
   git clone https://github.com/brosowskid/terraform-azure-container-apps.git
   cd terraform-azure-container-apps
   ```

2. **Initialize Terraform**
   ```bash
   terraform init
   ```

3. **Configure Variables**
   ```bash
   cp terraform.tfvars.example terraform.tfvars
   # Edit terraform.tfvars with your values
   ```

4. **Deploy Infrastructure**
   ```bash
   terraform plan
   terraform apply
   ```

## Configuration

### Required Variables
- `project`: Project identifier
- `environment`: Environment name (dev, prod, etc.)
- `pipeline_image`: Container image for pipeline service

### Optional Variables
- `location`: Azure region (default: West Europe)
- `location_short`: Short region identifier (default: weu)
- `tags`: Resource tags

## Resource Naming Convention

| Resource Type | Naming Pattern | Example |
|--------------|----------------|----------|
| Resource Group | rg-{project}-{env}-{location} | rg-demo-dev-weu |
| VNet | vnet-{project}-{env}-{location} | vnet-demo-dev-weu |
| Subnet | snet-{type}-{project}-{env}-{location} | snet-apps-demo-dev-weu |
| Container Apps Env | cae-{project}-{env}-{location} | cae-demo-dev-weu |
| Container App | ca-{name}-{project}-{env}-{location} | ca-webui-demo-dev-weu |

## Security

- All resources are deployed within a VNet
- Container Apps Environment uses dedicated subnet
- Network isolation between components
- Log Analytics for monitoring and auditing

## Outputs

- Resource Group name
- WebUI FQDN
- Container Apps Environment name

## Contributing

1. Fork the repository
2. Create feature branch
3. Commit changes
4. Create pull request

## License

This project is licensed under the MIT License - see the LICENSE file for details

## Support

For issues and feature requests, please create an issue in the repository.