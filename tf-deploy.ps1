# Deployment script

Set-Location $pwd\Terraform

#Initialize terraform deployment - downloads Azure provider required to manage your Azure resources and upgrades the necessary provider plugins to the newest version that complies with the configuration's version constraints
terraform init -upgrade

#Validate syntax errors
Write-Host "Validating files for syntax errors" -Foreground "Blue"
terraform validate

#Create execution plan and output to .tfplan file
terraform plan -out main.tfplan

#Apply execution plan from .tfplan file
terraform apply main.tfplan

#After applying execution plan, display output in json format
terraform output -json | Out-File -FilePath "output.txt"
Write-Host "Output saved to Terraform\output.txt" -Foreground "Green"
Write-Host "WARNING: FOR SECURITY, PLEASE DELETE THIS FILE AFTER SAVING OUTPUT (i.e. credentials, SSH keys) TO A SECURE PLACE (i.e. Password manager)" -Foreground "Red"

#Generate VPN client configuration files and download URL
Write-Host "Generating VPN client configuration files" -Foreground "Blue"
$profile=New-AzVpnClientConfiguration -ResourceGroupName "RTLAB" -Name "RTLAB-vpn" -AuthenticationMethod "EapTls"
$profile.VPNProfileSASUrl

#Stop all VMs
Write-Host "Stopping all running VMs" -Foreground "Blue"
$vms = $(Get-AzVM -Status)
for ($i = 0; $i -lt $vms.Count; $i++)
{
	if ( $vms.PowerState[$i] -eq "VM running" )
	{
		Write-Host "De-allocating resources for " $vms.Name[$i]
		Stop-AzVM -name $vms.Name[$i] -resourcegroup $vms.ResourceGroupName[$i] -Force
	}
}