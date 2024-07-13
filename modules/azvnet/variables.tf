// Define the variables specified in the module 

variable "vnet_name" {}

variable "resource_location" {}

variable "resource_group" {}

variable "address_space_list" {
  type = list
}

variable "address_prefixes_list" {
  type = list
}

