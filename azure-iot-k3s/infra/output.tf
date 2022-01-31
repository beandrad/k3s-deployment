output "k3s-vm-admin-username" {
  value = azurerm_linux_virtual_machine.vm-k3s.admin_username
}

output "k3s-vm-admin-password" {
  value     = azurerm_linux_virtual_machine.vm-k3s.admin_password
  sensitive = true
}

output "k3s-vm-public-ip" {
  value = azurerm_linux_virtual_machine.vm-k3s.public_ip_address
}

output "k3s121-vm-public-ip" {
  value = azurerm_linux_virtual_machine.vm-k3s121.public_ip_address
}

output "rancher-vm-public-ip" {
  value = azurerm_linux_virtual_machine.vm-rancher.public_ip_address
}

output "kv_name" {
  value = azurerm_key_vault.kv.name
}
