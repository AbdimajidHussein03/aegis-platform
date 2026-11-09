
resource "azurerm_virtual_network" "aegis" {
  name                = "vnet-aegis-dev"
  address_space       = ["10.0.0.0/16"]
  location            = var.location
  resource_group_name = var.resource_group_name
}

resource "azurerm_subnet" "app_gateway" {
  name                 = "snet-appgw-dev"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.aegis.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_subnet" "aks" {
  name                 = "snet-aks-dev"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.aegis.name
  address_prefixes     = ["10.0.4.0/22"]
}

resource "azurerm_network_security_group" "aks" {
  name                = "nsg-aks-dev"
  location            = var.location
  resource_group_name = var.resource_group_name

  security_rule {
    name                       = "allow-appgw-https"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "10.0.1.0/24"
    destination_address_prefix = "10.0.4.0/22"
  }

  security_rule {
    name                       = "allow-aks-outbound-https"
    priority                   = 120
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "10.0.4.0/22"
    destination_address_prefix = "Internet"
  }
}

resource "azurerm_subnet_network_security_group_association" "aks" {
  subnet_id                 = azurerm_subnet.aks.id
  network_security_group_id = azurerm_network_security_group.aks.id
}

resource "azurerm_network_security_group" "app_gateway" {
  name                = "nsg-appgw-dev"
  location            = var.location
  resource_group_name = var.resource_group_name

  security_rule {
    name                       = "allow-internet-https"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "Internet"
    destination_address_prefix = "10.0.1.0/24"
  }

  security_rule {
    name                       = "allow-gateway-manager"
    priority                   = 110
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "65200-65535"
    source_address_prefix      = "GatewayManager"
    destination_address_prefix = "10.0.1.0/24"
  }
}

resource "azurerm_subnet_network_security_group_association" "app_gateway" {
  subnet_id                 = azurerm_subnet.app_gateway.id
  network_security_group_id = azurerm_network_security_group.app_gateway.id
}

resource "azurerm_public_ip" "nat" {
  name                = "pip-nat-aegis-dev"
  location            = var.location
  resource_group_name = var.resource_group_name

  allocation_method = "Static"
  sku               = "Standard"
}

resource "azurerm_nat_gateway" "aks" {
  name                    = "nat-aegis-dev"
  location                = var.location
  resource_group_name     = var.resource_group_name
  sku_name                = "Standard"
  idle_timeout_in_minutes = 10
}

resource "azurerm_nat_gateway_public_ip_association" "aks" {
  nat_gateway_id       = azurerm_nat_gateway.aks.id
  public_ip_address_id = azurerm_public_ip.nat.id
}

resource "azurerm_subnet_nat_gateway_association" "aks" {
  subnet_id      = azurerm_subnet.aks.id
  nat_gateway_id = azurerm_nat_gateway.aks.id
}
