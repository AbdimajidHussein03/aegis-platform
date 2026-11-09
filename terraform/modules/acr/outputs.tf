
output "acr_id" {
  description = "Azure Container Registry resource ID"
  value       = azurerm_container_registry.aegis.id
}

output "login_server" {
  description = "Azure Container Registry login server"
  value       = azurerm_container_registry.aegis.login_server
}
