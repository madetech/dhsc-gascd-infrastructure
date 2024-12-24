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

variable "dbx_spark_version" {
  default = "15.4.x-scala2.12"
}

variable "dbx_spark_version_gpu" {
  default = "16.0.x-gpu-ml-scala2.12"
}
