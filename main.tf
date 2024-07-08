provider "azurerm" {

  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }

  skip_provider_registration = true
}

variable "resource_group" {
  default = "terraform-training"
}

variable "name" {
  default = "student-name"
}

data "azurerm_resource_group" "rg" {
  name = var.resource_group
}

output "resource_group_name" {
  value = azurerm_resource_group.rg.name
}