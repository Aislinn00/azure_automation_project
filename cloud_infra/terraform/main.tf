locals {
  name = "${var.project}Vm"
  tags = {
    project = var.project
    managed = "terraform"
    env     = "dev"
  }
}

#Resource Group
data "azurerm_resource_group" "rg" {
  name = var.resource_group_name
}

#Networking: VNet + Subnet
resource "azurerm_virtual_network" "vnet" {
  name                = "${var.project}-vnet"
  address_space       = ["10.10.0.0/16"]
  location            = data.azurerm_resource_group.rg.location
  resource_group_name = data.azurerm_resource_group.rg.name
  tags = {
    project = var.project
  }
}

resource "azurerm_subnet" "subnet" {
  name                 = "${var.project}-subnet"
  resource_group_name  = data.azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.10.1.0/24"]
}

# Network Security Group with tight SSH ingress
resource "azurerm_network_security_group" "nsg" {
  name                = "${var.project}-nsg"
  location            = data.azurerm_resource_group.rg.location
  resource_group_name = data.azurerm_resource_group.rg.name
  tags                = local.tags


  # Allow SSH (Port 22) only from the IP
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

  # open HTTP if you’re hosting a web app
  security_rule {
    name                       = "allow-http"
    priority                   = 1002
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "Internet"
    destination_address_prefix = "*"
  }
}

#Public IP
resource "azurerm_public_ip" "pip" {
  name                = "${var.project}-pip"
  location            = data.azurerm_resource_group.rg.location
  resource_group_name = data.azurerm_resource_group.rg.name
  allocation_method   = "Static"
  sku                 = "Standard"
  tags                = local.tags
}

# NIC
resource "azurerm_network_interface" "nic" {
  name                = "${var.project}-nic"
  location            = data.azurerm_resource_group.rg.location
  resource_group_name = data.azurerm_resource_group.rg.name
  tags                = local.tags

  ip_configuration {
    name                          = "primary"
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.pip.id
  }
}

# Associate NSG to the subnet (recommended) or NIC.
resource "azurerm_subnet_network_security_group_association" "subnet_nsg" {
  subnet_id                 = azurerm_subnet.subnet.id
  network_security_group_id = azurerm_network_security_group.nsg.id
}

#Linux VM
resource "azurerm_linux_virtual_machine" "vm" {
  name                  = local.name
  location              = data.azurerm_resource_group.rg.location
  resource_group_name   = data.azurerm_resource_group.rg.name
  size                  = var.vm_size
  admin_username        = var.admin_username
  network_interface_ids = [azurerm_network_interface.nic.id]

  # OS disk
  os_disk {
    name                 = "${local.name}-osdisk"
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  # Ubuntu LTS image
  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }

  # SSH key
  admin_ssh_key {
    username   = var.admin_username
    public_key = var.ssh_public_key
  }

  tags = local.tags
}

