resource "azurerm_container_registry" "acr" {
  name                = "learningstepsacr"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  sku                 = "Basic"
  admin_enabled       = false
}

resource "azurerm_role_assignment" "role" {
  scope                = azurerm_container_registry.acr.id
  principal_id         = azurerm_kubernetes_cluster.aks_cluster.kubelet_identity[0].object_id
  role_definition_name = "AcrPull"
}

# admin_enabled is false, so CI pushes as the service principal via `az acr login`.
resource "azurerm_role_assignment" "acr_push" {
  scope                = azurerm_container_registry.acr.id
  principal_id         = data.azurerm_client_config.current.object_id
  role_definition_name = "AcrPush"
}