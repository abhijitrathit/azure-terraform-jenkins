variable "location" {
  type    = string
  default = "centralindia"
}

variable "resource_group_name" {
  type = string
}

variable "create_resource_group" {
  type    = bool
  default = true
}

variable "vm_name_prefix" {
  description = "VMs are named <prefix>-1, <prefix>-2, ..."
  type        = string
}

variable "vm_count" {
  type    = number
  default = 1
}

variable "vm_size" {
  type    = string
  default = "Standard_B2s"
}

variable "admin_username" {
  type    = string
  default = "azureuser"
}

variable "ssh_public_key" {
  description = "Contents of your public key, e.g. ssh-rsa AAAA..."
  type        = string
}

variable "os_disk_size_gb" {
  type    = number
  default = 64
}

variable "os_disk_type" {
  type    = string
  default = "StandardSSD_LRS"
}

variable "image" {
  type = object({
    publisher = string
    offer     = string
    sku       = string
    version   = string
  })
  default = {
    publisher = "Canonical"
    offer     = "ubuntu-24_04-lts"
    sku       = "server"
    version   = "latest"
  }
}

variable "vnet_cidr" {
  type    = string
  default = "10.10.0.0/16"
}

variable "subnet_cidr" {
  type    = string
  default = "10.10.1.0/24"
}

variable "create_public_ip" {
  type    = bool
  default = true
}

variable "allowed_ssh_cidr" {
  description = "CIDR allowed to SSH (use your office/VPN IP, not 0.0.0.0/0)"
  type        = string
  default     = "0.0.0.0/0"
}

variable "tags" {
  type    = map(string)
  default = {}
}
