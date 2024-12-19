# Variables - move to seperate file when too many
variable "resource_prefix" {
  description = "Prefix for all resources"
  default     = "dapalpha"
}

variable "environment" {
  type        = string
  description = "Deployment environment"
  default     = "dev"
}

variable "location" {
  type        = string
  description = "Azure deployment Region"
  default     = "UK South"
}

variable "docker_frontend_image" {
  type        = string
  description = "Name of the frontend docker image"
  default     = "dapalpha"
}

variable "azure_msi_flag" {
  type    = bool
  default = false
}

variable "subscription_id" {
  type = string
}