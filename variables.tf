# ============================================================================
# VARIABLES
# ============================================================================

variable "location" {
  description = "Azure region for deployments."
  type        = string
  default     = "swedencentral"
}

variable "resource_group_name" {
  description = "Resource group name for all resources."
  type        = string
  default     = "rg-group5-sch"
}

variable "subscription_id" {
  description = "Azure subscription ID."
  type        = string
}

variable "client_id" {
  description = "Client ID for authentication."
  type        = string
  sensitive   = true
}

variable "tenant_id" {
  description = "Azure tenant ID."
  type        = string
  sensitive   = true
}
