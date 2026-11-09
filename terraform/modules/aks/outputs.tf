output "aks_id" {
  value = azurerm_kubernetes_cluster.aegis.id
}

output "aks_name" {
  value = azurerm_kubernetes_cluster.aegis.name
}


output "oidc_issuer_url" {
  value = azurerm_kubernetes_cluster.aegis.oidc_issuer_url
}

output "kubelet_identity_object_id" {
  description = "Object ID of the AKS kubelet identity"
  value       = azurerm_kubernetes_cluster.aegis.kubelet_identity[0].object_id
}