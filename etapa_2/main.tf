data "azurerm_resource_group" "rg" {
  name = local.resource_group_name
}

data "azurerm_kusto_cluster" "adx" {
  name                = local.adx_name
  resource_group_name = data.azurerm_resource_group.rg.name
}

data "azurerm_virtual_network" "logging_vnet" {
  name                = local.vnet_name
  resource_group_name = data.azurerm_resource_group.rg.name
}

data "azurerm_subnet" "adx_subnet" {
  name                 = var.adx_subnet_name
  virtual_network_name = data.azurerm_virtual_network.logging_vnet.name
  resource_group_name  = data.azurerm_resource_group.rg.name
}

data "azurerm_eventhub_namespace" "adh_ns" {
  name                = local.adh_ns_name
  resource_group_name = data.azurerm_resource_group.rg.name
}

data "azurerm_eventhub" "adh" {
  name                = local.adh_name
  resource_group_name = data.azurerm_resource_group.rg.name
  namespace_name      = data.azurerm_eventhub_namespace.adh_ns.name
}

resource "azurerm_kusto_database" "adx_db" {
  name                = var.adx_db_name
  resource_group_name = data.azurerm_resource_group.rg.name
  location            = data.azurerm_resource_group.rg.location
  cluster_name        = data.azurerm_kusto_cluster.adx.name
  hot_cache_period    = var.adx_db_cache
}

#ADX Private Link DNS
resource "azurerm_private_dns_zone" "dns_zone_adx_1" {
  name                = "privatelink.eastus.kusto.windows.net"
  resource_group_name = data.azurerm_resource_group.rg.name
  tags                = local.common_tags
}

resource "azurerm_private_dns_zone_virtual_network_link" "dns_zone_adx_link_1" {
  name                  = "adxzone1"
  resource_group_name   = data.azurerm_resource_group.rg.name
  private_dns_zone_name = azurerm_private_dns_zone.dns_zone_adx_1.name
  virtual_network_id    = data.azurerm_virtual_network.logging_vnet.id
}

resource "azurerm_private_dns_zone" "dns_zone_adx_2" {
  name                = "privatelink.blob.core.windows.net"
  resource_group_name = data.azurerm_resource_group.rg.name
  tags                = local.common_tags
}

resource "azurerm_private_dns_zone_virtual_network_link" "dns_zone_adx_link_2" {
  name                  = "adxzone2"
  resource_group_name   = data.azurerm_resource_group.rg.name
  private_dns_zone_name = azurerm_private_dns_zone.dns_zone_adx_2.name
  virtual_network_id    = data.azurerm_virtual_network.logging_vnet.id
}

resource "azurerm_private_dns_zone" "dns_zone_adx_3" {
  name                = "privatelink.queue.core.windows.net"
  resource_group_name = data.azurerm_resource_group.rg.name
  tags                = local.common_tags
}
resource "azurerm_private_dns_zone_virtual_network_link" "dns_zone_adx_link_3" {
  name                  = "adxzone3"
  resource_group_name   = data.azurerm_resource_group.rg.name
  private_dns_zone_name = azurerm_private_dns_zone.dns_zone_adx_3.name
  virtual_network_id    = data.azurerm_virtual_network.logging_vnet.id
}
resource "azurerm_private_dns_zone" "dns_zone_adx_4" {
  name                = "privatelink.table.core.windows.net"
  resource_group_name = data.azurerm_resource_group.rg.name
  tags                = local.common_tags
}

resource "azurerm_private_dns_zone_virtual_network_link" "dns_zone_adx_link_4" {
  name                  = "adxzone4"
  resource_group_name   = data.azurerm_resource_group.rg.name
  private_dns_zone_name = azurerm_private_dns_zone.dns_zone_adx_4.name
  virtual_network_id    = data.azurerm_virtual_network.logging_vnet.id
}

#crear la tabla y el mapeo
resource "azurerm_kusto_script" "create_table" {
  name           = "create_table"
  database_id    = azurerm_kusto_database.adx_db.id
  script_content = <<EOT
.create table ['${local.table_name}']  (['_timestamp']:real, ['alive']:bool, ['proc_name']:string, ['pid']:int, ['mem.VmPeak']:long, ['mem.VmSize']:long, ['mem.VmLck']:long, ['mem.VmHWM']:int, ['mem.VmRSS']:long, ['mem.VmData']:long, ['mem.VmStk']:long, ['mem.VmExe']:long, ['mem.VmLib']:long, ['mem.VmPTE']:long, ['mem.VmSwap']:long, ['fd']:int)
EOT
  depends_on     = [azurerm_kusto_database.adx_db]
}

resource "azurerm_kusto_script" "create_mapping" {
  name           = "create_mapping"
  database_id    = azurerm_kusto_database.adx_db.id
  script_content = <<EOT
  .create table ['${local.table_name}'] ingestion json mapping '${local.mapping_name}' '[{"column":"_timestamp", "Properties":{"Path":"$[\'@timestamp\']"}},{"column":"alive", "Properties":{"Path":"$[\'alive\']"}},{"column":"proc_name", "Properties":{"Path":"$[\'proc_name\']"}},{"column":"pid", "Properties":{"Path":"$[\'pid\']"}},{"column":"mem.VmPeak", "Properties":{"Path":"$[\'mem.VmPeak\']"}},{"column":"mem.VmSize", "Properties":{"Path":"$[\'mem.VmSize\']"}},{"column":"mem.VmLck", "Properties":{"Path":"$[\'mem.VmLck\']"}},{"column":"mem.VmHWM", "Properties":{"Path":"$[\'mem.VmHWM\']"}},{"column":"mem.VmRSS", "Properties":{"Path":"$[\'mem.VmRSS\']"}},{"column":"mem.VmData", "Properties":{"Path":"$[\'mem.VmData\']"}},{"column":"mem.VmStk", "Properties":{"Path":"$[\'mem.VmStk\']"}},{"column":"mem.VmExe", "Properties":{"Path":"$[\'mem.VmExe\']"}},{"column":"mem.VmLib", "Properties":{"Path":"$[\'mem.VmLib\']"}},{"column":"mem.VmPTE", "Properties":{"Path":"$[\'mem.VmPTE\']"}},{"column":"mem.VmSwap", "Properties":{"Path":"$[\'mem.VmSwap\']"}},{"column":"fd", "Properties":{"Path":"$[\'fd\']"}}]'
  EOT
  depends_on     = [azurerm_kusto_script.create_table]
}

resource "azurerm_private_endpoint" "endpoint_adx" {
  name                = data.azurerm_kusto_cluster.adx.name
  location            = data.azurerm_resource_group.rg.location
  resource_group_name = data.azurerm_resource_group.rg.name
  subnet_id           = data.azurerm_subnet.adx_subnet.id

  private_dns_zone_group {
    name                 = "dns-zone-group"
    private_dns_zone_ids = [azurerm_private_dns_zone.dns_zone_adx_1.id, azurerm_private_dns_zone.dns_zone_adx_2.id, azurerm_private_dns_zone.dns_zone_adx_3.id, azurerm_private_dns_zone.dns_zone_adx_4.id]
  }

  private_service_connection {
    name                           = "adx-private-link"
    private_connection_resource_id = data.azurerm_kusto_cluster.adx.id
    is_manual_connection           = false
    subresource_names              = ["cluster"]
  }

  depends_on = [azurerm_kusto_script.create_table, azurerm_kusto_script.create_mapping]
  tags       = local.common_tags
}

resource "azurerm_kusto_cluster_managed_private_endpoint" "adh_managed_endpoint" {
  cluster_name                 = data.azurerm_kusto_cluster.adx.name
  group_id                     = "namespace"
  name                         = "adh-managed-endpoint"
  private_link_resource_id     = data.azurerm_eventhub_namespace.adh_ns.id
  private_link_resource_region = data.azurerm_resource_group.rg.location
  request_message              = "Please approve"
  resource_group_name          = data.azurerm_resource_group.rg.name
  depends_on                   = [azurerm_private_endpoint.endpoint_adx]
}

#crear el permiso de psilveira (cambiar por el actual que es el de terraform)
resource "azurerm_kusto_cluster_principal_assignment" "adx_user_assignment" {
  cluster_name        = data.azurerm_kusto_cluster.adx.name
  name                = var.test_user.name
  principal_id        = var.test_user.principal_id
  principal_type      = "User"
  resource_group_name = data.azurerm_resource_group.rg.name
  role                = "AllDatabasesAdmin"
  tenant_id           = var.tenant_id
}

#crear la conexion de datos
resource "azurerm_kusto_eventhub_data_connection" "adx_adh_data_connection" {
  cluster_name        = data.azurerm_kusto_cluster.adx.name
  consumer_group      = "$Default"
  data_format         = "MULTIJSON"
  database_name       = azurerm_kusto_database.adx_db.name
  eventhub_id         = data.azurerm_eventhub.adh.id
  identity_id         = data.azurerm_kusto_cluster.adx.id
  location            = data.azurerm_resource_group.rg.location
  mapping_rule_name   = local.mapping_name
  name                = "adhconnection"
  resource_group_name = data.azurerm_resource_group.rg.name
  table_name          = local.table_name
  depends_on = [
    azurerm_kusto_database.adx_db,
    azurerm_kusto_cluster_managed_private_endpoint.adh_managed_endpoint
  ]
}

#auto aprobar el managed endpoint
data "azapi_resource_list" "private_endpoint_list" {
  type                   = "Microsoft.EventHub/Namespaces/PrivateEndpointConnections@2021-11-01"
  parent_id              = data.azurerm_eventhub_namespace.adh_ns.id
  response_export_values = ["value"]
  depends_on             = [azurerm_kusto_cluster_managed_private_endpoint.adh_managed_endpoint]
}

locals {
  parsed_json = jsondecode(data.azapi_resource_list.private_endpoint_list.output)
  pending_items = [for item in local.parsed_json.value : item.properties.privateLinkServiceConnectionState.status == "Pending" ? item : null]
  compacted_pending_items = [for item in local.pending_items : item if item != null]
}

resource "azapi_update_resource" "approval" {
  type      = "Microsoft.EventHub/Namespaces/PrivateEndpointConnections@2021-11-01"
  name      = try(local.compacted_pending_items[0].name, "dummy")
  parent_id = data.azurerm_eventhub_namespace.adh_ns.id
  body = jsonencode({
    properties = {
      privateLinkServiceConnectionState = {
        description = "Approved via Terraform"
        status      = "Approved"
      }
    }
  })
  depends_on = [data.azapi_resource_list.private_endpoint_list]
  lifecycle {
    ignore_changes = [name]
  }
}

resource "azurerm_kusto_script" "enable_streaming" {
  name           = "enable_streaming"
  database_id    = azurerm_kusto_database.adx_db.id
  script_content = <<EOT
.alter database ${azurerm_kusto_database.adx_db.name} policy streamingingestion enable
EOT
  depends_on     = [azapi_update_resource.approval]
}






