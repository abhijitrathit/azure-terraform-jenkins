resource "azurerm_resource_group" "this" {
  count    = var.create_resource_group ? 1 : 0
  name     = var.resource_group_name
  location = var.location
  tags     = var.tags
}

data "azurerm_resource_group" "existing" {
  count = var.create_resource_group ? 0 : 1
  name  = var.resource_group_name
}

locals {
  rg_name     = var.create_resource_group ? azurerm_resource_group.this[0].name : data.azurerm_resource_group.existing[0].name
  rg_location = var.create_resource_group ? azurerm_resource_group.this[0].location : data.azurerm_resource_group.existing[0].location
}

resource "azurerm_service_plan" "this" {
  name                = var.app_service_plan_name
  resource_group_name = local.rg_name
  location            = local.rg_location
  os_type             = "Linux"
  sku_name            = var.sku_name
  tags                = var.tags
}

resource "azurerm_linux_web_app" "this" {
  name                = var.app_name
  resource_group_name = local.rg_name
  location            = local.rg_location
  service_plan_id     = azurerm_service_plan.this.id
  https_only          = var.https_only
  app_settings        = var.app_settings
  tags                = var.tags

  site_config {
    always_on = var.always_on

    application_stack {
      node_version   = var.runtime_stack == "node" ? var.runtime_version : null
      python_version = var.runtime_stack == "python" ? var.runtime_version : null
      dotnet_version = var.runtime_stack == "dotnet" ? var.runtime_version : null
    }
  }
}
