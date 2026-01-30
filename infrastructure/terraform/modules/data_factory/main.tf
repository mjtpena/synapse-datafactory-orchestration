resource "azurerm_data_factory" "adf" {
  name                = "adf-${var.project_name}-${var.environment}-${var.unique_suffix}"
  location            = var.location
  resource_group_name = var.resource_group_name

  identity {
    type = "SystemAssigned"
  }

  public_network_enabled = true

  tags = merge(
    var.tags,
    {
      Purpose = "DataOrchestration"
    }
  )
}

# Diagnostic settings for Data Factory
resource "azurerm_monitor_diagnostic_setting" "adf_diagnostics" {
  name                       = "${azurerm_data_factory.adf.name}-diagnostics"
  target_resource_id         = azurerm_data_factory.adf.id
  log_analytics_workspace_id = var.log_analytics_workspace_id

  enabled_log {
    category = "ActivityRuns"
  }

  enabled_log {
    category = "PipelineRuns"
  }

  enabled_log {
    category = "TriggerRuns"
  }

  metric {
    category = "AllMetrics"
    enabled  = true
  }
}
