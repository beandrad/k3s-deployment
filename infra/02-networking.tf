resource "azurecaf_name" "net" {
  name     = var.name
  prefixes = var.prefixes
  suffixes = var.suffixes
  resource_types = [
    "azurerm_virtual_network",
    "azurerm_subnet"
  ]
  random_length = var.random_length
}

resource "azurerm_virtual_network" "net" {
  name                = azurecaf_name.net.results["azurerm_virtual_network"]
  address_space       = var.vnet_address_space
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
}

resource "azurerm_subnet" "net" {
  name                                           = azurecaf_name.net.results["azurerm_subnet"]
  resource_group_name                            = azurerm_resource_group.rg.name
  virtual_network_name                           = azurerm_virtual_network.net.name
  address_prefixes                               = var.subnet_address_space
  enforce_private_link_endpoint_network_policies = true
}

resource "azurerm_network_security_group" "net" {
  name                = "nsg-hub"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  security_rule {
    name                       = "websocket-allow"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "9094"
    source_address_prefixes    = var.whitelisted_ip_ranges
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "ssh-allow"
    priority                   = 101
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefixes    = var.whitelisted_ip_ranges
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "https-allow"
    priority                   = 102
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix    = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "k3s-api-allow"
    priority                   = 103
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "6443"
    source_address_prefixes    = var.whitelisted_ip_ranges
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "http-allow"
    priority                   = 104
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefixes    = var.whitelisted_ip_ranges
    destination_address_prefix = "*"
  }
}

resource "azurerm_subnet_network_security_group_association" "net" {
  subnet_id                 = azurerm_subnet.net.id
  network_security_group_id = azurerm_network_security_group.net.id
}
