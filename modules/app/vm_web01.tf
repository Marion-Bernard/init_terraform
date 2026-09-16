#Adresse IP Publique
resource "azurerm_public_ip" "web" {
  name                = "pip-${var.environment}-web01"
  location            = local.common_config.location
  resource_group_name = local.common_config.resource_group_name
  allocation_method   = "Static"
  sku                 = "Standard"
  tags                = local.common_tags
}

#Interface réseau
resource "azurerm_network_interface" "web" {
  name                = "nic-${var.environment}-web01"
  location            = local.common_config.location
  resource_group_name = local.common_config.resource_group_name
  tags                = local.common_tags

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.frontend.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.web.id
  }
}

#group de sécurité autorisant le traffic internet entrant
resource "azurerm_network_security_group" "web" {
  name                = "nsg-${var.environment}-web01"
  location            = local.common_config.location
  resource_group_name = local.common_config.resource_group_name

  security_rule {
    name                       = "Allow-HTTP"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  tags = local.common_tags
}

resource "azurerm_network_interface_security_group_association" "web" {
  network_interface_id      = azurerm_network_interface.web.id
  network_security_group_id = azurerm_network_security_group.web.id
}

#VM linux LTS 

resource "azurerm_linux_virtual_machine" "web" {
  name                  = "cloudcorp-${var.environment}-web01"
  resource_group_name   = local.common_config.resource_group_name
  location              = local.common_config.location
  size                  = "Standard_B1s"
  admin_username        = "azureuser"
  network_interface_ids = [azurerm_network_interface.web.id]

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
