variable "subscription_id" {
  description = "Azure Subscription ID to deploy into"
  type        = string
}

variable "project" {
  description = "Short name for tagging and resource naming."
  type        = string
  default     = "cloudInfra"
}

variable "resource_group_name" {
  description = "Name of existing resource group to deploy into"
  type        = string
  default     = "automation_ca"
}

variable "location" {
  description = "Azure region where resources will be deployed."
  type        = string
  default     = "francecentral"
}

variable "admin_username" {
  description = "Admin username for SSH access to the VM."
  type        = string
  default     = "ezzwk"
}

variable "ssh_public_key" {
  description = "Your SSH public key for secure login."
  type        = string
  sensitive   = true
}

variable "allowed_ssh_cidr" {
  description = "Which IP(s) are allowed to SSH into the VM."
  type        = string
  default     = "0.0.0.0/0" # Replace with your own IP/32 for better security
}

variable "vm_size" {
  description = "Azure VM size (RAM/CPU configuration)."
  type        = string
  default     = "Standard_B1s"
}
