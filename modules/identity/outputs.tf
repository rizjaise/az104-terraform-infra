output "vm_operator_role_id" {
  value = azurerm_role_definition.vm_operator.role_definition_resource_id
}

output "hspecter_contributor_assignment_id" {
  value = azurerm_role_assignment.hspecter_contributor.id
}

output "mross_reader_assignment_id" {
  value = azurerm_role_assignment.mross_reader.id
}