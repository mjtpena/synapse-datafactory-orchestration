variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
}

variable "location" {
  description = "Azure region"
  type        = string
}

variable "project_name" {
  description = "Project name prefix"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "unique_suffix" {
  description = "Unique suffix for resource names"
  type        = string
}

variable "storage_account_name" {
  description = "Name of the storage account"
  type        = string
}

variable "storage_account_id" {
  description = "ID of the storage account"
  type        = string
}

variable "log_analytics_workspace_id" {
  description = "Log Analytics Workspace ID"
  type        = string
}

variable "sql_administrator_login" {
  description = "SQL Administrator login"
  type        = string
  sensitive   = true
}

variable "synapse_admin_object_id" {
  description = "Azure AD Object ID for Synapse Admin"
  type        = string
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
}
