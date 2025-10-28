# 🔹 Virtual Network e Subnet para Private Endpoint
resource "azurerm_virtual_network" "vnet" {
  name                = "vnet-storage"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  address_space       = ["192.168.3.0/24"]
}

resource "azurerm_subnet" "private_endpoint_subnet" {
  name                 = "snet-private-endpoint"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["192.168.3.0/24"]

  service_endpoints = ["Microsoft.Storage"]
  depends_on = [
    azurerm_private_endpoint.storage_pe
  ]
}

# 🔹 Private DNS Zone
resource "azurerm_private_dns_zone" "storage_dns" {
  name                = "privatelink.blob.core.windows.net"
  resource_group_name = azurerm_resource_group.rg.name
  depends_on = [
    azurerm_private_endpoint.storage_pe
  ]

}

# 🔹 Link da VNet à zona DNS privada
resource "azurerm_private_dns_zone_virtual_network_link" "dns_link" {
  name                  = "storage-dns-link"
  resource_group_name   = azurerm_resource_group.rg.name
  private_dns_zone_name = azurerm_private_dns_zone.storage_dns.name
  virtual_network_id    = azurerm_virtual_network.vnet.id
  registration_enabled  = false
  depends_on = [
    azurerm_private_dns_zone.storage_dns,
    azurerm_virtual_network.vnet
  ]
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
  depends_on = [
    azurerm_storage_account.storage,
    azurerm_subnet.private_endpoint_subnet,
    azurerm_private_dns_zone_virtual_network_link.dns_link
  ]
}

resource "azurerm_virtual_network_peering" "storage_to_servidores" {
  name                         = "storage-to-servidores"
  resource_group_name          = azurerm_resource_group.rg.name
  virtual_network_name         = azurerm_virtual_network.vnet.name
  remote_virtual_network_id    = data.azurerm_virtual_network.net_server.id
  allow_forwarded_traffic      = true
  allow_gateway_transit        = false
  use_remote_gateways          = false
  allow_virtual_network_access = true

  depends_on = [
    azurerm_virtual_network.vnet
  ]
}

# Peering da existente para a nova
resource "azurerm_virtual_network_peering" "servidores_to_storage" {
  name                         = "servidores_to_storage"
  resource_group_name          = "RG-INFRA"
  virtual_network_name         = data.azurerm_virtual_network.net_server.name
  remote_virtual_network_id    = azurerm_virtual_network.vnet.id
  allow_forwarded_traffic      = true
  allow_gateway_transit        = false
  use_remote_gateways          = false
  allow_virtual_network_access = true

  depends_on = [
    azurerm_virtual_network.vnet
  ]
}