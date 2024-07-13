// output file

output "prefix-ip" {
  value = azurerm_public_ip.lab-pip.ip_address
}
