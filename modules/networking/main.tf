#Vnet 1
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
    destination_port_ranges    = ["80", "443"]
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

#Vnet 2
resource "azurerm_virtual_network" "secondary" {
    name                = "SpecterVNetSecondary-Dev"
    location            = var.location
    resource_group_name = var.resource_group_name
    address_space       = ["192.168.0.0/16"]
}

resource "azurerm_subnet" "secondary" {
    name                 = "SpecterSubnetSecondary-Dev"
    resource_group_name  = var.resource_group_name
    virtual_network_name = azurerm_virtual_network.secondary.name
    address_prefixes     = ["192.168.1.0/24"]
}

#Peering Primary to Secondary
resource "azurerm_virtual_network_peering" "primary_to_secondary" {
    name                      = "peer-primary-to-secondary"
    resource_group_name       = var.resource_group_name
    virtual_network_name      = azurerm_virtual_network.main.name
    remote_virtual_network_id = azurerm_virtual_network.secondary.id
    allow_forwarded_traffic   = true
    allow_gateway_transit     = false
    use_remote_gateways       = false
}

#Peering Secondary to Primary
resource "azurerm_virtual_network_peering" "secondary_to_primary" {
    name                      = "peer-secondary-to-primary"
    resource_group_name       = var.resource_group_name
    virtual_network_name      = azurerm_virtual_network.secondary.name
    remote_virtual_network_id = azurerm_virtual_network.main.id
    allow_forwarded_traffic   = true
    allow_gateway_transit     = false
    use_remote_gateways       = false
}

#Private DNS Zone
resource "azurerm_private_dns_zone" "main" {
  name = "specterdev.internal"
  resource_group_name = var.resource_group_name
}

#Link Private DNS Zone to Vnet 1
resource "azurerm_private_dns_zone_virtual_network_link" "primary" {
  name                  = "dns-link-primary"
  resource_group_name   = var.resource_group_name
  private_dns_zone_name = azurerm_private_dns_zone.main.name
  virtual_network_id    = azurerm_virtual_network.main.id
  registration_enabled = true
}

#Link Private DNS Zone to Vnet 2
resource "azurerm_private_dns_zone_virtual_network_link" "secondary" {
  name                  = "dns-link-secondary"
  resource_group_name   = var.resource_group_name
  private_dns_zone_name = azurerm_private_dns_zone.main.name
  virtual_network_id    = azurerm_virtual_network.secondary.id
  registration_enabled = false
}