terraform {
  required_providers {
    azurerm = {
        source = "hashicorp/azurerm"
        version = "~> 3.0"
    }
  }
  backend "azurerm" {
    
  }
}

  provider "azurerm" {
    features {}
  }

  resource "azurerm_resource_group" "rg" {
    name     = "SpecterRG-Dev"
    location = "East US"
  }

  module "networking" {
    source              = "../../modules/networking"
    location            = var.location
    resource_group_name = azurerm_resource_group.rg.name
  }

  module "compute" {
    source = "../../modules/compute"
    location            = var.location
    resource_group_name = azurerm_resource_group.rg.name
    subnet_web_id       = module.networking.subnet_web_id
    vm_admin_username   = var.vm_admin_username
    vm_admin_password   = var.vm_admin_password

  }

  module "storage" {
    source = "../../modules/storage"
    location            = var.location
    resource_group_name = azurerm_resource_group.rg.name
  }