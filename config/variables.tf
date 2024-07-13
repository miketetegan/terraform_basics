// Variable file 

variable "resource_group" {
  description = "Azure resource group"
  default = "rg_tf_004"
  type = string  // can define your variable type if needed 
}

variable "resource_location" {
  description = "Resources location"
  default = "westus"
  type = string  
}
