
terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
    }
  }
}

provider "azurerm" {
  features {}
}


resource "azurerm_resource_group" "aegis" {
  name     = "rg-aegis-dev"
  location = "West Europe"
}


module "networking" {
  source = "../../modules/networking"

  location            = var.location
  resource_group_name = azurerm_resource_group.aegis.name
}


resource "azurerm_user_assigned_identity" "aks" {
  name                = "id-aks-aegis-dev"
  location            = var.location
  resource_group_name = azurerm_resource_group.aegis.name
}

# Grant AKS permissions on its subnet
resource "azurerm_role_assignment" "aks_network" {
  scope                = module.networking.aks_subnet_id
  role_definition_name = "Network Contributor"
  principal_id         = azurerm_user_assigned_identity.aks.principal_id

  skip_service_principal_aad_check = true
}


module "acr" {
  source = "../../modules/acr"

  acr_name            = "acraegisdev01"
  resource_group_name = azurerm_resource_group.aegis.name
  location            = var.location
}



module "aks" {
  source = "../../modules/aks"

  aks_name            = "aks-aegis-dev"
  location            = var.location
  resource_group_name = azurerm_resource_group.aegis.name
  dns_prefix          = "aegisdev"

  node_count    = var.node_count
  vm_size       = var.vm_size
  aks_subnet_id = module.networking.aks_subnet_id

  aks_identity_id = azurerm_user_assigned_identity.aks.id

  pod_cidr       = var.pod_cidr
  service_cidr   = var.service_cidr
  dns_service_ip = var.dns_service_ip

  depends_on = [
    azurerm_role_assignment.aks_network,
    module.networking
  ]
}

resource "azurerm_role_assignment" "aks_acr_pull" {
  scope                = module.acr.acr_id
  role_definition_name = "AcrPull"
  principal_id         = module.aks.kubelet_identity_object_id

  skip_service_principal_aad_check = true
}

terraform {
  backend "azurerm" {
    resource_group_name  = "rg-aegis-tfstate"
    storage_account_name = "staegistfe2b6bcc9"
    container_name       = "tfstate"
    key                  = "aegis-dev.tfstate"
    use_azuread_auth     = true
  }
}