#Advanced Red Team Lab on Azure - Predeployment configuration script for Windows Server 2019

[CmdletBinding()]

param 
( 
    [Parameter(ValuefromPipeline=$true,Mandatory=$true)] [String]$SafeModeAdministratorPassword
)

$SMAP = ConvertTo-SecureString -AsPlainText $SafeModeAdministratorPassword -Force

#Variables
$domain_name = "rtlab.local"
$domain_netbios_name = "rtlab-dc"
$domain_mode = "WinThreshold" # Windows Server 2016 mode
$forest_mode = "WinThreshold" # Windows Server 2016 mode
$database_path = "C:/Windows/NTDS"
$sysvol_path = "C:/Windows/SYSVOL"
$log_path = "C:/Windows/NTDS"

#1. Set execution policy to unrestricted
Set-ExecutionPolicy -ExecutionPolicy Unrestricted -Scope LocalMachine

#2. Install AD-Domain-Services
Install-WindowsFeature -Name AD-Domain-Services -IncludeAllSubFeature -IncludeManagementTools

#3. Create forest and domain
Install-ADDSForest -CreateDnsDelegation:$false -InstallDns:$true -DomainMode $domain_mode -DomainName $domain_name -DomainNetbiosName $domain_netbios_name -ForestMode $forest_mode -DatabasePath $database_path -SysvolPath $sysvol_path -LogPath $log_path -NoRebootOnCompletion:$false -Force:$true -SkipPreChecks -SafeModeAdministratorPassword $SMAP

#4. Promote the server to a domain controller


#6. Run badblood script to generate random users/SPs


#7. Set group policy to disable windows defender (PENDING)

exit 0
