// Define the module's outputs

output "vnet_output" {
  value = azurerm_virtual_network.module-vnet  // Gets all the values of the resource object
}
