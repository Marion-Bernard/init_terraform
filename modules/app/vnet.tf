resource "azurerm_virtual_network" "lab" {
  name                = "cloudcorp-${var.environment}-vnet"
  location            = local.common_config.location
  resource_group_name = local.common_config.resource_group_name
  address_space       = ["10.20.0.0/16"]
  tags                = local.common_tags
}

resource "azurerm_subnet" "frontend" {
  name                 = "subnet-${var.environment}-frontend"
  resource_group_name  = local.common_config.resource_group_name
  virtual_network_name = azurerm_virtual_network.lab.name
  address_prefixes     = ["10.20.1.0/24"]
}

resource "azurerm_subnet" "backend" {
  name                 = "subnet-${var.environment}-backend"
  resource_group_name  = local.common_config.resource_group_name
  virtual_network_name = azurerm_virtual_network.lab.name
  address_prefixes     = ["10.20.2.0/24"]
}