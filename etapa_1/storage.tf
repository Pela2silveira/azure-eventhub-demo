#Esto puede ser necesario para utilizar algun consumidor para manejar el índice
# resource "azurerm_storage_account" "adh" {
#   name                     = "adhconsumerindex"
#   resource_group_name      = azurerm_resource_group.rg.name
#   location                 = azurerm_resource_group.rg.location
#   account_tier             = "Standard"
#   account_replication_type = "GRS"
#   tags                     = local.common_tags
# }

# resource "azurerm_storage_container" "adh" {
#   name                  = "adh"
#   storage_account_name  = azurerm_storage_account.adh.name
#   container_access_type = "private"
# }

# resource "azurerm_storage_blob" "adh" {
#   name                   = "consumer-index"
#   storage_account_name   = azurerm_storage_account.adh.name
#   storage_container_name = azurerm_storage_container.adh.name
#   type                   = "Block"
# }