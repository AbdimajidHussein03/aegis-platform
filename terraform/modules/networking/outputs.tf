output "vnet_id" {
  value = azurerm_virtual_network.aegis.id
}

output "aks_subnet_id" {
  value = azurerm_subnet.aks.id
}

output "app_gateway_subnet_id" {
  value = azurerm_subnet.app_gateway.id
}