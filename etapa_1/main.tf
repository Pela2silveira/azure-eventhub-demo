resource "azurerm_resource_group" "rg" {
  name     = local.resource_group_name
  location = var.location
  tags     = local.common_tags
}

resource "azurerm_virtual_network" "logging_vnet" {
  name                = local.vnet_name
  address_space       = [var.address_space]
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  tags                = local.common_tags
}

resource "azurerm_subnet" "adh_subnet" {
  name                                          = var.adh_subnet_name
  resource_group_name                           = azurerm_resource_group.rg.name
  virtual_network_name                          = azurerm_virtual_network.logging_vnet.name
  address_prefixes                              = [local.adh_subnet_cidr]
  private_link_service_network_policies_enabled = true
}

resource "azurerm_subnet" "adx_subnet" {
  name                                          = var.adx_subnet_name
  resource_group_name                           = azurerm_resource_group.rg.name
  virtual_network_name                          = azurerm_virtual_network.logging_vnet.name
  address_prefixes                              = [local.adx_subnet_cidr]
  private_link_service_network_policies_enabled = true
}

#EVENT HUB PRIVATE LINK DNS
resource "azurerm_private_dns_zone" "dns_zone_adh" {
  name                = "privatelink.servicebus.windows.net"
  resource_group_name = azurerm_resource_group.rg.name
  tags                = local.common_tags
}

resource "azurerm_private_dns_zone_virtual_network_link" "dns_zone_adh_link" {
  name                  = "adhzone"
  resource_group_name   = azurerm_resource_group.rg.name
  private_dns_zone_name = azurerm_private_dns_zone.dns_zone_adh.name
  virtual_network_id    = azurerm_virtual_network.logging_vnet.id
  tags                  = local.common_tags
}

resource "azurerm_eventhub_namespace" "adh_ns" {
  name                          = local.adh_ns_name
  location                      = azurerm_resource_group.rg.location
  resource_group_name           = azurerm_resource_group.rg.name
  sku                           = "Standard"
  capacity                      = 1
  auto_inflate_enabled          = true
  maximum_throughput_units      = 5
  zone_redundant                = true
  public_network_access_enabled = false
  tags                          = local.common_tags
}

resource "azurerm_eventhub" "adh" {
  name                = local.adh_name
  namespace_name      = azurerm_eventhub_namespace.adh_ns.name
  resource_group_name = azurerm_resource_group.rg.name
  partition_count     = 2
  message_retention   = 7
}

resource "azurerm_eventhub_authorization_rule" "producer" {
  name                = "producer"
  namespace_name      = azurerm_eventhub_namespace.adh_ns.name
  eventhub_name       = azurerm_eventhub.adh.name
  resource_group_name = azurerm_resource_group.rg.name
  listen              = false
  send                = true
  manage              = false
}

resource "azurerm_eventhub_authorization_rule" "consumer" {
  name                = "consumer"
  namespace_name      = azurerm_eventhub_namespace.adh_ns.name
  eventhub_name       = azurerm_eventhub.adh.name
  resource_group_name = azurerm_resource_group.rg.name
  listen              = true
  send                = false
  manage              = false
}

resource "azurerm_private_endpoint" "endpoint" {
  name                = "eventhub-private-endpoint"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  subnet_id           = azurerm_subnet.adh_subnet.id

  private_dns_zone_group {
    name                 = "dns_zone_adh"
    private_dns_zone_ids = [azurerm_private_dns_zone.dns_zone_adh.id]
  }
  private_service_connection {
    name                           = "eventhubnamespace"
    private_connection_resource_id = azurerm_eventhub_namespace.adh_ns.id
    is_manual_connection           = false
    subresource_names              = ["namespace"]
  }
  tags = local.common_tags
}

resource "azurerm_kusto_cluster" "adx" {
  name                          = local.adx_name
  location                      = azurerm_resource_group.rg.location
  resource_group_name           = azurerm_resource_group.rg.name
  public_network_access_enabled = true
  allowed_ip_ranges             = var.adx_allowed_ips
  streaming_ingestion_enabled   = true
  sku {
    name     = var.adx_sku_name
    capacity = var.adx_sku_capacity
  }
  identity {
    type = "SystemAssigned"
  }
  tags = local.common_tags
}

resource "azurerm_role_assignment" "adx_to_adh_assigment" {
  scope                = azurerm_resource_group.rg.id
  role_definition_name = "Azure Event Hubs Data Receiver"
  principal_id         = azurerm_kusto_cluster.adx.identity[0].principal_id
}
