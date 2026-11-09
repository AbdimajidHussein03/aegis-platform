
resource "azurerm_kubernetes_cluster" "aegis" {
  name                = var.aks_name
  location            = var.location
  resource_group_name = var.resource_group_name
  dns_prefix          = var.dns_prefix

  sku_tier = "Free"

  node_provisioning_profile {
    mode = "Manual"
  }

  default_node_pool {
    name           = "system"
    node_count     = var.node_count
    vm_size        = var.vm_size
    vnet_subnet_id = var.aks_subnet_id

    temporary_name_for_rotation = "tempnode"
  }

  identity {
    type         = "UserAssigned"
    identity_ids = [var.aks_identity_id]
  }
  oidc_issuer_enabled       = true
  workload_identity_enabled = true

  network_profile {
    network_plugin      = "azure"
    network_plugin_mode = "overlay"

    load_balancer_sku = "standard"
    outbound_type     = "userAssignedNATGateway"

    pod_cidr       = var.pod_cidr
    service_cidr   = var.service_cidr
    dns_service_ip = var.dns_service_ip
  }
}
