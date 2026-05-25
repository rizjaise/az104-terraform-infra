#Public IP for Load Balancer
resource "azurerm_public_ip" "lb" {
   name                = "pip-lb-specter"
   location            = var.location
   resource_group_name = var.resource_group_name
   allocation_method   = "Static"
   sku                 = "Standard"
}

#Load Balancer
resource "azurerm_lb" "main" {
    name                = "lb-specter"
    location            =  var.location
    resource_group_name = var.resource_group_name
    sku                 = "Standard"

    frontend_ip_configuration {
        name                 = "lb-specter-fe"
        public_ip_address_id = azurerm_public_ip.lb.id
    }
}

#Backend Address Pool
resource "azurerm_lb_backend_address_pool" "main" {
    name                = "backend-pool-specter"
    loadbalancer_id     = azurerm_lb.main.id
}

#Health Probe
resource "azurerm_lb_probe" "main" {
    name                = "http-probe-specter"
    loadbalancer_id     = azurerm_lb.main.id
    protocol            = "Http"
    port                = 80
    request_path        = "/"
}

#Load Balancer Rule
resource "azurerm_lb_rule" "main" {
    loadbalancer_id         = azurerm_lb.main.id
    name                    = "http-rule-specter"
    protocol                = "Tcp"
    frontend_port           = 80
    backend_port            = 80
    frontend_ip_configuration_name = "lb-specter-fe"
    backend_address_pool_ids = [azurerm_lb_backend_address_pool.main.id]
    probe_id                = azurerm_lb_probe.main.id
}

#Availability Set
resource "azurerm_availability_set" "main" {
    name                = "avset-specter"
    location            = var.location
    resource_group_name = var.resource_group_name
    platform_fault_domain_count  = 2
    platform_update_domain_count = 5
}

#Network Interface
resource "azurerm_network_interface" "vm" {
  count               = 2
  name                = "nic-vm-${count.index}"
  location            = var.location
  resource_group_name = var.resource_group_name

  ip_configuration {
    name                          = "ipconfig-specter"
    subnet_id                     = var.subnet_web_id
    private_ip_address_allocation = "Dynamic"
  }
}

#Associate Network Interface with Backend Pool
resource "azurerm_network_interface_backend_address_pool_association" "main" {
  count                   = 2
  network_interface_id    = azurerm_network_interface.vm[count.index].id
  ip_configuration_name   = "ipconfig-specter"
  backend_address_pool_id = azurerm_lb_backend_address_pool.main.id
}

#Virtual Machine
resource "azurerm_windows_virtual_machine" "vm" {
    count               = 2
    name                = "vm-specter-${count.index}"
    location            = var.location
    resource_group_name = var.resource_group_name
    size                = "Standard_B2ts_v2"
    admin_username      = var.vm_admin_username
    admin_password      = var.vm_admin_password
    availability_set_id = azurerm_availability_set.main.id

    network_interface_ids = [
        azurerm_network_interface.vm[count.index].id
    ]

    os_disk {
        caching              = "ReadWrite"
        storage_account_type = "Standard_LRS"
    }

    source_image_reference {
        publisher = "MicrosoftWindowsServer"
        offer     = "WindowsServer"
        sku       = "2022-Datacenter"
        version   = "latest"
    }
}