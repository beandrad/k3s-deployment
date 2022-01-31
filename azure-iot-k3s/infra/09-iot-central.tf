resource "azurecaf_name" "iot-central" {
  name          = var.name
  prefixes      = var.prefixes
  suffixes      = var.suffixes
  resource_type = "azurerm_iotcentral_application"
  random_length = var.random_length
}

resource "azurerm_iotcentral_application" "iot" {
  name                = azurecaf_name.iot-central.result
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  sub_domain          = "dev-${var.name}"

  display_name = "Dev ${var.name}"
  sku          = "ST1"
  # template     = "iotc-default@1.0.0"
}
