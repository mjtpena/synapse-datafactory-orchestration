resource "azurerm_application_insights" "app_insights" {
  name                = "appi-${var.project_name}-${var.environment}-${var.unique_suffix}"
  location            = var.location
  resource_group_name = var.resource_group_name
  application_type    = "web"
  workspace_id        = var.log_analytics_workspace_id

  tags = merge(
    var.tags,
    {
      Purpose = "ApplicationMonitoring"
    }
  )
}
