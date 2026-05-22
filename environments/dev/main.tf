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
    location = "South India"
  }

  module "networking" {
    source              = "../../modules/networking"
    location            = var.location
    resource_group_name = azurerm_resource_group.rg.name
  }