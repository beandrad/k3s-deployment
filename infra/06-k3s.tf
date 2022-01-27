resource "azurecaf_name" "vm-k3s" {
  name          = var.name
  prefixes      = concat(["k3s"], var.prefixes)
  suffixes      = var.suffixes
  resource_type = "azurerm_linux_virtual_machine"
  random_length = var.random_length
}

resource "azurecaf_name" "vm-k3s-nic" {
  name     = var.name
  prefixes = concat(["k3s"], var.prefixes)
  suffixes = var.suffixes
  resource_types = [
    "azurerm_public_ip",
    "azurerm_network_interface"
  ]
  random_length = var.random_length
}

resource "azurerm_public_ip" "vm-k3s" {
  name                    = azurecaf_name.vm-k3s-nic.results["azurerm_public_ip"]
  location                = azurerm_resource_group.rg.location
  resource_group_name     = azurerm_resource_group.rg.name
  allocation_method       = "Static"
  idle_timeout_in_minutes = 30
}

resource "azurerm_network_interface" "vm-k3s" {
  name                = azurecaf_name.vm-k3s-nic.results["azurerm_network_interface"]
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "config"
    subnet_id                     = azurerm_subnet.net.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.vm-k3s.id
  }
}

data "template_file" "install-k3s" {
  template = file("${path.module}/scripts/install-k3s.sh")

  vars = {
    vault_url = azurerm_key_vault.kv.vault_uri
    server_ip = azurerm_public_ip.vm-k3s.ip_address
  }
}

data "template_file" "config-k3s" {
  template = file("${path.module}/scripts/config-k3s.yaml")

  vars = {
    server_ip = azurerm_public_ip.vm-k3s.ip_address
  }
}

data "template_file" "cloud-init" {
  template = file("${path.module}/scripts/cloud-init-k3s.yaml")

  vars = {
    install_k3s = base64encode(data.template_file.install-k3s.rendered)
    # add k3s config
    config_k3s = base64encode(data.template_file.config-k3s.rendered)
  }
}

data "template_cloudinit_config" "init" {
  gzip          = true
  base64_encode = true

  part {
    content_type = "text/cloud-config"
    content      = data.template_file.cloud-init.rendered
  }
}

resource "azurerm_linux_virtual_machine" "vm-k3s" {
  name                            = azurecaf_name.vm-k3s.result
  location                        = azurerm_resource_group.rg.location
  resource_group_name             = azurerm_resource_group.rg.name
  network_interface_ids           = [azurerm_network_interface.vm-k3s.id]
  size                            = "Standard_A1_v2"
  admin_username                  = "adminuser"
  admin_password                  = random_password.k3s-password.result
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
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.k3s.id]
  }

  custom_data = data.template_cloudinit_config.init.rendered
}
