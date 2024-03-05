locals {
  resources_name      = "${var.client}-${var.project}-${var.env}-${var.env_num}"
  resource_group_name = local.resources_name
  vnet_name           = local.resources_name
  private_subnet_cidr = cidrsubnet(var.address_space, 1, 0)
  public_subnet_cidr  = cidrsubnet(var.address_space, 1, 1)

  common_tags = {
    client     = var.client
    env        = var.env
    env_num    = var.env_num
    origin     = "tf"
    repository = var.repository
  }
}


