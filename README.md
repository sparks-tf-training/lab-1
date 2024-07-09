### Lab 1: Terraform Workflow, Control Structures, Outputs

**Steps:**

1. **Set Up a Simple Terraform Configuration:**

   Create a file named `main.tf` and add the following configuration to deploy an Azure virtual machine:

   ```hcl
   provider "azurerm" {
     features {}

   }
   ```

2. **Create a Resource Group:**

   Go on the Azure portal and create a resource group named `terraform-training` in the `France Central` region.

3. **Implement and Use Variables:**

   Create a file named `variables.tf` and define variables:

   ```hcl
    variable "resource_group" {
        default = "terraform-training"
    }

    variable "name" {
        default = "student-name"
    }

    variable "create_vm" {
        default = false
    }

    variable "network_cidr" {
        default = "10.128.0.0/16"
    }

    variable "subnet_prefix" {
        default = "10.128.0.0/24"
    }

    variable "create_network" {
        default = true
    }
   ```

    Create the `terraform.tfvars` file and set the values for the variables:

    ```hcl
    name = "student-name"
    create_vm = false
    create_network = false
    ```

    Update `main.tf` to use the variables:

    ```hcl
    resource "azurerm_resource_group" "rg" {
        name = var.resource_group
       location = "France Central"
    }
    ```

    Make your Terraform output more informative by adding the following:

    ```hcl
    output "resource_group_id" {
        value = data.azurerm_resource_group.rg.id
    }
    ```

    Run the following command to see the output:

    ```sh
    terraform init
    terraform apply
    ```

4. **Implement the network:**

    Create a file named `1-network.tf` and add the following configuration to create a virtual network and a subnet:

    ```hcl
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
    ```

    Update variable to enable the network creation:

    ```hcl
    create_network = true
    ```

    Run the following command to create the network:

    ```sh
    terraform apply
    ```

5. **Implement the Virtual Machine:**

   Create a file named `2-vm.tf` and add the following configuration to create a virtual machine:

    ```hcl

    locals {
        create_vm = var.create_vm && var.create_network
    }

    resource "azurerm_network_interface" "nic" {
        count               = local.create_vm ? 1 : 0
        name                = "${var.name}-nic"
        location            = data.azurerm_resource_group.rg.location
        resource_group_name = data.azurerm_resource_group.rg.name

        ip_configuration {
            name                          = "internal"
            subnet_id                     = azurerm_subnet.subnet[0].id
            private_ip_address_allocation = "Dynamic"
        }

    }

    resource "azurerm_virtual_machine" "vm" {
        count               = local.create_vm ? 1 : 0
        name                = "${var.name}-vm-demo"
        location            = data.azurerm_resource_group.rg.location
        resource_group_name = data.azurerm_resource_group.rg.name
        network_interface_ids = [
            azurerm_network_interface.nic[0].id,
        ]
        vm_size                       = "Standard_B1ls"
        delete_os_disk_on_termination = true

        storage_image_reference {
            publisher = "Canonical"
            offer     = "0001-com-ubuntu-server-jammy"
            sku       = "22_04-lts"
            version   = "latest"
        }

        storage_os_disk {
            name              = "${var.name}-osdisk"
            caching           = "ReadWrite"
            create_option     = "FromImage"
            managed_disk_type = "Standard_LRS"
        }

        os_profile {
            computer_name  = "hostname"
            admin_username = "adminuser"
            admin_password = "P@ssw0rd1234!"
        }

        os_profile_linux_config {
            disable_password_authentication = false
        }
    }
    ```

6. Implement useful outputs:

    Add the following outputs to the `main.tf` file:

    ```hcl
    output "vm_id" {
        value = azurerm_virtual_machine.vm.id
    }

    output "vm_ip" {
        value = azurerm_network_interface.nic[0].private_ip_address
    }
    ```

    Run the following command to create the virtual machine:

    ```sh
    terraform apply
    ```

7. **Clean Up:**

   Run the following command to destroy the resources:

   ```sh
   terraform destroy
   ```
