$vms = $(Get-AzVM -Status)
for ($i = 0; $i -lt $vms.Count; $i++)
{
	if ( $vms.PowerState[$i] -eq "VM running" )
	{
		Write-Host "De-allocating resources for " $vms.Name[$i]
		Stop-AzVM -name $vms.Name[$i] -resourcegroup $vms.ResourceGroupName[$i] -Force
	}
}