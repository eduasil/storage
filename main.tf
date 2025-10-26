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

  tags = {
    environment = "Terraform Demo"
  }
}

# Storage Container privado
resource "azurerm_storage_container" "private_blob" {
  name                  = "listasalarios"
  storage_account_name  = azurerm_storage_account.storage.name
  container_access_type = "private"
}

# Data source para pegar o workspace existente
data "azurerm_log_analytics_workspace" "la" {
  name                = "la-defender-for-cloud"
  resource_group_name = "rg-logs"
}

resource "azurerm_monitor_diagnostic_setting" "storage_diag" {
  name                       = "${azurerm_storage_account.storage.name}-diag"
  target_resource_id         = azurerm_storage_account.storage.id
  log_analytics_workspace_id = data.azurerm_log_analytics_workspace.la.id



  metric {
    category = "AllMetrics"
    enabled  = true
    retention_policy { enabled = false }
  }
}
