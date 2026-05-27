terraform {
  required_providers {
    azurerm = {
        source = "hashicorp/azurerm"
        version = "~> 3.0"
    }

    azuread = {
      source  = "hashicorp/azuread"
      version = "~> 2.0"
    }

    random = {
      source = "hashicorp/random"
      version = "~> 3.0"
    }
  }
  backend "azurerm" {
    resource_group_name  = "rg-tfstate"
    storage_account_name = "rizjaisetfstate"
    container_name       = "tfstate"
    key                  = "dev.terraform.tfstate"
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

  module "identity" {
    source = "../../modules/identity"
    location            = var.location
    resource_group_id   = azurerm_resource_group.rg.id
    resource_group_name = azurerm_resource_group.rg.name
    storage_account_id  = module.storage.storage_account_id
    hspecter_upn        = var.hspecter_upn
    mross_upn           = var.mross_upn
  }

