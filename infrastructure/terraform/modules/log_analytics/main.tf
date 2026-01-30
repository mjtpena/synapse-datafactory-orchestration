resource "azurerm_log_analytics_workspace" "log_analytics" {
  name                = "log-${var.project_name}-${var.environment}-${var.unique_suffix}"
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = "PerGB2018"
  retention_in_days   = 30

  tags = merge(
    var.tags,
    {
      Purpose = "Monitoring"
    }
  )
}
