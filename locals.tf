locals {
  resources_name      = "${var.client}-${var.project}-${var.env}-${var.env_num}"
  resource_group_name = local.resources_name
  vnet_name           = local.resources_name
  public_ip_name      = local.resources_name
  apigw_name          = local.resources_name


  common_tags = {
    client     = var.client
    env        = var.env
    env_num    = var.env_num
    origin     = "tf"
    repository = var.repository
  }
}


