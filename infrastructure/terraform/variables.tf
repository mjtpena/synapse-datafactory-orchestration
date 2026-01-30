variable "location" {
  description = "Azure region for resources"
  type        = string
  default     = "australiaeast"
}

variable "environment" {
  description = "Environment name (dev, test, prod)"
  type        = string
  default     = "dev"

  validation {
    condition     = contains(["dev", "test", "prod"], var.environment)
    error_message = "Environment must be dev, test, or prod."
  }
}

variable "project_name" {
  description = "Project name prefix for resources"
  type        = string
  default     = "synapse-df"
}

variable "enable_data_factory" {
  description = "Enable Azure Data Factory deployment"
  type        = bool
  default     = true
}

variable "enable_synapse" {
  description = "Enable Synapse Workspace deployment"
  type        = bool
  default     = true
}

variable "synapse_sql_admin_login" {
  description = "SQL Administrator login for Synapse"
  type        = string
  default     = "sqladmin"
  sensitive   = true
}

variable "synapse_admin_object_id" {
  description = "Azure AD Object ID for Synapse Admin"
  type        = string
}

variable "common_tags" {
  description = "Common tags for all resources"
  type        = map(string)
  default = {
    Project     = "Synapse Data Factory Orchestration"
    ManagedBy   = "Terraform"
    Environment = "dev"
  }
}
