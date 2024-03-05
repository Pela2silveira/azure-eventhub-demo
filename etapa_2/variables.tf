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

variable "adx_subnet_name" {
  type        = string
  description = "Name for EventHub subnet"
  default     = "adx"
}

variable "adx_db_cache" {
  type        = string
  description = "Cache for DB in Azure Data Explorer"
  default     = "P7D"
}

variable "adx_db_name" {
  type        = string
  description = "Name for DB in Azure Data Explorer"
  default     = "adx_db"
}

variable "test_user" {
  type        = map(any)
  description = "Test user for accessing adx, needs name and principal_id fields"
}





