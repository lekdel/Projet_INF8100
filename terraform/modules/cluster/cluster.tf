
resource "azurerm_resource_group" "projet-log8100" {
  name = var.rgname
  location = var.location
}

resource "azurerm_kubernetes_cluster" "projet-log8100" {
  name                  = "projet-log8100-cluster"
  location              = azurerm_resource_group.projet-log8100.location
  resource_group_name   = azurerm_resource_group.projet-log8100.name
  dns_prefix            = "projet-log8100"
  kubernetes_version    = var.kubernetes_version

  default_node_pool {
    name            = "default"
    node_count      = 2
    vm_size         = "standard_b2als_v2"
    type            = "VirtualMachineScaleSets"
    os_disk_size_gb = 250
  }

  identity {
    type = "SystemAssigned"
  }

  tags = {
    Environment = "Production"
  }

  linux_profile {
    admin_username = "azureuser"
    ssh_key {
      key_data = var.ssh_key
    }
  }

  network_profile {
    network_plugin = "kubenet"
    load_balancer_sku = "standard"
  }
}