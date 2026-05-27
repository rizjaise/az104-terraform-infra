# Get current subscription details
data "azurerm_subscription" "main" {}

# Get existing users from Entra Id
data "azuread_user" "hspecter" {
  user_principal_name = var.hspecter_upn
}

data "azuread_user" "mross" {
  user_principal_name = var.mross_upn
}

# Contributor role assignment - Hspecter on resource group
resource "azurerm_role_assignment" "hspecter_contributor" {
  scope                = var.resource_group_id
  role_definition_name = "Contributor"
  principal_id         = data.azuread_user.hspecter.object_id
}

# Reader role assignment - MRoss on resource group
resource "azurerm_role_assignment" "mross_reader" {
  scope                = var.resource_group_id
  role_definition_name = "Reader"
  principal_id         = data.azuread_user.mross.object_id
}

# Custome role - limited VM operator
resource "azurerm_role_definition" "vm_operator" {
    name = "VM Operator Specter"
    scope = data.azurerm_subscription.main.id
    description = "Can start, stop and restart VMs but cannot create or delete them"

    permissions {
        actions = [
            "Microsoft.Compute/virtualMachines/start/action",
            "Microsoft.Compute/virtualMachines/deallocate/action",
            "Microsoft.Compute/virtualMachines/restart/action",
            "Microsoft.Compute/virtualMachines/read",
            "Microsoft.Resources/subscriptions/resourceGroups/read",
        ]
        not_actions = []
        }

    assignable_scopes = [
        data.azurerm_subscription.main.id
    ]
}

# Assign custom VM Operator role to Hspecter
resource "azurerm_role_assignment" "hspecter_vm_operator" {
  scope                = var.resource_group_id
  role_definition_id   = azurerm_role_definition.vm_operator.role_definition_resource_id
  principal_id         = data.azuread_user.hspecter.object_id
}

# Azure Policy - enforce tagging
resource "azurerm_policy_definition" "require_tags" {
    name = "require-tags-specter"
    policy_type = "Custom"
    mode ="Indexed"
    display_name = "Require Tags and Owner Tags"

    policy_rule = <<POLICY
    {
      "if": {
        "anyOf": [
          {
            "field": "tags['environment']",
            "exists": "false"
          },
          {
            "field": "tags['owner']",
            "exists": "false"
          }
        ]
      },
      "then": {
        "effect": "audit"
      }
    }
    POLICY
}

# Assign tagging policy to resource group
resource "azurerm_resource_group_policy_assignment" "require_tags" {
    name = "assign-require-tags"
    resource_group_id = var.resource_group_id
    policy_definition_id = azurerm_policy_definition.require_tags.id
}

# Azure Policy - restrict location
resource "azurerm_policy_definition" "allowed_locations" {
  name         = "allowed-locations-specter"
  policy_type  = "Custom"
  mode         = "Indexed"
  display_name = "Allow East US location only"

  policy_rule = <<POLICY
{
  "if": {
    "not": {
      "field": "location",
      "in": "[parameters('allowedLocations')]"
    }
  },
  "then": {
    "effect": "deny"
  }
}
POLICY

parameters = <<PARAMS
{
  "allowedLocations": {
    "type": "Array",
    "metadata": {
      "displayName": "Allowed locations",
      "strongType": "location"
    }
  }
}
PARAMS
}

# Assign location policy to resource group
resource "azurerm_resource_group_policy_assignment" "allowed_locations" {
  name                 = "assign-allowed-locations"
  resource_group_id    = var.resource_group_id
  policy_definition_id = azurerm_policy_definition.allowed_locations.id

  parameters = <<PARAMS
{
  "allowedLocations": {
    "value": ["eastus"]
  }
}
PARAMS
}

# Resource lock on storage account
resource "azurerm_management_lock" "storage" {
  name       = "lock-storage-specter"
  scope      = var.storage_account_id
  lock_level = "ReadOnly"
  notes      = "Protect storage account from accidental deletion or modification"
}