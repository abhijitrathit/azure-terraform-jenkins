output "app_url" {
  value = "https://${azurerm_linux_web_app.this.default_hostname}"
}

output "app_id" {
  value = azurerm_linux_web_app.this.id
}

output "service_plan_id" {
  value = azurerm_service_plan.this.id
}
