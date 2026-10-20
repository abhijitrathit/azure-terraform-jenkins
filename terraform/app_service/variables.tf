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

variable "app_service_plan_name" {
  type = string
}

variable "app_name" {
  description = "Globally unique web app name (becomes <name>.azurewebsites.net)"
  type        = string
}

variable "sku_name" {
  description = "e.g. B1, S1, P1v3"
  type        = string
  default     = "B1"
}

variable "runtime_stack" {
  description = "node | python | dotnet"
  type        = string
  default     = "node"

  validation {
    condition     = contains(["node", "python", "dotnet"], var.runtime_stack)
    error_message = "runtime_stack must be node, python or dotnet."
  }
}

variable "runtime_version" {
  description = "node: 20-lts | python: 3.12 | dotnet: 8.0"
  type        = string
  default     = "20-lts"
}

variable "https_only" {
  type    = bool
  default = true
}

variable "always_on" {
  description = "Must be false on the Free/F1 tier"
  type        = bool
  default     = true
}

variable "app_settings" {
  type    = map(string)
  default = {}
}

variable "tags" {
  type    = map(string)
  default = {}
}
