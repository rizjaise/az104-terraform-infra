resource "azurerm_virtual_network" "main" {
    name                = "SpecterVNet-Dev"
    location            = var.location
    resource_group_name = var.resource_group_name
    address_space       = ["10.0.0.0/16"]
  }

resource "azurerm_subnet" "web" {
    name                 = "SpecterSubnetWeb-Dev"
    resource_group_name  = var.resource_group_name
    virtual_network_name = azurerm_virtual_network.main.name
    address_prefixes     = ["10.0.1.0/24"]
  }

resource "azurerm_subnet" "app" {
    name                 = "SpecterSubnetApp-Dev"
    resource_group_name  = var.resource_group_name
    virtual_network_name = azurerm_virtual_network.main.name
    address_prefixes     = ["10.0.2.0/24 "]
    }
      
resource "azurerm_subnet" "data" {
      name                 = "SpecterSubnetData-Dev"
      resource_group_name  = var.resource_group_name
      virtual_network_name = azurerm_virtual_network.main.name
      address_prefixes     = ["10.0.3.0/24"]
    }