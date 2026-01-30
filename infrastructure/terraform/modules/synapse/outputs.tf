output "workspace_name" {
  description = "Name of the Synapse workspace"
  value       = azurerm_synapse_workspace.synapse.name
}

output "workspace_id" {
  description = "ID of the Synapse workspace"
  value       = azurerm_synapse_workspace.synapse.id
}

output "workspace_identity_principal_id" {
  description = "Principal ID of the Synapse workspace managed identity"
  value       = azurerm_synapse_workspace.synapse.identity[0].principal_id
}

output "spark_pool_name" {
  description = "Name of the Spark pool"
  value       = azurerm_synapse_spark_pool.spark_pool.name
}
