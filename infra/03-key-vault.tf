resource "azurecaf_name" "kv" {
  name          = var.name
  prefixes      = var.prefixes
  suffixes      = var.suffixes
  resource_type = "azurerm_key_vault"
  random_length = var.random_length
}

resource "azurerm_key_vault" "kv" {
  name                        = azurecaf_name.kv.result
  location                    = azurerm_resource_group.rg.location
  resource_group_name         = azurerm_resource_group.rg.name
  tenant_id                   = data.azurerm_client_config.current.tenant_id
  sku_name                    = "standard"
  enabled_for_disk_encryption = true

  purge_protection_enabled = false

  enabled_for_deployment          = true
  enabled_for_template_deployment = true
}

resource "azurerm_key_vault_access_policy" "admin" {
  key_vault_id = azurerm_key_vault.kv.id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = data.azurerm_client_config.current.object_id

  key_permissions = [
      "backup", "create", "delete", "get", "import", "list", "recover", "restore", "update"
    ]

    secret_permissions = [
      "backup", "delete", "get", "list", "recover", "restore", "set"
    ]

    certificate_permissions = [
      "backup", "create", "delete", "deleteissuers", "get", "getissuers", "import", "list", "listissuers", "managecontacts", "manageissuers", "recover", "restore", "setissuers", "update"
    ]
}

resource "azurerm_key_vault_access_policy" "service_reader" {
  key_vault_id = azurerm_key_vault.kv.id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = azurerm_user_assigned_identity.k3s.principal_id

  key_permissions         = []
  secret_permissions      = ["Get", "Set"]
  certificate_permissions = []
  storage_permissions     = []
}
