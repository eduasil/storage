terraform {
  required_version = ">= 1.13.4"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
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

# Resource Group
resource "azurerm_resource_group" "rg" {
  name     = "rg-storage-test"
  location = "eastus"
}

# Storage Account
resource "azurerm_storage_account" "storage" {
  name                     = "stteststorage01"
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = azurerm_resource_group.rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

# Container público — vai violar a policy
resource "azurerm_storage_container" "public_container" {
  name                  = "public-container"
  storage_account_name  = azurerm_storage_account.storage.name
  container_access_type = "blob" # 🔥 policy deve bloquear
}