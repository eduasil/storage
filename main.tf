# Resource Group
resource "azurerm_resource_group" "rg" {
  name     = var.resource_group_name
  location = var.location
}

# Storage Account
resource "azurerm_storage_account" "storage" {
  name                     = var.storage_account_name
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = azurerm_resource_group.rg.location
  account_tier             = var.account_tier
  account_replication_type = var.account_replication_type

}

resource "azurerm_storage_container" "public_container" {
  name                  = "publiccontainer"
  storage_account_name  = azurerm_storage_account.storage.name
  container_access_type = "blob"
}