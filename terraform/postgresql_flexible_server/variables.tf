variable "location" {
  type    = string
  default = "centralindia"
}

variable "resource_group_name" {
  type = string
}

variable "create_resource_group" {
  description = "true = create the RG, false = use an existing one"
  type        = bool
  default     = true
}

variable "server_name" {
  description = "Globally unique PostgreSQL server name"
  type        = string
}

variable "postgres_version" {
  type    = string
  default = "16"
}

variable "sku_name" {
  description = "e.g. B_Standard_B1ms, GP_Standard_D2s_v3"
  type        = string
  default     = "B_Standard_B1ms"
}

variable "storage_mb" {
  type    = number
  default = 32768
}

variable "backup_retention_days" {
  type    = number
  default = 7
}

variable "administrator_login" {
  type    = string
  default = "pgadmin"
}

# Supplied by Jenkins as TF_VAR_administrator_password (never put it in tfvars)
variable "administrator_password" {
  type      = string
  sensitive = true
}

variable "databases" {
  description = "List of databases to create"
  type        = list(string)
  default     = []
}

variable "firewall_rules" {
  description = "Map of name => { start_ip, end_ip }"
  type = map(object({
    start_ip = string
    end_ip   = string
  }))
  default = {}
}

variable "tags" {
  type    = map(string)
  default = {}
}
