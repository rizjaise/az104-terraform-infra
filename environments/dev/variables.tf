variable "location" {
  default = "East US"
}

variable "environment" {
  default = "dev"
}

variable "vm_admin_username" {}
variable "vm_admin_password" {
  sensitive = true
}

variable "hspecter_upn" {}
variable "mross_upn" {}