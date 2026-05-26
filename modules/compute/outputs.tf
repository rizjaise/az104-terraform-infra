output "lb_public_ip" {
    value = azurerm_public_ip.lb.ip_address
}

output "vm_names" {
    value = azurerm_windows_virtual_machine.vm[*].name
}

output "app_service_name" {
    value = azurerm_linux_web_app.main.name
}

output "app_service_url" {
    value = "https://${azurerm_linux_web_app.main.default_hostname}"
}

output "managed_identity_id" {
    value = azurerm_user_assigned_identity.main.id
}

output "managed_identity_client_id" {
    value = azurerm_user_assigned_identity.main.client_id
}