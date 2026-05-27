output "storage_account_name" {
  value = azurerm_storage_account.main.name
}

output "storage_account_id" {
  value = azurerm_storage_account.main.id
}

output "blob_container_name" {
  value = azurerm_storage_container.main.name
}

output "file_share_name" {
  value = azurerm_storage_share.main.name
}

output "primary_blob_endpoint" {
  value = azurerm_storage_account.main.primary_blob_endpoint
}