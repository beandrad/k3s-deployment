resource "azurecaf_name" "identity" {
  name          = var.name
  prefixes      = var.prefixes
  suffixes      = var.suffixes
  resource_type = "azurerm_user_assigned_identity"
  random_length = var.random_length
}

resource "azurerm_user_assigned_identity" "k3s" {
  name = azurecaf_name.identity.result

  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
}

resource "azurerm_role_assignment" "cluster_vault" {
  scope                = azurerm_resource_group.rg.id
  principal_id         = azurerm_user_assigned_identity.k3s.principal_id
  role_definition_name = "Key Vault Secrets User"
}


resource "azurerm_role_assignment" "role1" {
  scope                            = azurerm_resource_group.rg.id #module.servers.scale_set_id 
  role_definition_name             = "Contributor"
  principal_id                     = azurerm_user_assigned_identity.k3s.principal_id
  skip_service_principal_aad_check = true

}

resource "azurerm_role_assignment" "role2" {
  scope                            = azurerm_resource_group.rg.id #module.servers.scale_set_id 
  role_definition_name             = "Network Contributor"
  principal_id                     = azurerm_user_assigned_identity.k3s.principal_id
  skip_service_principal_aad_check = true
}
