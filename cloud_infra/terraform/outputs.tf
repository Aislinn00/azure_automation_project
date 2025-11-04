output "public_ip" {
  description = "Public IP of the VM"
  value       = azurerm_public_ip.pip.ip_address
}

output "ssh_command" {
  description = "Convenience SSH command"
  value       = "ssh ${var.admin_username}@${azurerm_public_ip.pip.ip_address}"
}

output "resource_group_name" {
  description = "Existing Resource Group name"
  value       = data.azurerm_resource_group.rg.name
}

output "resource_group_location" {
  description = "Existing Resource Group location"
  value       = data.azurerm_resource_group.rg.location
}
