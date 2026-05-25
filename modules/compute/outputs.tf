output "lb_public_ip" {
    value = azurerm_public_ip.lb.ip_address
}

output "vm_names" {
    value = azurerm_windows_virtual_machine.vm[*].name
}