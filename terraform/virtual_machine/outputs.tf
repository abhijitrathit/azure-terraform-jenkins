output "vm_names" {
  value = azurerm_linux_virtual_machine.this[*].name
}

output "private_ips" {
  value = azurerm_network_interface.this[*].private_ip_address
}

output "public_ips" {
  value = var.create_public_ip ? azurerm_public_ip.this[*].ip_address : []
}
