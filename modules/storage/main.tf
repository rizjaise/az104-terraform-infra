#Storage Account
resource "azurerm_storage_account" "main" {
    name                     = "spectersa-dev"
    resource_group_name      = var.resource_group_name
    location                 = var.location
    account_tier             = "Standard"
    account_replication_type = "LRS"
    min_tls_version         = "TLS1_2"

    blob_properties {
        versioning_enabled = true

        delete_retention_policy {
            days = 7
        }

        container_delete_retention_policy {
            days = 7
        }
    }
}

#Blob Container
resource "azurerm_storage_container" "main" {
    name                  = "blob-specter"
    storage_account_name  = azurerm_storage_account.main.name
    container_access_type = "private"
}

#Azure File Share
resource "azurerm_storage_share" "main" {
    name                 = "fileshare-specter"
    storage_account_name = azurerm_storage_account.main.name
    quota                = 5
}

#Lifecycle Management Policy
resource "azurerm_storage_management_policy" "main" {
    storage_account_id = azurerm_storage_account.main.id

    rule {
        name  = "move-to-cool"
        enabled = true

        filters {
            prefix_match = ["blob-specter/"]
            blob_types  = ["blockBlob"]
        }

        actions {
            base_blob {
                tier_to_cool_after_days_since_modification_greater_than = 30
                tier_to_archive_after_days_since_modification_greater_than = 90
                delete_after_days_since_modification_greater_than = 365
            }

            snapshot {
                delete_after_days_since_creation_greater_than = 30
            }
        }
    }
}