output "app_insights_id" {
  description = "ID of the Application Insights"
  value       = azurerm_application_insights.app_insights.id
}

output "app_insights_name" {
  description = "Name of the Application Insights"
  value       = azurerm_application_insights.app_insights.name
}

output "instrumentation_key" {
  description = "Instrumentation key of the Application Insights"
  value       = azurerm_application_insights.app_insights.instrumentation_key
  sensitive   = true
}

output "connection_string" {
  description = "Connection string of the Application Insights"
  value       = azurerm_application_insights.app_insights.connection_string
  sensitive   = true
}
