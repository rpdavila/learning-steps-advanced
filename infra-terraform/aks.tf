resource "azurerm_kubernetes_cluster" "aks_cluster" {
  name                = "learning-steps-aks"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  dns_prefix          = "learning-dev-k8s"
  kubernetes_version  = "1.34"

  identity {
    type = "SystemAssigned"
  }

  key_vault_secrets_provider {
    secret_rotation_enabled = true
  }

  default_node_pool {
    name            = "lsnodepool"
    node_count      = 2
    vm_size         = "Standard_D2_v4"
    os_disk_size_gb = 30
    vnet_subnet_id  = azurerm_subnet.aks_subnet.id
  }

  network_profile {
    network_plugin = "azure"
    network_policy = "azure"
    service_cidr = "10.2.0.0/16"
    dns_service_ip = "10.2.0.10"
  }

  role_based_access_control_enabled = true

  tags = {
    Environment = var.environment
    Owner       = var.owner
  }
}

resource "azurerm_role_assignment" "aks_cluster_keyvault_secret_user" {
  principal_id         = azurerm_kubernetes_cluster.aks_cluster.identity[0].principal_id
  role_definition_name = "Key Vault Secrets User"
  scope                = azurerm_key_vault.akv.id
  depends_on           = [azurerm_kubernetes_cluster.aks_cluster]
}

resource "azurerm_role_assignment" "aks_keyvault_secret_user" {
  principal_id         = azurerm_kubernetes_cluster.aks_cluster.kubelet_identity[0].object_id
  role_definition_name = "Key Vault Secrets User"
  scope                = azurerm_key_vault.akv.id
  depends_on           = [azurerm_kubernetes_cluster.aks_cluster]
}

