output "data_factory_name" {
  description = "Name of the Data Factory"
  value       = azurerm_data_factory.adf.name
}

output "data_factory_id" {
  description = "ID of the Data Factory"
  value       = azurerm_data_factory.adf.id
}

output "data_factory_identity_principal_id" {
  description = "Principal ID of the Data Factory managed identity"
  value       = azurerm_data_factory.adf.identity[0].principal_id
}
