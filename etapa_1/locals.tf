locals {
  resources_name      = "${var.client}-${var.project}-${var.env}-${var.env_num}"
  resource_group_name = local.resources_name
  vnet_name           = local.resources_name
  adh_ns_name         = local.resources_name
  adh_name            = "${var.project}-${var.env}"
  adx_name            = "${var.project}-${var.env}-${var.env_num}"
  adh_subnet_cidr     = cidrsubnet(var.address_space, 1, 0)
  adx_subnet_cidr     = cidrsubnet(var.address_space, 1, 1)
  common_tags = {
    client     = var.client
    env        = var.env
    env_num    = var.env_num
    origin     = "tf"
    repository = var.repository
  }
}


