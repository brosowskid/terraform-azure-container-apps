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

# Check if Partner Admin Link exists
data "external" "check_pal" {
  program = ["bash", "-c", <<EOT
    ACCESS_TOKEN=$(curl -X POST -H "Content-Type: application/x-www-form-urlencoded" \
      -d "grant_type=client_credentials" \
      -d "client_id=$ARM_CLIENT_ID" \
      -d "client_assertion_type=urn:ietf:params:oauth:client-assertion-type:jwt-bearer" \
      -d "client_assertion=$ARM_CLIENT_JWT" \
      -d "scope=https://management.azure.com/.default" \
      "https://login.microsoftonline.com/$ARM_TENANT_ID/oauth2/v2.0/token" | jq -r .access_token)

    RESPONSE=$(curl -s -H "Authorization: Bearer $ACCESS_TOKEN" \
      "https://management.azure.com/providers/microsoft.managementpartner/partners/${var.partner_id}?api-version=2018-02-01")
    
    if echo "$RESPONSE" | grep -q "error"; then
      echo '{"exists": "false", "status": "not_found"}'
    else
      echo '{"exists": "true", "status": "'$(echo $RESPONSE | jq -r .state)'"}'
    fi
  EOT
  ]
}

# Partner Admin Link configuration using null_resource
resource "null_resource" "partner_admin_link" {
  # Only create/update if PAL doesn't exist or is not Active
  count = data.external.check_pal.result.exists == "false" || data.external.check_pal.result.status != "Active" ? 1 : 0

  triggers = {
    service_principal_id = data.azuread_service_principal.sp.id
    partner_id          = var.partner_id
    pal_status         = data.external.check_pal.result.status
  }

  provisioner "local-exec" {
    command = <<EOT
      ACCESS_TOKEN=$(curl -X POST -H "Content-Type: application/x-www-form-urlencoded" \
        -d "grant_type=client_credentials" \
        -d "client_id=$ARM_CLIENT_ID" \
        -d "client_assertion_type=urn:ietf:params:oauth:client-assertion-type:jwt-bearer" \
        -d "client_assertion=$ARM_CLIENT_JWT" \
        -d "scope=https://management.azure.com/.default" \
        "https://login.microsoftonline.com/$ARM_TENANT_ID/oauth2/v2.0/token" | jq -r .access_token)

      RESPONSE=$(curl -X PUT \
        -H "Authorization: Bearer $ACCESS_TOKEN" \
        -H "Content-Type: application/json" \
        -d '{"partnerId": "${var.partner_id}"}' \
        "https://management.azure.com/providers/microsoft.managementpartner/partners/${var.partner_id}?api-version=2018-02-01")
      
      if echo "$RESPONSE" | grep -q "error"; then
        echo "Failed to configure Partner Admin Link:"
        echo "$RESPONSE"
        exit 1
      fi
    EOT
  }
}

# Outputs
output "service_principal_id" {
  value = data.azuread_service_principal.sp.id
}

output "partner_id" {
  value = var.partner_id
}

output "pal_status" {
  value = data.external.check_pal.result
  description = "Current status of the Partner Admin Link configuration"
}