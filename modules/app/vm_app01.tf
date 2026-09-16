#Interface réseau
resource "azurerm_network_interface" "app" {
  name                = "nic-${var.environment}-app01"
  location            = local.common_config.location
  resource_group_name = local.common_config.resource_group_name
  tags                = local.common_tags

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.backend.id
    private_ip_address_allocation = "Dynamic"
  }
}

#group de sécurité autorisant le traffic internet entrant
resource "azurerm_network_security_group" "app" {
  name                = "nsg-${var.environment}-app01"
  location            = local.common_config.location
  resource_group_name = local.common_config.resource_group_name

security_rule {
    name                       = "Allow-Front-To-Back-HTTP"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    
    # Remplacer "*" par le sous-réseau de votre front
    # Exemple si votre subnet frontend est une ressource Terraform :
    source_address_prefix      = azurerm_subnet.frontend.address_prefixes[0] 
    
    destination_address_prefix = "*"
  }

  tags = local.common_tags
}

resource "azurerm_network_interface_security_group_association" "app" {
  network_interface_id      = azurerm_network_interface.app.id
  network_security_group_id = azurerm_network_security_group.app.id
}

#VM linux LTS 

resource "azurerm_linux_virtual_machine" "app" {
  name                  = "cloudcorp-${var.environment}-app01"
  resource_group_name   = local.common_config.resource_group_name
  location              = local.common_config.location
  size                  = "Standard_B1s"
  admin_username        = "azureuser"
  network_interface_ids = [azurerm_network_interface.app.id]

  admin_ssh_key {
    username   = "azureuser"
  	public_key = file(pathexpand(var.public_key_path))
  }

  os_disk {
    caching = "ReadWrite"
    #HDD
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "ubuntu-24_04-lts"
    sku       = "server"
    version   = "latest"
  }
  tags = local.common_tags
}

# 1. IP Publique dédiée à la NAT Gateway
resource "azurerm_public_ip" "nat_gw_ip" {
  name                = "pip-nat-gw-${var.environment}"
  location            = local.common_config.location
  resource_group_name = local.common_config.resource_group_name
  allocation_method   = "Static"
  sku                 = "Standard" # Obligatoire pour une NAT Gateway
  tags                = local.common_tags
}

# 2. La NAT Gateway
resource "azurerm_nat_gateway" "nat_gw" {
  name                    = "nat-gw-${var.environment}"
  location                = local.common_config.location
  resource_group_name     = local.common_config.resource_group_name
  sku_name                = "Standard"
  idle_timeout_in_minutes = 4
  tags                    = local.common_tags
}

# 3. Association de l'IP Publique à la NAT Gateway
resource "azurerm_nat_gateway_public_ip_association" "nat_gw_ip_assoc" {
  nat_gateway_id       = azurerm_nat_gateway.nat_gw.id
  public_ip_address_id = azurerm_public_ip.nat_gw_ip.id
}

# 4. Association de la NAT Gateway au sous-réseau Backend de la VM APP01
resource "azurerm_subnet_nat_gateway_association" "backend_nat_assoc" {
  subnet_id      = azurerm_subnet.backend.id # Remplacez par le nom exact de votre ressource subnet backend
  nat_gateway_id = azurerm_nat_gateway.nat_gw.id
}
