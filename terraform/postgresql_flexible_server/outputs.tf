output "server_fqdn" {
  value = azurerm_postgresql_flexible_server.this.fqdn
}

output "server_id" {
  value = azurerm_postgresql_flexible_server.this.id
}

output "databases" {
  value = [for d in azurerm_postgresql_flexible_server_database.db : d.name]
}
