data "azurerm_virtual_network" "net_server" {
  name                = "net_server"
  resource_group_name = "RG-INFRA"
}