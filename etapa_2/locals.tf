locals {
  resources_name      = "${var.client}-${var.project}-${var.env}-${var.env_num}"
  resource_group_name = local.resources_name
  vnet_name           = local.resources_name
  adh_ns_name         = local.resources_name
  adh_name            = "${var.project}-${var.env}"
  adx_name            = "${var.project}-${var.env}-${var.env_num}"
  table_name          = "logs"
  mapping_name        = "mapping"
  common_tags = {
    client     = var.client
    env        = var.env
    env_num    = var.env_num
    origin     = "tf"
    repository = var.repository
  }
}


