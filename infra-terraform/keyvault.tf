resource "azurerm_key_vault" "akv" {
  name                       = "learning-steps-key-vault"
  resource_group_name        = azurerm_resource_group.rg.name
  location                   = azurerm_resource_group.rg.location
  sku_name                   = "standard"
  tenant_id                  = var.tennant_id
  soft_delete_retention_days = 90
  rbac_authorization_enabled = true

  network_acls {
    default_action = "Deny"
    bypass         = "AzureServices"
    # The CI runner writes azurerm_key_vault_secret over the Key Vault data
    # plane, which "Deny" blocks regardless of RBAC. Supplied per-run as
    # TF_VAR_keyvault_allowed_ip.
    ip_rules = [
      var.keyvault_allowed_ip,
      data.azurerm_public_ip.aks_egress.ip_address,
    ]
  }
}

resource "azurerm_role_assignment" "rbac_akv" {
  principal_id         = data.azurerm_client_config.current.object_id
  role_definition_name = "Key Vault Secrets Officer"
  scope                = azurerm_key_vault.akv.id
}

# TEMPORARY: adopt the secret left behind by a partial apply. It is NOT in
# state, so Terraform tries to create it and fails with "already exists".
# DELETE THIS BLOCK only after a run has completed successfully.
import {
  to = azurerm_key_vault_secret.akv_secret
  id = "https://learning-steps-key-vault.vault.azure.net/secrets/learning-steps-secret/df0c76b99875449d884a2fac41565557"
}

resource "azurerm_key_vault_secret" "akv_secret" {
  name         = "learning-steps-secret"
  key_vault_id = azurerm_key_vault.akv.id
  value        = var.postgres_password
  depends_on   = [time_sleep.wait_for_rbac]
}

resource "azurerm_network_security_rule" "akv_outbound" {
  name      = "Allow-AKV-Out"
  priority  = 109
  direction = "Outbound"
  access    = "Allow"
  protocol  = "Tcp"

  source_address_prefix      = "*"
  destination_address_prefix = "AzureKeyVault"

  source_port_range      = "*"
  destination_port_range = "*"

  resource_group_name         = azurerm_resource_group.rg.name
  network_security_group_name = azurerm_network_security_group.aks_nsg.name
}