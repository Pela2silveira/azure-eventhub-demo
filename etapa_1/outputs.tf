output "consumer_endpoint" {
  value       = azurerm_eventhub_authorization_rule.consumer.primary_connection_string
  sensitive   = true
  description = "description"
}

output "producer_endpoint" {
  value       = azurerm_eventhub_authorization_rule.producer.primary_connection_string
  sensitive   = true
  description = "description"
}

output "topic" {
  value       = azurerm_eventhub.adh.name
  sensitive   = false
  description = "description"
}

output "ns" {
  value       = azurerm_eventhub_namespace.adh_ns.name
  sensitive   = false
  description = "description"
}

# output "blob_endpoint" {
#   value       = azurerm_storage_account.adh.primary_connection_string
#   sensitive   = true
#   description = "description"
# }
