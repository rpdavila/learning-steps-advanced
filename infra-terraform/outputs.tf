output "key_vault_id" {
  value = azurerm_key_vault.akv.id
}

output "key_vault_name" {
  value = azurerm_key_vault.akv.name
}

output "key_vault_uri" {
  value = azurerm_key_vault.akv.vault_uri
}


output "aks_cluster_name" {
  value = azurerm_kubernetes_cluster.aks_cluster.name
}

output "aks_resource_group" {
  value = azurerm_resource_group.rg.name
}

output "acr_login_server" {
  value = azurerm_container_registry.acr.login_server
}

output "acr_name" {
  value = azurerm_container_registry.acr.name
}

output "postgres_server_fqdn" {
  value = azurerm_postgresql_flexible_server.postgresql.fqdn
}

output "postgres_server_name" {
  value = azurerm_postgresql_flexible_server.postgresql.name
}

output "vnet_id" {
  value = azurerm_virtual_network.vnet.id
}

output "aks_subnet_id" {
  value = azurerm_subnet.aks_subnet.id
}

output "postgres_subnet_id" {
  value = azurerm_subnet.Postgresql_subnet.id
}