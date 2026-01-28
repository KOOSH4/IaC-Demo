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

variable "admin_username" {
  description = "Admin username for the VM."
  type        = string
  sensitive   = true
}

variable "admin_password" {
  description = "Admin password for the VM."
  default     = "Password123$$"
  type        = string
  sensitive   = true
}
