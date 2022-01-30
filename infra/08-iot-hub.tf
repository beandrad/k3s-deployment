resource "azurecaf_name" "law" {
  name          = var.name
  prefixes      = var.prefixes
  suffixes      = var.suffixes
  resource_type = "azurerm_log_analytics_workspace"
  random_length = var.random_length
}

resource "azurerm_log_analytics_workspace" "iot" {
  name                = azurecaf_name.law.result
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
}

resource "azurecaf_name" "iot" {
  name          = var.name
  prefixes      = var.prefixes
  suffixes      = var.suffixes
  resource_type = "azurerm_iothub"
  random_length = var.random_length
}

resource "azurerm_iothub" "iot" {
  name                = azurecaf_name.iot.result
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location

  sku {
    name     = "F1"
    capacity = "1"
  }

  event_hub_partition_count = 2
  event_hub_retention_in_days = 1
}
