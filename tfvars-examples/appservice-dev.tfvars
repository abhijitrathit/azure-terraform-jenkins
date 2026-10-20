location              = "centralindia"
resource_group_name   = "rg-app-dev"
create_resource_group = true

app_service_plan_name = "asp-myapp-dev"
app_name              = "mycompany-myapp-dev-001"
sku_name              = "B1"

runtime_stack   = "node"
runtime_version = "20-lts"

app_settings = {
  ENVIRONMENT = "dev"
}

tags = {
  environment = "dev"
  owner       = "platform-team"
}
