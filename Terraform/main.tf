#-------------------------------------------------
# TERRAFORM CONFIGURATION - ADVANCED RED TEAM LAB 
#-------------------------------------------------

resource "azurerm_resource_group" "rg" {
  name     = var.prefix_lab
  location = var.resource_group_location
}

#-----------------
# Virtual Network 
#-----------------

resource "azurerm_virtual_network" "rtlab_network" {
  name                = "${var.prefix_lab}-vnet"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  address_space       = ["10.0.0.0/16"]
}

#---------
# Subnets
#---------

resource "azurerm_subnet" "GatewaySubnet" {
  name                 = "GatewaySubnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.rtlab_network.name
  address_prefixes     = ["10.0.0.0/24"]
  depends_on           = [azurerm_virtual_network.rtlab_network]
}

resource "azurerm_subnet" "rtlab_subnet1" {
  name                 = "${var.prefix_lab}-subnet1"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.rtlab_network.name
  address_prefixes     = ["10.0.1.0/24"]
  depends_on           = [azurerm_virtual_network.rtlab_network]
}

resource "azurerm_subnet" "rtlab_subnet2" {
  name                 = "${var.prefix_lab}-subnet2"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.rtlab_network.name
  address_prefixes     = ["10.0.2.0/24"]
  depends_on           = [azurerm_virtual_network.rtlab_network]
}


#-----------
# Public IP
#-----------

resource "azurerm_public_ip" "rtlab_public_ip_1" {
  name                = "${var.prefix_lab}-public-ip-1"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  sku                 = "Standard"
  sku_tier            = "Regional"
  allocation_method   = "Static"
  
}

#------------------------
# Network Security Group
#------------------------

resource "azurerm_network_security_group" "rtlab_nsg_win" {
  name                = "${var.prefix_lab}-nsg-win"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  
  security_rule {
    name                       = "RDP"
    priority                   = 1000
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "3389"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
  security_rule {
    name                       = "web"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

resource "azurerm_network_security_group" "rtlab_nsg_linux" {
  name                = "${var.prefix_lab}-nsg-linux"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  
    security_rule {
    name                       = "SSH"
    priority                   = 1000
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
  security_rule {
    name                       = "web"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}


#-------------------------
# Network Interface Cards
#-------------------------

resource "azurerm_network_interface" "winserver_nic" {
  name                = "${var.prefix_lab}-winserver-nic"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "winserver_nic_conf"
    subnet_id                     = azurerm_subnet.rtlab_subnet1.id
    private_ip_address_allocation = "Dynamic"
  }
  
  depends_on           = [azurerm_subnet.rtlab_subnet1]
}

resource "azurerm_network_interface" "win1_nic" {
  name                = "${var.prefix_lab}-win1-nic"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "win1_nic_conf"
    subnet_id                     = azurerm_subnet.rtlab_subnet1.id
    private_ip_address_allocation = "Dynamic"
  }
  
  depends_on           = [azurerm_subnet.rtlab_subnet1]
}

resource "azurerm_network_interface" "win2_nic1" {
  name                = "${var.prefix_lab}-win2-nic1"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "win2_nic1_conf"
    subnet_id                     = azurerm_subnet.rtlab_subnet1.id
    private_ip_address_allocation = "Dynamic"
  }
  
  depends_on           = [azurerm_subnet.rtlab_subnet1]
}

resource "azurerm_network_interface" "win2_nic2" {
  name                = "${var.prefix_lab}-win2-nic2"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "win2_nic2_conf"
    subnet_id                     = azurerm_subnet.rtlab_subnet2.id
    private_ip_address_allocation = "Dynamic"
  }
  
  depends_on           = [azurerm_subnet.rtlab_subnet2]
}

resource "azurerm_network_interface" "win3_nic" {
  name                = "${var.prefix_lab}-win3-nic"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "win3_nic_conf"
    subnet_id                     = azurerm_subnet.rtlab_subnet2.id
    private_ip_address_allocation = "Dynamic"
  }
  
  depends_on           = [azurerm_subnet.rtlab_subnet2]
}

resource "azurerm_network_interface" "kali_nic1" {
  name                = "${var.prefix_lab}-kali-nic1"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "kali_nic1_conf"
    subnet_id                     = azurerm_subnet.rtlab_subnet1.id
    private_ip_address_allocation = "Dynamic"
  }
  
  depends_on           = [azurerm_subnet.rtlab_subnet1]
}

resource "azurerm_network_interface" "kali_nic2" {
  name                = "${var.prefix_lab}-kali-nic2"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "kali_nic2_conf"
    subnet_id                     = azurerm_subnet.rtlab_subnet2.id
    private_ip_address_allocation = "Dynamic"
  }
  
  depends_on           = [azurerm_subnet.rtlab_subnet2]
}

resource "azurerm_network_interface" "ubuntu_nic" {
  name                = "${var.prefix_lab}-ubuntu-nic"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "ubuntu_nic_conf"
    subnet_id                     = azurerm_subnet.rtlab_subnet1.id
    private_ip_address_allocation = "Dynamic"
  }
  
  depends_on           = [azurerm_subnet.rtlab_subnet1]
}

#-------------------------------------
# Network Security Group Associations
#-------------------------------------

resource "azurerm_network_interface_security_group_association" "winserver_nisga" {
  network_interface_id      = azurerm_network_interface.winserver_nic.id
  network_security_group_id = azurerm_network_security_group.rtlab_nsg_win.id
  depends_on                = [azurerm_network_security_group.rtlab_nsg_win, azurerm_network_interface.winserver_nic]
}

resource "azurerm_network_interface_security_group_association" "win1_nisga" {
  network_interface_id      = azurerm_network_interface.win1_nic.id
  network_security_group_id = azurerm_network_security_group.rtlab_nsg_win.id
  depends_on                = [azurerm_network_security_group.rtlab_nsg_win, azurerm_network_interface.win1_nic]
}

resource "azurerm_network_interface_security_group_association" "win2_nisga1" {
  network_interface_id      = azurerm_network_interface.win2_nic1.id
  network_security_group_id = azurerm_network_security_group.rtlab_nsg_win.id
  depends_on                = [azurerm_network_security_group.rtlab_nsg_win, azurerm_network_interface.win2_nic1]
}

resource "azurerm_network_interface_security_group_association" "win2_nisga2" {
  network_interface_id      = azurerm_network_interface.win2_nic2.id
  network_security_group_id = azurerm_network_security_group.rtlab_nsg_win.id
  depends_on                = [azurerm_network_security_group.rtlab_nsg_win, azurerm_network_interface.win2_nic2]
}

resource "azurerm_network_interface_security_group_association" "win3_nisga" {
  network_interface_id      = azurerm_network_interface.win3_nic.id
  network_security_group_id = azurerm_network_security_group.rtlab_nsg_win.id
  depends_on                = [azurerm_network_security_group.rtlab_nsg_win, azurerm_network_interface.win3_nic]
}

resource "azurerm_network_interface_security_group_association" "kali_nisga1" {
  network_interface_id      = azurerm_network_interface.kali_nic1.id
  network_security_group_id = azurerm_network_security_group.rtlab_nsg_linux.id
  depends_on                = [azurerm_network_security_group.rtlab_nsg_linux, azurerm_network_interface.kali_nic1]
}

resource "azurerm_network_interface_security_group_association" "kali_nisga2" {
  network_interface_id      = azurerm_network_interface.kali_nic2.id
  network_security_group_id = azurerm_network_security_group.rtlab_nsg_linux.id
  depends_on                = [azurerm_network_security_group.rtlab_nsg_linux, azurerm_network_interface.kali_nic2]
}

resource "azurerm_network_interface_security_group_association" "ubuntu_nisga" {
  network_interface_id      = azurerm_network_interface.ubuntu_nic.id
  network_security_group_id = azurerm_network_security_group.rtlab_nsg_linux.id
  depends_on                = [azurerm_network_security_group.rtlab_nsg_linux, azurerm_network_interface.ubuntu_nic]
}

#----------
# SSH Keys
#----------

resource "azapi_resource" "ssh_public_key_ubuntu" {
  type      = "Microsoft.Compute/sshPublicKeys@2022-11-01"
  name      = "ssh-admin-ubuntu"
  location  = azurerm_resource_group.rg.location
  parent_id = azurerm_resource_group.rg.id
}

resource "azapi_resource_action" "ssh_public_key_gen_ubuntu" {
  type        = "Microsoft.Compute/sshPublicKeys@2022-11-01"
  resource_id = azapi_resource.ssh_public_key_ubuntu.id
  action      = "generateKeyPair"
  method      = "POST"

  response_export_values = ["publicKey", "privateKey"]
}

resource "azapi_resource" "ssh_public_key_kali" {
  type      = "Microsoft.Compute/sshPublicKeys@2022-11-01"
  name      = "ssh-admin-kali"
  location  = azurerm_resource_group.rg.location
  parent_id = azurerm_resource_group.rg.id
}

resource "azapi_resource_action" "ssh_public_key_gen_kali" {
  type        = "Microsoft.Compute/sshPublicKeys@2022-11-01"
  resource_id = azapi_resource.ssh_public_key_kali.id
  action      = "generateKeyPair"
  method      = "POST"

  response_export_values = ["publicKey", "privateKey"]
}

#-----------
# Passwords 
#-----------

resource "random_password" "password_admin_winserver" {
  length      = 42
  min_lower   = 9
  min_upper   = 9
  min_numeric = 9
  min_special = 9
  special     = true
}

resource "random_password" "password_admin_winserver_safemode" {
  length      = 42
  min_lower   = 9
  min_upper   = 9
  min_numeric = 9
  min_special = 9
  special     = true
}

resource "random_password" "password_admin_win1" {
  length      = 42
  min_lower   = 9
  min_upper   = 9
  min_numeric = 9
  min_special = 9
  special     = true
}

resource "random_password" "password_admin_win2" {
  length      = 42
  min_lower   = 9
  min_upper   = 9
  min_numeric = 9
  min_special = 9
  special     = true
}

resource "random_password" "password_admin_win3" {
  length      = 42
  min_lower   = 9
  min_upper   = 9
  min_numeric = 9
  min_special = 9
  special     = true
}

resource "random_password" "password_admin_ubuntu" {
  length      = 42
  min_lower   = 9
  min_upper   = 9
  min_numeric = 9
  min_special = 9
  special     = true
}

resource "random_password" "password_admin_kali" {
  length      = 42
  min_lower   = 9
  min_upper   = 9
  min_numeric = 9
  min_special = 9
  special     = true
}

#------------------
# Virtual Machines
#------------------

resource "azurerm_windows_virtual_machine" "winserver" {
  name                  = "${var.prefix_lab}-winserver"
  admin_username        = "admin-winserver"
  admin_password        = random_password.password_admin_winserver.result
  resource_group_name   = azurerm_resource_group.rg.name
  location              = azurerm_resource_group.rg.location
  network_interface_ids = [azurerm_network_interface.winserver_nic.id]
  size                  = "Standard_B2ms"
  computer_name			= "rtlab-dc"

  os_disk {
    name                 = "${var.prefix_lab}-winserver-disk"
    caching              = "ReadWrite"
    storage_account_type = "StandardSSD_LRS"
	#disk_size_gb         = "127"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2019-Datacenter"
    version   = "latest"
  }
  
  depends_on            = [azurerm_network_interface.winserver_nic, random_password.password_admin_winserver]
}

resource "azurerm_windows_virtual_machine" "win1" {
  name                  = "${var.prefix_lab}-win1"
  admin_username        = "admin-win1"
  admin_password        = random_password.password_admin_win1.result
  resource_group_name   = azurerm_resource_group.rg.name
  location              = azurerm_resource_group.rg.location
  network_interface_ids = [azurerm_network_interface.win1_nic.id]
  size                  = "Standard_B2s"

  os_disk {
    name                 = "${var.prefix_lab}-win1-disk"
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
	#disk_size_gb         = "127"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsDesktop"
    offer     = "Windows-10"
    sku       = "win10-22h2-entn-g2"
    version   = "latest"
  }
  
  depends_on            = [azurerm_network_interface.win1_nic, random_password.password_admin_win1]
}

resource "azurerm_windows_virtual_machine" "win2" {
  name                  = "${var.prefix_lab}-win2"
  admin_username        = "admin-win2"
  admin_password        = random_password.password_admin_win2.result
  resource_group_name   = azurerm_resource_group.rg.name
  location              = azurerm_resource_group.rg.location
  network_interface_ids = [azurerm_network_interface.win2_nic1.id, azurerm_network_interface.win2_nic2.id]
  size                  = "Standard_B2s"

  os_disk {
    name                 = "${var.prefix_lab}-win2-disk"
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
	#disk_size_gb         = "127"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsDesktop"
    offer     = "Windows-10"
    sku       = "win10-22h2-entn-g2"
    version   = "latest"
  }
  
  depends_on            = [azurerm_network_interface.win2_nic1, azurerm_network_interface.win2_nic2, random_password.password_admin_win2]
}

resource "azurerm_windows_virtual_machine" "win3" {
  name                  = "${var.prefix_lab}-win3"
  admin_username        = "admin-win3"
  admin_password        = random_password.password_admin_win3.result
  resource_group_name   = azurerm_resource_group.rg.name
  location              = azurerm_resource_group.rg.location
  network_interface_ids = [azurerm_network_interface.win3_nic.id]
  size                  = "Standard_B2s"

  os_disk {
    name                 = "${var.prefix_lab}-win3-disk"
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
	#disk_size_gb         = "127"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsDesktop"
    offer     = "Windows-10"
    sku       = "win10-22h2-entn-g2"
    version   = "latest"
  }
  
  depends_on            = [azurerm_network_interface.win3_nic, random_password.password_admin_win3]
}

resource "azurerm_linux_virtual_machine" "ubuntu" {
  name                  = "${var.prefix_lab}-ubuntu"
  disable_password_authentication = "false"
  admin_username        = "admin-ubuntu"
  admin_password        = random_password.password_admin_ubuntu.result
  resource_group_name   = azurerm_resource_group.rg.name
  location              = azurerm_resource_group.rg.location
  network_interface_ids = [azurerm_network_interface.ubuntu_nic.id]
  size                  = "Standard_B2s"

  os_disk {
    name                 = "${var.prefix_lab}-ubuntu-disk"
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
	#disk_size_gb         = "64"
  }

  source_image_reference {
	publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts-gen2"
    version   = "latest"
  }
  
  admin_ssh_key {
    username   = "admin-ubuntu"
    public_key = jsondecode(azapi_resource_action.ssh_public_key_gen_ubuntu.output).publicKey
  }
  
  depends_on            = [azurerm_network_interface.ubuntu_nic, azapi_resource_action.ssh_public_key_gen_ubuntu, random_password.password_admin_ubuntu]
}

resource "azurerm_marketplace_agreement" "kali" {
  publisher = "kali-linux"
  offer     = "kali"
  plan      = "kali-2023-2"
}

resource "azurerm_linux_virtual_machine" "kali" {
  name                  = "${var.prefix_lab}-kali"
  disable_password_authentication = "false"
  admin_username        = "admin-kali"
  admin_password        = random_password.password_admin_kali.result
  resource_group_name   = azurerm_resource_group.rg.name
  location              = azurerm_resource_group.rg.location
  network_interface_ids = [azurerm_network_interface.kali_nic1.id, azurerm_network_interface.kali_nic2.id]
  size                  = "Standard_B2s"

  os_disk {
    name                 = "${var.prefix_lab}-kali-disk"
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
	#disk_size_gb         = "127"
  }

  source_image_reference {
    publisher = "kali-linux"
    offer     = "kali"
    sku       = "kali-2023-2"
    version   = "latest"
  }
   plan {
    publisher = "kali-linux"
	product   = "kali"
	name      = "kali-2023-2"
  }
  
    admin_ssh_key {
    username   = "admin-kali"
    public_key = jsondecode(azapi_resource_action.ssh_public_key_gen_kali.output).publicKey
  }
  
  depends_on            = [azurerm_marketplace_agreement.kali, azurerm_network_interface.kali_nic1, azurerm_network_interface.kali_nic2, azapi_resource_action.ssh_public_key_gen_kali, random_password.password_admin_kali]
}

#----------------------------
# VM Auto shutdown schedules
#----------------------------

resource "azurerm_dev_test_global_vm_shutdown_schedule" "winserver" {
  virtual_machine_id = azurerm_windows_virtual_machine.winserver.id
  location           = azurerm_resource_group.rg.location
  enabled            = true

  daily_recurrence_time = "${var.autoshutdown_time}"
  timezone              = "${var.autoshutdown_timezone}"

  notification_settings {
    enabled         = true
	email           = "${var.autoshutdown_notification_email}"
    time_in_minutes = "${var.autoshutdown_notification_time}"
  }
  
  depends_on = [azurerm_windows_virtual_machine.winserver]
}

resource "azurerm_dev_test_global_vm_shutdown_schedule" "win1" {
  virtual_machine_id = azurerm_windows_virtual_machine.win1.id
  location           = azurerm_resource_group.rg.location
  enabled            = true

  daily_recurrence_time = "${var.autoshutdown_time}"
  timezone              = "${var.autoshutdown_timezone}"

  notification_settings {
    enabled         = true
	email           = "${var.autoshutdown_notification_email}"
    time_in_minutes = "${var.autoshutdown_notification_time}"
  }
  
  depends_on = [azurerm_windows_virtual_machine.win1]
}

resource "azurerm_dev_test_global_vm_shutdown_schedule" "win2" {
  virtual_machine_id = azurerm_windows_virtual_machine.win2.id
  location           = azurerm_resource_group.rg.location
  enabled            = true

  daily_recurrence_time = "${var.autoshutdown_time}"
  timezone              = "${var.autoshutdown_timezone}"

  notification_settings {
    enabled         = true
	email           = "${var.autoshutdown_notification_email}"
    time_in_minutes = "${var.autoshutdown_notification_time}"
  }
  
  depends_on = [azurerm_windows_virtual_machine.win2]
}

resource "azurerm_dev_test_global_vm_shutdown_schedule" "win3" {
  virtual_machine_id = azurerm_windows_virtual_machine.win3.id
  location           = azurerm_resource_group.rg.location
  enabled            = true

  daily_recurrence_time = "${var.autoshutdown_time}"
  timezone              = "${var.autoshutdown_timezone}"

  notification_settings {
    enabled         = true
	email           = "${var.autoshutdown_notification_email}"
    time_in_minutes = "${var.autoshutdown_notification_time}"
  }
  
  depends_on = [azurerm_windows_virtual_machine.win3]
}

resource "azurerm_dev_test_global_vm_shutdown_schedule" "ubuntu" {
  virtual_machine_id = azurerm_linux_virtual_machine.ubuntu.id
  location           = azurerm_resource_group.rg.location
  enabled            = true

  daily_recurrence_time = "${var.autoshutdown_time}"
  timezone              = "${var.autoshutdown_timezone}"

  notification_settings {
    enabled         = true
	email           = "${var.autoshutdown_notification_email}"
    time_in_minutes = "${var.autoshutdown_notification_time}"
  }
  
  depends_on = [azurerm_linux_virtual_machine.ubuntu]
}

resource "azurerm_dev_test_global_vm_shutdown_schedule" "kali" {
  virtual_machine_id = azurerm_linux_virtual_machine.kali.id
  location           = azurerm_resource_group.rg.location
  enabled            = true

  daily_recurrence_time = "${var.autoshutdown_time}"
  timezone              = "${var.autoshutdown_timezone}"

  notification_settings {
    enabled         = true
	email           = "${var.autoshutdown_notification_email}"
    time_in_minutes = "${var.autoshutdown_notification_time}"
  }
  
  depends_on = [azurerm_linux_virtual_machine.kali]
}

#-------------------------
# Virtual Network Gateway
#-------------------------

resource "azurerm_virtual_network_gateway" "rtlab_vpn" {
  name                = "${var.prefix_lab}-vpn"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  type     = "Vpn"
  vpn_type = "RouteBased"

  active_active = false
  enable_bgp    = false
  sku           = "VpnGw1"

  ip_configuration {
    name                          = "rtlab_vpn_config"
    public_ip_address_id          = azurerm_public_ip.rtlab_public_ip_1.id
    private_ip_address_allocation = "Dynamic"
    subnet_id                     = azurerm_subnet.GatewaySubnet.id
  }

  vpn_client_configuration {
    address_space = ["192.168.1.0/24"]
	vpn_client_protocols = ["OpenVPN"]
	vpn_auth_types = ["Certificate"]

    root_certificate {
      name = "P2SRootCert"
      public_cert_data = file("${path.module}/VPNcerts/P2SRootCert.txt")
    }
  }
  
  depends_on = [azurerm_virtual_network.rtlab_network, azurerm_subnet.GatewaySubnet, azurerm_public_ip.rtlab_public_ip_1]
}

#----------------------
# Post install scripts
#----------------------

resource "azurerm_virtual_machine_extension" "active_directory_setup" {
  name                       = "${var.prefix_lab}-script"
  virtual_machine_id         = azurerm_windows_virtual_machine.winserver.id
  publisher                  = "Microsoft.Compute"
  type                       = "CustomScriptExtension"
  type_handler_version       = "1.9"
  auto_upgrade_minor_version = true

	protected_settings = <<SETTINGS
	{
		"commandToExecute": "powershell -ExecutionPolicy Unrestricted -File ${filebase64("${path.module}/Scripts/domain-setup.ps1")} -SafeModeAdministratorPassword ${random_password.password_admin_winserver_safemode.result}"
	}
	SETTINGS
	
	depends_on = [azurerm_windows_virtual_machine.winserver, random_password.password_admin_winserver_safemode]
}