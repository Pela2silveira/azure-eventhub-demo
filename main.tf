resource "azurerm_resource_group" "rg" {
  name     = local.resource_group_name
  location = var.location
  tags     = local.common_tags
}


resource "azurerm_eventhub_namespace" "demo" {
  name                = "appLogsNamespace"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  sku                 = "Standard"
  capacity            = 1

  tags = local.common_tags
}

resource "azurerm_eventhub" "demo" {
  name                = "appLogs"
  namespace_name      = azurerm_eventhub_namespace.demo.name
  resource_group_name = azurerm_resource_group.rg.name
  partition_count     = 2
  message_retention   = 1

}


resource "azurerm_eventhub_authorization_rule" "producer" {
  name                = "producer"
  namespace_name      = azurerm_eventhub_namespace.demo.name
  eventhub_name       = azurerm_eventhub.demo.name
  resource_group_name = azurerm_resource_group.rg.name
  listen              = false
  send                = true
  manage              = false
}



resource "azurerm_eventhub_authorization_rule" "consumer" {
  name                = "consumer"
  namespace_name      = azurerm_eventhub_namespace.demo.name
  eventhub_name       = azurerm_eventhub.demo.name
  resource_group_name = azurerm_resource_group.rg.name
  listen              = true
  send                = false
  manage              = false
}

output consumer_endpoint {
  value       = azurerm_eventhub_authorization_rule.consumer.primary_connection_string
  sensitive   = true
  description = "description"
}

output producer_endpoint {
  value       = azurerm_eventhub_authorization_rule.producer.primary_connection_string
  sensitive   = true
  description = "description"
}

resource "azurerm_storage_account" "demo" {
  name                     = "eventhubindex"
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = azurerm_resource_group.rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  tags = local.common_tags
}

output blob_endpoint {
  value       = azurerm_storage_account.demo.primary_connection_string
  sensitive   = true
  description = "description"
}

resource "azurerm_storage_container" "demo" {
  name                  = "index"
  storage_account_name  = azurerm_storage_account.demo.name
  container_access_type = "private"
}

resource "azurerm_storage_blob" "demo" {
  name                   = "consumer-index"
  storage_account_name   = azurerm_storage_account.demo.name
  storage_container_name = azurerm_storage_container.demo.name
  type                   = "Block"
}
