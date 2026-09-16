output "vnet_name" { value = azurerm_virtual_network.lab.name }
output "web01_private_ip" { value = azurerm_network_interface.web.private_ip_address }
output "web01_public_ip" { value = azurerm_public_ip.web.ip_address }