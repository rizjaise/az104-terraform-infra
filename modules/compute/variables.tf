variable location{}
variable resource_group_name{}
variable subnet_web_id{}
variable vm_admin_username{}
variable vm_admin_password{
    sensitive = true
}

terraform {
    required_providers {
        random = {
            source  = "hashicorp/random"
            version = "~> 3.0"
        }
    }
}