# Create Random Password
resource "random_password" "k3s-password" {
  length           = 16
  special          = true
  override_special = "_%@"
}

resource "azurerm_key_vault_secret" "keyvault_ado_agent_secret" {
  name         = "${azurecaf_name.vm-k3s.result}-password"
  value        = random_password.k3s-password.result
  key_vault_id = azurerm_key_vault.kv.id
}
