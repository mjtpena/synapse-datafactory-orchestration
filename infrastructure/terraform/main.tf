terraform {
  required_version = ">= 1.5.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.80"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.5"
    }
  }

  # Uncomment for remote state storage
  # backend "azurerm" {
  #   resource_group_name  = "terraform-state-rg"
  #   storage_account_name = "tfstate"
  #   container_name       = "tfstate"
  #   key                  = "synapse-datafactory.terraform.tfstate"
  # }
}

provider "azurerm" {
  features {
    key_vault {
      purge_soft_delete_on_destroy = true
    }
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

# Random suffix for unique resource names
resource "random_string" "suffix" {
  length  = 8
  special = false
  upper   = false
}

# Resource Group
resource "azurerm_resource_group" "rg" {
  name     = "rg-${var.project_name}-${var.environment}"
  location = var.location

  tags = var.common_tags
}

# Storage Account (Data Lake Gen2)
module "storage" {
  source = "./modules/storage"

  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  project_name        = var.project_name
  environment         = var.environment
  unique_suffix       = random_string.suffix.result
  tags                = var.common_tags
}

# Key Vault
module "keyvault" {
  source = "./modules/keyvault"

  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  project_name        = var.project_name
  environment         = var.environment
  unique_suffix       = random_string.suffix.result
  tags                = var.common_tags
}

# Log Analytics Workspace
module "log_analytics" {
  source = "./modules/log_analytics"

  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  project_name        = var.project_name
  environment         = var.environment
  unique_suffix       = random_string.suffix.result
  tags                = var.common_tags
}

# Application Insights
module "app_insights" {
  source = "./modules/app_insights"

  resource_group_name         = azurerm_resource_group.rg.name
  location                    = azurerm_resource_group.rg.location
  project_name                = var.project_name
  environment                 = var.environment
  unique_suffix               = random_string.suffix.result
  log_analytics_workspace_id  = module.log_analytics.workspace_id
  tags                        = var.common_tags
}

# Data Factory
module "data_factory" {
  source = "./modules/data_factory"
  count  = var.enable_data_factory ? 1 : 0

  resource_group_name         = azurerm_resource_group.rg.name
  location                    = azurerm_resource_group.rg.location
  project_name                = var.project_name
  environment                 = var.environment
  unique_suffix               = random_string.suffix.result
  log_analytics_workspace_id  = module.log_analytics.workspace_id
  tags                        = var.common_tags
}

# Synapse Workspace
module "synapse" {
  source = "./modules/synapse"
  count  = var.enable_synapse ? 1 : 0

  resource_group_name         = azurerm_resource_group.rg.name
  location                    = azurerm_resource_group.rg.location
  project_name                = var.project_name
  environment                 = var.environment
  unique_suffix               = random_string.suffix.result
  storage_account_name        = module.storage.storage_account_name
  storage_account_id          = module.storage.storage_account_id
  log_analytics_workspace_id  = module.log_analytics.workspace_id
  sql_administrator_login     = var.synapse_sql_admin_login
  synapse_admin_object_id     = var.synapse_admin_object_id
  tags                        = var.common_tags
}
