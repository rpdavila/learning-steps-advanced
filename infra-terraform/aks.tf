resource "azurerm_kubernetes_cluster" "aks_cluster" {
  name                = "learning-steps-aks"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  dns_prefix          = "learning-dev-k8s"
  kubernetes_version  = "1.34"
  api_server_access_profile {
    authorized_ip_ranges = ["93.222.255.160/32"]
  }
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
    service_cidr   = "10.2.0.0/16"
    dns_service_ip = "10.2.0.10"
  }

  role_based_access_control_enabled = true

  tags = {
    Environment = var.environment
    Owner       = var.owner
  }
}

# The Secrets Store CSI driver reads Key Vault as the secrets-provider addon
# identity -- not the control-plane or kubelet identity. Granting the wrong
# principal makes the secret mount fail with 403 at pod start.
resource "azurerm_role_assignment" "aks_kv_secrets_provider" {
  principal_id         = azurerm_kubernetes_cluster.aks_cluster.key_vault_secrets_provider[0].secret_identity[0].object_id
  role_definition_name = "Key Vault Secrets User"
  scope                = azurerm_key_vault.akv.id
}

