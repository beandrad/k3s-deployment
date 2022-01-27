resource "azurecaf_name" "vm-rancher" {
  name          = var.name
  prefixes      = concat(["rancher"], var.prefixes)
  suffixes      = var.suffixes
  resource_type = "azurerm_linux_virtual_machine"
  random_length = var.random_length
}

resource "azurecaf_name" "vm-rancher-nic" {
  name          = var.name
  prefixes      = concat(["rancher"], var.prefixes)
  suffixes      = var.suffixes
  resource_types = [
    "azurerm_public_ip",
    "azurerm_network_interface"
  ]
  random_length = var.random_length
}

resource "azurerm_public_ip" "vm-rancher" {
  name                    = azurecaf_name.vm-rancher-nic.results["azurerm_public_ip"]
  location                = azurerm_resource_group.rg.location
  resource_group_name     = azurerm_resource_group.rg.name
  allocation_method       = "Static"
  idle_timeout_in_minutes = 30
}

resource "azurerm_network_interface" "vm-rancher" {
  name                = azurecaf_name.vm-rancher-nic.results["azurerm_network_interface"]
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "config"
    subnet_id                     = azurerm_subnet.net.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id = azurerm_public_ip.vm-rancher.id
  }
}

data "template_file" "cloud-init-rancher" {
  template = file("${path.module}/scripts/cloud-init-rancher.yaml")
}

data "template_cloudinit_config" "init-rancher" {
  gzip          = true
  base64_encode = true

  part {
    content_type = "text/cloud-config"
    content      = data.template_file.cloud-init-rancher.rendered
  }
}

resource "azurerm_linux_virtual_machine" "vm-rancher" {
  name                  = azurecaf_name.vm-rancher.result
  location              = azurerm_resource_group.rg.location
  resource_group_name   = azurerm_resource_group.rg.name
  network_interface_ids = [azurerm_network_interface.vm-rancher.id]
  size                  = "Standard_DS3_v2"
  admin_username        = "adminuser"
  admin_password = random_password.k3s-password.result
  disable_password_authentication = false

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-focal"
    sku       = "20_04-LTS"
    version   = "latest"
  }

  os_disk {
    storage_account_type = "Standard_LRS"
    caching              = "ReadWrite"
  }

  identity {
    type = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.k3s.id]
  }

  custom_data = data.template_cloudinit_config.init-rancher.rendered
}
