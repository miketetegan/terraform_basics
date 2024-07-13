// azurerm_subnet.subnet.id references a resource that does not exists yet
// data is used to query existing value in the infrastructure
// Use queried value to create a new resource with data.azurerm_public_ip_prefix.pip-prefix-out.id 
// terraform destroy -–target azurerm_network_security_group.lab-nsg ; for example deletes the lab-nsg resource 
// terraform.tfstate file holds the current state of your remote infra . It is created during the first init execution
// terraform.tfstate.backup holds the old state of your infra before the new config gets applied 



// Configure the Microsoft Azure Provider
provider "azurerm" {
#  subscription_id = PAYG-Sandboxes
  skip_provider_registration = true # This is only required when the User, Service Principal, or Identity running Terraform lacks the permissions to register Azure Resource Providers.
  features {}
}

// Create the variables . You can specify them in 3 ways : with terraform apply prompt; with terraform apply -var "resource_group = rg_tf_004"; or using a tfvars file .


// Create a NSG
resource "azurerm_network_security_group" "lab-nsg" {
  name                = "lab-nsg"
  location            = var.resource_location  // Define the location variable specified
  resource_group_name = var.resource_group   //Define the rg variable specified 
security_rule {
    name                       = "allow-ssh"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

// Create a VNet
resource "azurerm_virtual_network" "lab-vnet" {
  name                = "lab-vnet"
  location            = var.resource_location  // Define the location variable specified
  resource_group_name = var.resource_group   //Define the rg variable specified 
  address_space       = ["10.0.0.0/16"]
}
#  subnet {
#    name           = "subnet1"
#    address_prefix = "10.0.0.0/24"
#    security_group = "lab-nsg"
#  }
#}

resource "azurerm_subnet" "subnet" {
  name                 = "subnet"
  resource_group_name  = var.resource_group   //Define the rg variable specified 
  virtual_network_name = "lab-vnet"
  address_prefixes     = ["10.0.0.0/24"]
}


//Create a PIP
resource "azurerm_public_ip" "lab-pip" {
  name                = "lab-pip"
  resource_group_name = var.resource_group   //Define the rg variable specified 
  location            = var.resource_location  // Define the location variable specified
  allocation_method   = "Static"
  sku = "Standard"
  tags = {
    environment = "Production"
  }
}


// Create a vNIC
resource "azurerm_network_interface" "lab-nic" {
  name                = "lab-nic"
  location            = var.resource_location  // Define the location variable specified
  resource_group_name = var.resource_group   //Define the rg variable specified 

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.subnet.id       
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id = azurerm_public_ip.lab-pip.id
  }
}

// NSG and vNIC association
resource "azurerm_network_interface_security_group_association" "nsg-nic" {
  network_interface_id      = azurerm_network_interface.lab-nic.id
  network_security_group_id = azurerm_network_security_group.lab-nsg.id
}

// Create a linux VM
resource "azurerm_linux_virtual_machine" "example" {
  name                = "example-machine"
  resource_group_name = var.resource_group   //Define the rg variable specified 
  location            = var.resource_location  // Define the location variable specified
  size                = "Standard_B2s"
  admin_username      = "adminuser"
# count               = 3
  network_interface_ids = [
    azurerm_network_interface.lab-nic.id,
  ]

  admin_ssh_key {
    username   = "adminuser"
    public_key = file("/root/.ssh/terra.pub")
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }
}

// Query existing resource in Azure with data 
data "azurerm_public_ip_prefix" "pip-prefix-out" {
  name                 = "pip-prefix"
  resource_group_name  = var.resource_group   //Define the rg variable specified  }

// Use queried value to create a new resource with data.azurerm_public_ip_prefix.pip-prefix-out.id 


// Output PIP at the end of the execution

