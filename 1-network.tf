variable "network_cidr" {
  default = "10.128.0.0/16"
}

variable "subnet_prefix" {
  default = "10.128.0.0/24"
}

variable "create_network" {
  default = true
}

resource "azurerm_virtual_network" "vnet" {
  count               = var.create_network ? 1 : 0
  name                = "${var.name}-vnet"
  address_space       = [var.network_cidr]
  location            = data.azurerm_resource_group.rg.location
  resource_group_name = data.azurerm_resource_group.rg.name
}

resource "azurerm_subnet" "subnet" {
  count                = var.create_network ? 1 : 0
  name                 = "${azurerm_virtual_network.vnet[0].name}-subnet"
  resource_group_name  = data.azurerm_resource_group.rg.name
  virtual_network_name = data.azurerm_virtual_network.vnet[0].name
  address_prefixes     = [var.subnet_prefix]
}