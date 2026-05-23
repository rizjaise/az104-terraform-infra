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
    address_prefixes     = ["10.0.2.0/24"]
  }
      
resource "azurerm_subnet" "data" {
      name                 = "SpecterSubnetData-Dev"
      resource_group_name  = var.resource_group_name
      virtual_network_name = azurerm_virtual_network.main.name
      address_prefixes     = ["10.0.3.0/24"]
  }

#NSG - Web
resource "azurerm_network_security_group" "web" {
    name                = "SpecterNSGWeb-Dev"
    location            = var.location
    resource_group_name = var.resource_group_name
  
security_rule {
    name                      = "allow-internet-inbound"
    priority                  = 100
    direction                 = "Inbound"
    access                    = "Allow"
    protocol                  = "Tcp"
    source_port_range         = "*"
    destination_port_range    = ["80", "443"]
    source_address_prefix     = "internet"
    destination_address_prefix = "*"
  }

security_rule {
    name                      = "deny-all-inbound"
    priority                  = 4096
    direction                 = "Inbound"
    access                    = "Deny"
    protocol                  = "*"
    source_port_range         = "*"
    destination_port_range    = "*"
    source_address_prefix     = "*"
    destination_address_prefix = "*"
  }
}

#NSG - App
resource "azurerm_network_security_group" "app" {
    name                = "SpecterNSGApp-Dev"
    location            = var.location
    resource_group_name = var.resource_group_name
  
  security_rule {
    name                      = "allow-app-inbound"
    priority                  = 100
    direction                 = "Inbound"
    access                    = "Allow"
    protocol                  = "Tcp"
    source_port_range         = "*"
    destination_port_range    = "*"
    source_address_prefix     = "10.0.1.0/24"
    destination_address_prefix = "*"
  }

  security_rule {
    name                      = "deny-internet-inbound"
    priority                  = 200
    direction                 = "Inbound"
    access                    = "Deny"
    protocol                  = "*"
    source_port_range         = "*"
    destination_port_range    = "*"
    source_address_prefix     = "Internet"
    destination_address_prefix = "*"
  }

  security_rule {
    name                      = "deny-data-inbound"
    priority                  = 300
    direction                 = "Inbound"
    access                    = "Deny"
    protocol                  = "*"
    source_port_range         = "*"
    destination_port_range    = "*"
    source_address_prefix     = "10.0.3.0/24"
    destination_address_prefix = "*"
  }
}

#NSG - Data
resource "azurerm_network_security_group" "data" {
    name                = "SpecterNSGData-Dev"
    location            = var.location
    resource_group_name = var.resource_group_name
  
  security_rule {
    name                      = "allow-app-inbound"
    priority                  = 100
    direction                 = "Inbound"
    access                    = "Allow"
    protocol                  = "Tcp"
    source_port_range         = "*"
    destination_port_range    = "*"
    source_address_prefix     = "10.0.2.0/24"
    destination_address_prefix = "*"
  }

  security_rule {
    name                      = "deny-all-inbound"
    priority                  = 200
    direction                 = "Inbound"
    access                    = "Deny"
    protocol                  = "*"
    source_port_range         = "*"
    destination_port_range    = "*"
    source_address_prefix     = "*"
    destination_address_prefix = "*"
  }
}

#Associate NSG with Subnets
resource "azurerm_subnet_network_security_group_association" "web" {
    subnet_id                 = azurerm_subnet.web.id
    network_security_group_id = azurerm_network_security_group.web.id
}

resource "azurerm_subnet_network_security_group_association" "app" {
    subnet_id                 = azurerm_subnet.app.id
    network_security_group_id = azurerm_network_security_group.app.id
}

resource "azurerm_subnet_network_security_group_association" "data" {
    subnet_id                 = azurerm_subnet.data.id
    network_security_group_id = azurerm_network_security_group.data.id
}


