#App Service Plan

resource "azurerm_service_plan" "main" {
    name                = "asp-specter"
    location            = var.location
    resource_group_name = var.resource_group_name
    os_type             = "Linux"
    sku_name            = "B1"
}

#user assigned identity for app service
resource "azurerm_user_assigned_identity" "main" {
    name                = "id-specter-appservice"
    location            = var.location
    resource_group_name = var.resource_group_name
}

#App Service
resource "azurerm_linux_web_app" "main" {
    name                = "app-specter-${random_string.suffix.result}"
    location            = var.location
    resource_group_name = var.resource_group_name
    service_plan_id     = azurerm_service_plan.main.id

    identity {
        type = "UserAssigned"
        identity_ids = [azurerm_user_assigned_identity.main.id]
    }

    site_config {
        always_on = false
    }
}

#Random Suffix to ensure globally unique app name
resource "random_string" "suffix"{
    length  = 6
    upper   = false
    special = false
}