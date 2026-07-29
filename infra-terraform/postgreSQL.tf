resource "azurerm_postgresql_flexible_server" "postgresql" {
  name                          = "postgresql-database"
  location                      = azurerm_resource_group.rg.location
  resource_group_name           = azurerm_resource_group.rg.name
  version                       = "18"
  delegated_subnet_id           = azurerm_subnet.Postgresql_subnet.id
  private_dns_zone_id           = azurerm_private_dns_zone.PDNSZ.id
  public_network_access_enabled = false
  administrator_login           = var.postgres_user
  administrator_password        = azurerm_key_vault_secret.akv_secret.value
  zone                          = 1

  storage_mb   = 32768
  storage_tier = "P4"

  sku_name   = "B_Standard_B1ms"
  depends_on = [azurerm_private_dns_zone_virtual_network_link.vnl]
}

resource "azurerm_postgresql_flexible_server_firewall_rule" "example" {
  name             = "Firewall-for-postgresql"
  server_id        = azurerm_postgresql_flexible_server.postgresql.id
  start_ip_address = "0.0.0.0"
  end_ip_address   = "0.0.0.0"
}

