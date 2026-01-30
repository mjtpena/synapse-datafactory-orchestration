data "azurerm_client_config" "current" {}

resource "azurerm_key_vault" "kv" {
  name                       = "kv-${var.project_name}-${var.environment}-${substr(var.unique_suffix, 0, 6)}"
  location                   = var.location
  resource_group_name        = var.resource_group_name
  tenant_id                  = data.azurerm_client_config.current.tenant_id
  sku_name                   = "standard"
  soft_delete_retention_days = 7
  purge_protection_enabled   = true
  enable_rbac_authorization  = true

  network_acls {
    default_action = "Allow" # Change to "Deny" for production
    bypass         = "AzureServices"
  }

  tags = merge(
    var.tags,
    {
      Purpose = "SecretsManagement"
    }
  )
}
