resource "azurerm_resource_group" "this" {
  count    = var.create_resource_group ? 1 : 0
  name     = var.resource_group_name
  location = var.location
  tags     = var.tags
}

data "azurerm_resource_group" "existing" {
  count = var.create_resource_group ? 0 : 1
  name  = var.resource_group_name
}

locals {
  rg_name     = var.create_resource_group ? azurerm_resource_group.this[0].name : data.azurerm_resource_group.existing[0].name
  rg_location = var.create_resource_group ? azurerm_resource_group.this[0].location : data.azurerm_resource_group.existing[0].location
}

resource "azurerm_virtual_network" "this" {
  name                = "${var.vm_name_prefix}-vnet"
  resource_group_name = local.rg_name
  location            = local.rg_location
  address_space       = [var.vnet_cidr]
  tags                = var.tags
}

resource "azurerm_subnet" "this" {
  name                 = "${var.vm_name_prefix}-subnet"
  resource_group_name  = local.rg_name
  virtual_network_name = azurerm_virtual_network.this.name
  address_prefixes     = [var.subnet_cidr]
}

resource "azurerm_network_security_group" "this" {
  name                = "${var.vm_name_prefix}-nsg"
  resource_group_name = local.rg_name
  location            = local.rg_location
  tags                = var.tags

  security_rule {
    name                       = "allow-ssh"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = var.allowed_ssh_cidr
    destination_address_prefix = "*"
  }
}

resource "azurerm_subnet_network_security_group_association" "this" {
  subnet_id                 = azurerm_subnet.this.id
  network_security_group_id = azurerm_network_security_group.this.id
}

resource "azurerm_public_ip" "this" {
  count               = var.create_public_ip ? var.vm_count : 0
  name                = "${var.vm_name_prefix}-${count.index + 1}-pip"
  resource_group_name = local.rg_name
  location            = local.rg_location
  allocation_method   = "Static"
  sku                 = "Standard"
  tags                = var.tags
}

resource "azurerm_network_interface" "this" {
  count               = var.vm_count
  name                = "${var.vm_name_prefix}-${count.index + 1}-nic"
  resource_group_name = local.rg_name
  location            = local.rg_location
  tags                = var.tags

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.this.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = var.create_public_ip ? azurerm_public_ip.this[count.index].id : null
  }
}

resource "azurerm_linux_virtual_machine" "this" {
  count               = var.vm_count
  name                = "${var.vm_name_prefix}-${count.index + 1}"
  resource_group_name = local.rg_name
  location            = local.rg_location
  size                = var.vm_size
  admin_username      = var.admin_username
  tags                = var.tags

  network_interface_ids = [azurerm_network_interface.this[count.index].id]

  disable_password_authentication = true

  admin_ssh_key {
    username   = var.admin_username
    public_key = var.ssh_public_key
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = var.os_disk_type
    disk_size_gb         = var.os_disk_size_gb
  }

  source_image_reference {
    publisher = var.image.publisher
    offer     = var.image.offer
    sku       = var.image.sku
    version   = var.image.version
  }
}
