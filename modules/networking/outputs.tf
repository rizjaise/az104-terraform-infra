output "vnet_id" {
  value = azurerm_virtual_network.main.id
}

output "subnet_web_id" {
  value = azurerm_subnet.web.id
}

output "subnet_app_id" {
  value = azurerm_subnet.app.id
}

output "subnet_data_id" {
  value = azurerm_subnet.data.id
}