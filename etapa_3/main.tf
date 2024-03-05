
data "azurerm_resource_group" "rg" {
  name = local.resource_group_name
}

data "azurerm_virtual_network" "adh" {
  name                = local.vnet_name
  resource_group_name = data.azurerm_resource_group.rg.name
}

resource "azapi_resource_action" "ssh_public_key_gen" {
  type                   = "Microsoft.Compute/sshPublicKeys@2022-11-01"
  resource_id            = azapi_resource.ssh_public_key.id
  action                 = "generateKeyPair"
  method                 = "POST"
  response_export_values = ["publicKey", "privateKey"]
}

resource "azapi_resource" "ssh_public_key" {
  type      = "Microsoft.Compute/sshPublicKeys@2022-11-01"
  name      = "publickkeysncalck"
  location  = data.azurerm_resource_group.rg.location
  parent_id = data.azurerm_resource_group.rg.id
  tags      = local.common_tags
}

output "key_data" {
  value = jsondecode(azapi_resource_action.ssh_public_key_gen.output).privateKey
}

# Create the VNet
resource "azurerm_virtual_network" "producer_vnet" {
  name                = "producer-vnet"
  location            = data.azurerm_resource_group.rg.location
  resource_group_name = data.azurerm_resource_group.rg.name
  address_space       = [var.address_space]
  tags                = local.common_tags
}

# Create the AzureBastionSubnet
resource "azurerm_subnet" "bastion_subnet" {
  name                 = "AzureBastionSubnet"
  resource_group_name  = data.azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.producer_vnet.name
  address_prefixes     = [local.public_subnet_cidr]
}

# Create a public IP address for the Azure Bastion
resource "azurerm_public_ip" "bastion_public_ip" {
  name                = "bastion-host-ip"
  location            = data.azurerm_resource_group.rg.location
  resource_group_name = data.azurerm_resource_group.rg.name
  allocation_method   = "Static"
  sku                 = "Standard"
  tags                = local.common_tags
}

resource "azurerm_private_dns_zone_virtual_network_link" "link-dns-vm" {
  name                  = "link-producer-vnet"
  resource_group_name   = data.azurerm_resource_group.rg.name
  private_dns_zone_name = "privatelink.servicebus.windows.net"
  virtual_network_id    = azurerm_virtual_network.producer_vnet.id
}

# Create the private-subnet
resource "azurerm_subnet" "private_subnet" {
  name                 = "private-subnet"
  resource_group_name  = data.azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.producer_vnet.name
  address_prefixes     = [local.private_subnet_cidr]
  #service_endpoints    = ["Microsoft.Storage", "Microsoft.EventHub"]
}

resource "azurerm_network_interface" "vm_nic" {
  name                = "vm-nic"
  location            = data.azurerm_resource_group.rg.location
  resource_group_name = data.azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.private_subnet.id
    private_ip_address_allocation = "Dynamic"
  }
  tags = local.common_tags
}

# Create virtual machine
resource "azurerm_linux_virtual_machine" "vm" {
  name                = "producer"
  location            = data.azurerm_resource_group.rg.location
  resource_group_name = data.azurerm_resource_group.rg.name
  network_interface_ids = [
    azurerm_network_interface.vm_nic.id,
  ]
  size = "Standard_DS1_v2"

  os_disk {
    name                 = "OsDisk"
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts-gen2"
    version   = "latest"
  }

  computer_name  = "producer"
  admin_username = "user6"
  admin_password = "L!dw12ala"
  admin_ssh_key {
    username   = "user6"
    public_key = jsondecode(azapi_resource_action.ssh_public_key_gen.output).publicKey
  }

  custom_data = base64encode(templatefile("config/cloud-init.yaml.tpl", {
    fluent_bit_kafka_brokers  = "${data.terraform_remote_state.etapa_1.outputs.ns}.servicebus.windows.net:9093"
    fluent_bit_kafka_topic    = data.terraform_remote_state.etapa_1.outputs.topic
    fluent_bit_kafka_password = data.terraform_remote_state.etapa_1.outputs.producer_endpoint,
    repo = var.repo
  }))
  tags = local.common_tags
}

# Create the Bastion Host
resource "azurerm_bastion_host" "bastion_host" {
  name                = "bastion-host"
  location            = data.azurerm_resource_group.rg.location
  resource_group_name = data.azurerm_resource_group.rg.name
  sku                 = "Standard"
  tunneling_enabled   = true
  ip_configuration {
    name                 = "configuration"
    subnet_id            = azurerm_subnet.bastion_subnet.id
    public_ip_address_id = azurerm_public_ip.bastion_public_ip.id
  }
  tags = local.common_tags
}

resource "azurerm_virtual_network_peering" "peering" {
  name                         = "peering"
  resource_group_name          = data.azurerm_resource_group.rg.name
  virtual_network_name         = azurerm_virtual_network.producer_vnet.name
  remote_virtual_network_id    = data.azurerm_virtual_network.adh.id
  allow_virtual_network_access = true
  allow_forwarded_traffic      = false
  allow_gateway_transit        = false
}

resource "azurerm_virtual_network_peering" "peering-vuelta" {
  name                         = "peering"
  resource_group_name          = data.azurerm_resource_group.rg.name
  virtual_network_name         = local.vnet_name
  remote_virtual_network_id    = azurerm_virtual_network.producer_vnet.id
  allow_virtual_network_access = false
  allow_forwarded_traffic      = false
  allow_gateway_transit        = false
}