resource "azurecaf_name" "rg" {
  name          = var.name
  prefixes      = var.prefixes
  suffixes      = var.suffixes
  resource_type = "azurerm_resource_group"
  random_length = var.random_length
}

resource "azurerm_resource_group" "rg" {
  name     = azurecaf_name.rg.result
  location = var.location
}
