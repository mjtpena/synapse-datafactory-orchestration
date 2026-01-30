output "resource_group_name" {
  description = "Name of the resource group"
  value       = azurerm_resource_group.rg.name
}

output "storage_account_name" {
  description = "Name of the storage account"
  value       = module.storage.storage_account_name
}

output "storage_account_id" {
  description = "ID of the storage account"
  value       = module.storage.storage_account_id
}

output "key_vault_name" {
  description = "Name of the Key Vault"
  value       = module.keyvault.key_vault_name
}

output "key_vault_uri" {
  description = "URI of the Key Vault"
  value       = module.keyvault.key_vault_uri
}

output "log_analytics_workspace_id" {
  description = "ID of the Log Analytics workspace"
  value       = module.log_analytics.workspace_id
}

output "app_insights_instrumentation_key" {
  description = "Application Insights instrumentation key"
  value       = module.app_insights.instrumentation_key
  sensitive   = true
}

output "data_factory_name" {
  description = "Name of the Data Factory"
  value       = var.enable_data_factory ? module.data_factory[0].data_factory_name : null
}

output "data_factory_id" {
  description = "ID of the Data Factory"
  value       = var.enable_data_factory ? module.data_factory[0].data_factory_id : null
}

output "synapse_workspace_name" {
  description = "Name of the Synapse workspace"
  value       = var.enable_synapse ? module.synapse[0].workspace_name : null
}

output "synapse_workspace_id" {
  description = "ID of the Synapse workspace"
  value       = var.enable_synapse ? module.synapse[0].workspace_id : null
}
