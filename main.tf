terraform {
  required_version = ">= 1.8.5"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.117.1"
    }
  }

  backend "remote" {
    organization = "almeidacorp"

    workspaces {
      name = "storage"
    }
  }
}

provider "azurerm" {
  features {}
}

# 🔹 Resource Group
resource "azurerm_resource_group" "rg" {
  name     = "RG-STORAGE-TEST"
  location = "eastus"
}

# 🔹 Virtual Network e Subnet para Private Endpoint
resource "azurerm_virtual_network" "vnet" {
  name                = "vnet-storage"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  address_space       = ["c"]
}

resource "azurerm_subnet" "private_endpoint_subnet" {
  name                 = "snet-private-endpoint"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["192.168.3.0/24"]

  # Necessário para Private Endpoints
  enforce_private_link_endpoint_network_policies = true
}

# 🔹 Storage Account
resource "azurerm_storage_account" "storage" {
  name                     = "stteststorage01"
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = azurerm_resource_group.rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  min_tls_version          = "TLS1_2"

  network_rules {
    default_action             = "Deny"
    bypass                     = ["AzureServices"]
    ip_rules                   = []
    virtual_network_subnet_ids = [azurerm_subnet.private_endpoint_subnet.id]
  }
}

# 🔹 Container privado
resource "azurerm_storage_container" "private_container" {
  name                  = "private-container"
  storage_account_name  = azurerm_storage_account.storage.name
  container_access_type = "private"
}

# 🔹 Private DNS Zone
resource "azurerm_private_dns_zone" "storage_dns" {
  name                = "privatelink.blob.core.windows.net"
  resource_group_name = azurerm_resource_group.rg.name
}

# 🔹 Link da VNet à zona DNS privada
resource "azurerm_private_dns_zone_virtual_network_link" "dns_link" {
  name                  = "storage-dns-link"
  resource_group_name   = azurerm_resource_group.rg.name
  private_dns_zone_name = azurerm_private_dns_zone.storage_dns.name
  virtual_network_id    = azurerm_virtual_network.vnet.id
  registration_enabled  = false
}

# 🔹 Private Endpoint com associação DNS (nova sintaxe)
resource "azurerm_private_endpoint" "storage_pe" {
  name                = "pe-storage"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  subnet_id           = azurerm_subnet.private_endpoint_subnet.id

  private_service_connection {
    name                           = "psc-storage"
    private_connection_resource_id = azurerm_storage_account.storage.id
    subresource_names              = ["blob"]
    is_manual_connection           = false
  }

  private_dns_zone_group {
    name                 = "storage-dns-zone-group"
    private_dns_zone_ids = [azurerm_private_dns_zone.storage_dns.id]
  }
}
