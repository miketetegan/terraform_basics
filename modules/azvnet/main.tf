// Contains the actual resources you want to create 

resource "azurerm_virtual_network" "module-vnet" {
  name                = var.vnet_name
  location            = var.resource_location  // Define the location variable specified
  resource_group_name = var.resource_group   //Define the rg variable specified 
  address_space       = var.address_space_list
}

resource "azurerm_subnet" "subnet" {
  name                 = "subnet"
  resource_group_name  = var.resource_group   //Define the rg variable specified 
  virtual_network_name = ${var.vnet_name}
  address_prefixes     = var.address_prefixes_list
}

