location              = "centralindia"
resource_group_name   = "rg-pg-dev"
create_resource_group = true

server_name           = "mycompany-pg-dev-001"
postgres_version      = "16"
sku_name              = "B_Standard_B1ms"
storage_mb            = 32768
backup_retention_days = 7
administrator_login   = "pgadmin"

databases = ["appdb", "reportsdb"]

firewall_rules = {
  office = { start_ip = "203.0.113.10", end_ip = "203.0.113.10" }
}

tags = {
  environment = "dev"
  owner       = "platform-team"
}
