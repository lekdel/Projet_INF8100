terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=4.13.0"
    }
  }
}

provider "azurerm" {
    subscription_id = var.subscription_id
    client_id       = var.service_principle_id
    client_secret   = var.service_principle_key
    tenant_id       = var.tenant_id
    features {}
}
resource "azurerm_resource_group" "rg1" {
  name = var.rgname
  location = var.location
}

module "cluster" {
  source = "./modules/cluster"
  service_principle_id = var.service_principle_id
  service_principle_key = var.service_principle_key
  ssh_key = var.ssh_key
  kubernetes_version = var.kubernetes_version
}