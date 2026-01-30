resource "azurerm_synapse_workspace" "synapse" {
  name                                 = "syn-${var.project_name}-${var.environment}-${var.unique_suffix}"
  resource_group_name                  = var.resource_group_name
  location                             = var.location
  storage_data_lake_gen2_filesystem_id = azurerm_storage_data_lake_gen2_filesystem.synapse_fs.id
  sql_administrator_login              = var.sql_administrator_login
  sql_administrator_login_password     = random_password.synapse_sql_password.result

  identity {
    type = "SystemAssigned"
  }

  managed_resource_group_name = "syn-${var.project_name}-${var.environment}-${var.unique_suffix}-managed-rg"

  tags = merge(
    var.tags,
    {
      Purpose = "DataAnalytics"
    }
  )
}

resource "random_password" "synapse_sql_password" {
  length  = 16
  special = true
}

resource "azurerm_storage_data_lake_gen2_filesystem" "synapse_fs" {
  name               = "synapse"
  storage_account_id = var.storage_account_id
}

# Grant Synapse workspace Storage Blob Data Contributor on the storage account
resource "azurerm_role_assignment" "synapse_storage" {
  scope                = var.storage_account_id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = azurerm_synapse_workspace.synapse.identity[0].principal_id
}

# Firewall rule to allow Azure services
resource "azurerm_synapse_firewall_rule" "allow_azure_services" {
  name                 = "AllowAllWindowsAzureIps"
  synapse_workspace_id = azurerm_synapse_workspace.synapse.id
  start_ip_address     = "0.0.0.0"
  end_ip_address       = "0.0.0.0"
}

# Synapse Spark Pool
resource "azurerm_synapse_spark_pool" "spark_pool" {
  name                 = "sparkpool01"
  synapse_workspace_id = azurerm_synapse_workspace.synapse.id
  node_size_family     = "MemoryOptimized"
  node_size            = "Small"
  node_count           = 3

  auto_scale {
    min_node_count = 3
    max_node_count = 10
  }

  auto_pause {
    delay_in_minutes = 15
  }

  spark_version = "3.4"

  dynamic_executor_allocation {
    enabled             = true
    min_executors       = 1
    max_executors       = 10
  }

  tags = var.tags
}

# Diagnostic settings for Synapse Workspace
resource "azurerm_monitor_diagnostic_setting" "synapse_diagnostics" {
  name                       = "${azurerm_synapse_workspace.synapse.name}-diagnostics"
  target_resource_id         = azurerm_synapse_workspace.synapse.id
  log_analytics_workspace_id = var.log_analytics_workspace_id

  enabled_log {
    category = "SynapseRbacOperations"
  }

  enabled_log {
    category = "GatewayApiRequests"
  }

  enabled_log {
    category = "SQLSecurityAuditEvents"
  }

  enabled_log {
    category = "BuiltinSqlReqsEnded"
  }

  enabled_log {
    category = "IntegrationPipelineRuns"
  }

  enabled_log {
    category = "IntegrationActivityRuns"
  }

  enabled_log {
    category = "IntegrationTriggerRuns"
  }

  metric {
    category = "AllMetrics"
    enabled  = true
  }
}
