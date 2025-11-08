# 🔹 Resource Group
resource "azurerm_resource_group" "rg" {
  name     = "RG-CNAPP"
  location = "eastus"
}

# 🔹 Storage Account
resource "azurerm_storage_account" "storage" {
  name                     = "stalmeidacnapp"
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = azurerm_resource_group.rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  min_tls_version          = "TLS1_2"

  depends_on = [
    azurerm_resource_group.rg
  ]
}

# 🔹 Container privado
resource "azurerm_storage_container" "private_container" {
  name                  = "private-container"
  storage_account_name  = azurerm_storage_account.storage.name
  container_access_type = "blob"

  depends_on = [
    azurerm_storage_account.storage
  ]
}