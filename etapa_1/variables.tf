variable "subscription_id" {
  type        = string
  description = "The Azure subscription ID."
}
variable "client_id" {
  description = "The Azure Service Principal app ID."
  type        = string
}
variable "client_secret" {
  description = "The Azure Service Principal password."
  type        = string
}

variable "tenant_id" {
  description = "The Azure Tenant ID."
  type        = string
}

variable "location" {
  description = "The Azure location where all resources in this example should be created."
  default     = "eastus"
  type        = string
}

variable "client" {
  description = "The name of the client. Value can be 'shared'."
  type        = string
}

variable "project" {
  description = "The name of the project. Value can be 'shared'."
  type        = string
}

variable "env" {
  description = "The name of the environment. Value can be 'shared'."
  type        = string
}

variable "env_num" {
  description = "Should be used every time. Is a value needed for differentiate two environments with same values for client-project-env dimensions"
  type        = string
  default     = "01"
}

variable "repository" {
  type        = string
  description = "The url used for managing this resource"
}

variable "address_space" {
  type        = string
  description = "Address space for VNET"
}

variable "adx_subnet_name" {
  type        = string
  description = "Name for EventHub subnet"
  default     = "adx"
}

variable "adh_subnet_name" {
  type        = string
  description = "Name for Data Explorer subnet"
  default     = "adh"
}

variable "adx_allowed_ips" {
  type        = list(string)
  description = "List of allowed publics IP's for Data Explorer"
}

variable "adx_sku_name" {
  type        = string
  description = "SKU Name of Data Explorer"
}
variable "adx_sku_capacity" {
  type        = string
  description = "SKU Capacity of Data Explorer"
}
