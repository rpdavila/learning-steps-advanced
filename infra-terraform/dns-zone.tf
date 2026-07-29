resource "azurerm_private_dns_zone" "PDNSZ" {
  name                = "private.postgres.database.azure.com"
  resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_private_dns_zone_virtual_network_link" "vnl" {
  name                  = "dns-netwrok-link"
  private_dns_zone_name = azurerm_private_dns_zone.PDNSZ.name
  resource_group_name   = azurerm_resource_group.rg.name
  virtual_network_id    = azurerm_virtual_network.vnet.id
}