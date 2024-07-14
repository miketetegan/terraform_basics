# We strongly recommend using the required_providers block to set the
# Azure Provider source and version being used
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=3.0.0"
    }
  }
}

# Configure the Microsoft Azure Provider
provider "azurerm" {
#  subscription_id = PAYG-Sandboxes
  skip_provider_registration = true # This is only required when the User, Service Principal, or Identity running Terraform lacks the permissions to register Azure Resource Providers.
  features {}
}

# Create a resource group
#resource "azurerm_resource_group" "example" {
#  name     = "example-resources"
#  location = "West Europe"
#}

variable "subnet_range" {
  description = "subnet range"
  default = "10.0.10.0/24"
  type = string 
}

variable "region" {} #global variable using export TF_VAR

# Create a virtual network within the resource group
resource "azurerm_virtual_network" "example" {
  name                = "example-network"
  resource_group_name = "rg_sb_westeurope_124111_2_171965863975"
  location            = var.region
  address_space       = ["10.0.0.0/16"]
}

resource "azurerm_subnet" "example" {
  name                 = "example-subnet"
  resource_group_name  = "rg_sb_westeurope_124111_2_171965863975"
  virtual_network_name = "example-network"
  address_prefixes     = [var.subnet_range]
}

data "azurerm_subnet" "subnetquery" {
  name                 = "example-subnet"
  virtual_network_name = "example-network"
  resource_group_name  = "rg_sb_westeurope_124111_2_171965863975"
}

output "subnet_id" {
  value = data.azurerm_subnet.subnetquery.id
}

user_data = file("entry-script.sh")
user_data = <<EOF
		apt update -y
		apt install apache2 -y
		EOF
user_data_replace_on_change = true #instance will be destroyed and recreated if the user_data is edited



### Connects to the remote server 
connection {
  type = "ssh"
  host= self.public_ip  #if you are in the resource block 
  user= "azureuser"
  private-key = file (./id.rsa) 
}

### Copies the script to the remote server 
provisioner "file" {
  source= "./entry-script.sh"
  destination = /home/azureuser/entry-script.sh"
}

### Execute command on the remote server 
provisioner "remote-exec" {
	inline = [ #list of commands
		"export ENV=dev,
		"mkdir newdir",
    "entry-script.sh"
	]
}

### Copies the file to server and executes it 
provisioner "file" {
  script = "./entry-script.sh" 
}

### Executes a command localy after a resource is created 
provisioner "local-exec" {
  command = "pwd"
}


module "my_module" {	     #A name of the module 
   source = "modules/subnet" #location of the module
   variable1 = var.subnet    #variable in child module = variable in root var file. You define the actual values in tfvars file 
   variable2 = var.region
}

nsg = module.my-module.output.id  #Access an object for resources defined in modules 

