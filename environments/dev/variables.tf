variable "location" {
  default = "South India"
}

variable "environment" {
  default = "dev"
}

variable "vm_admin_username" {}
variable "vm_admin_password" {
  sensitive = true
}