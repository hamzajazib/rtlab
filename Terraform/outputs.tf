output "resource_group_name" {
  value = azurerm_resource_group.rg.name
}

output "password_admin_winserver" {
  sensitive = true
  value     = azurerm_windows_virtual_machine.winserver.admin_password
}

output "password_admin_winserver_safemode" {
  sensitive = true
  value     = random_password.password_admin_winserver_safemode.result
}

output "password_admin_win1" {
  sensitive = true
  value     = azurerm_windows_virtual_machine.win1.admin_password
}

output "password_admin_win2" {
  sensitive = true
  value     = azurerm_windows_virtual_machine.win2.admin_password
}

output "password_admin_win3" {
  sensitive = true
  value     = azurerm_windows_virtual_machine.win3.admin_password
}

output "password_admin_ubuntu" {
  sensitive = true
  value     = azurerm_linux_virtual_machine.ubuntu.admin_password
}

output "password_admin_kali" {
  sensitive = true
  value     = azurerm_linux_virtual_machine.kali.admin_password
}

output "key_data_ubuntu" {
  value = jsondecode(azapi_resource_action.ssh_public_key_gen_ubuntu.output).publicKey
}

output "key_data_kali" {
  value = jsondecode(azapi_resource_action.ssh_public_key_gen_kali.output).publicKey
}