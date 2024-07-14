terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = "3.110.0"
    }
  }
}

provider "azurerm" {
  skip_provider_registration = true # This is only required when the User, Service Principal, or Identity running Terraform lacks the permissions to register Azure Resource Providers.
  features {}
}

resource "azurerm_kubernetes_cluster" "cluster" {
  name                = "example-aks1"
  location            = "westus"
  resource_group_name = "rg_sb_eastus_124111_1_172008794215"
  dns_prefix          = "clustertetegan"

  default_node_pool {
    name       = "default"
    node_count = 3
    vm_size    = "standard_d2as_v4"
  }

  identity {
    type = "SystemAssigned"
  }

  tags = {
    Environment = "Production"
  }
}

output "client_certificate" {
  value     = azurerm_kubernetes_cluster.cluster.kube_config[0].client_certificate
  sensitive = true
}

output "kube_config" {
  value = azurerm_kubernetes_cluster.cluster.kube_config_raw

  sensitive = true
}
