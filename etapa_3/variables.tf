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

variable "repo" {
  description = "The app repo."
  type        = string
}

variable "tenant_id" {
  description = "The Azure Tenant ID."
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
  description = "The address space for VNET"
}