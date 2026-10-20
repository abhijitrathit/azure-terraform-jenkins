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

resource "azurerm_postgresql_flexible_server" "this" {
  name                = var.server_name
  resource_group_name = local.rg_name
  location            = local.rg_location
  version             = var.postgres_version
  sku_name            = var.sku_name
  storage_mb          = var.storage_mb

  administrator_login    = var.administrator_login
  administrator_password = var.administrator_password

  backup_retention_days         = var.backup_retention_days
  public_network_access_enabled = true

  tags = var.tags

  lifecycle {
    ignore_changes = [zone]
  }
}

resource "azurerm_postgresql_flexible_server_database" "db" {
  for_each  = toset(var.databases)
  name      = each.value
  server_id = azurerm_postgresql_flexible_server.this.id
  charset   = "UTF8"
  collation = "en_US.utf8"
}

resource "azurerm_postgresql_flexible_server_firewall_rule" "rule" {
  for_each         = var.firewall_rules
  name             = each.key
  server_id        = azurerm_postgresql_flexible_server.this.id
  start_ip_address = each.value.start_ip
  end_ip_address   = each.value.end_ip
}
