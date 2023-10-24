# Overview

Advanced Red Team Lab Infrastructure on Azure using Terraform

### Note: Tested on terraform/1.5.4, please use the same version to avoid deployment issues

# Lab Build

**Topology**

![image](https://github.com/hamzajazib/rtlab/assets/82419998/86516e5f-1e3c-423e-afa3-53994353bc91)


- Solid red line = Active Directory connection
- Dotted blue line = Endpoint connection for Logs

**Virtual Network**

| Address Space |
| --- |
| 10.0.0.0/16 |

**Subnets**

| Subnet Name | IPv4 | Use |
| --- | --- | --- |
| GatewaySubnet | 10.0.0.0/24 | VPN Gateway |
| RTLAB-subnet1 | 10.0.1.0/24 | Active Directory |
| RTLAB-subnet2 | 10.0.2.0/24 | Pivoting Lab |

**Virtual Network Gateway (VPN)**

| SKU | VNET Subnet | Public IP | Tunnel Type | Authentication Type | Address Pool (Clients) |
| --- | --- | --- | --- | --- | --- |
| VpnGw1 | 10.0.0.0/24<br>`GatewaySubnet` | `RTLAB-public-ip-1` | OpenVPN (SSL) | Azure Certificate | 192.168.1.0/24 |

**Virtual Machines**

| Host | Size | OS  | Image Offer | Image Plan | Role | Subnet | Private IP |
| --- | --- | --- | --- | --- | --- | --- | --- |
| RTLAB-winserver | Standard B2ms (2 vCPUs, 8GB RAM) | Windows | WindowsServer | 2019-DataCenter | AD DC | `RTLAB-subnet1` | `Dynamic` |
| RTLAB-win1 | Standard B2s (2 vCPUs, 4GB RAM) | Windows | Windows-10 | win10-22h2-entn-g2 | AD User | `RTLAB-subnet1` | `Dynamic` |
| RTLAB-win2 | Standard B2s (2 vCPUs, 4GB RAM) | Windows | Windows-10 | win10-22h2-entn-g2 | AD User | `RTLAB-subnet1`<br>`RTLAB-subnet2` | `Dynamic`<br>`Dynamic` |
| RTLAB-win3 | Standard B2s (2 vCPUs, 4GB RAM) | Windows | Windows-10 | win10-22h2-entn-g2 | Pivot Machine | `RTLAB-subnet2` | `Dynamic` |
| RTLAB-ubuntu | Standard B2s (2 vCPUs, 4GB RAM) | Linux | 0001-com-ubuntu-server-jammy | 22_04-lts-gen2 | AD User | `RTLAB-subnet1` | `Dynamic` |
| RTLAB-kali | Standard B2s (2 vCPUs, 4GB RAM) | Linux | kali | kali-2023-2 | SOC BOX | `RTLAB-subnet1`<br>`RTLAB-subnet2` | `Dynamic`<br>`Dynamic` |

**Note:** All VMs are configured to auto shutdown on 11:00 PST daily

# Estimated Cost Analysis

![image](https://github.com/hamzajazib/rtlab/assets/82419998/b26cef6c-0045-4291-bdfa-683191f757ff)


Note: VPN gateway incurs cost even when not used (therefore billed for 720 hours). To save costs, VPN gateway can be destroyed when not needed and re-deployed again when needed, regularly.

# Learning Resources

- [Terraform Language Documentation](https://developer.hashicorp.com/terraform/language)
- [Terraform: azurerm Documentation](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs)
- [GitHub: hashicorp/terraform-provider-azurerm/examples](https://github.com/hashicorp/terraform-provider-azurerm/tree/main/examples)
- [Quickstart: Use Terraform to create a Windows VM](https://learn.microsoft.com/en-us/azure/virtual-machines/windows/quick-create-terraform)
- [Quickstart: Use Terraform to create a Linux VM](https://learn.microsoft.com/en-us/azure/virtual-machines/linux/quick-create-terraform)
- [Configure Terraform in Azure Cloud Shell with Azure PowerShell](https://learn.microsoft.com/en-us/azure/developer/terraform/get-started-cloud-shell-powershell)
- Modules
    - [azurerm\_resource\_group](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group)
    - random_id
    - random_password
    - [azurerm\_virtual\_network](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_network)
    - [azurerm_subnet](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/subnet)
    - [azurerm\_public\_ip](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/public_ip)
    - [azurerm\_network\_security_group](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_security_group)
    - [azurerm\_network\_interface](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_interface)
    - [azurerm\_network\_interface\_security\_group_association](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_interface_security_group_association)
    - azapi_resource
        - Microsoft.Compute/sshPublicKeys@2022-11-01
    - azapi\_resource\_action
        - Microsoft.Compute/sshPublicKeys@2022-11-01
    - [azurerm\_windows\_virtual_machine](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/windows_virtual_machine)
    - [azurerm\_linux\_virtual_machine](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/linux_virtual_machine)
    - [azurerm\_marketplace\_agreement](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/marketplace_agreement)
    - [azurerm\_dev\_test\_global\_vm\_shutdown\_schedule](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/dev_test_global_vm_shutdown_schedule)
    - [azurerm\_virtual\_machine_extension](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_machine_extension.html)
    - [azurerm\_virtual\_network_gateway](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_network_gateway)

# Contents

**Pre-requisite:** Active Azure Subscription

- Configure Terraform
    - Configure Cloud Shell
    - Install/Update Terraform
    - Authenticate via a Microsoft account from Cloud Shell (using PowerShell)
        - Create a service principal using Azure PowerShell
        - Specify service principal credentials in environment variables
        - Specify service principal credentials in a Terraform provider block
- Generate VPN certificate
- Deploy Infrastructure
- Configure VPN client
- Put VMs to stopped(de-allocated) state
- View Console Output
- Destroy Resources

# Configure Cloud Shell

1\. Open [Azure Portal](https://portal.azure.com) and login

2\. Open Azure Cloud Shell and select "PowerShell" as the interpreter environment

![image](https://github.com/hamzajazib/rtlab/assets/82419998/6ff0adf7-3484-4319-a21c-5b48ec10c276)


3\. If this is your first time using the Azure account, when displayed "You have no storage mounted" and prompted to create a file share, select "Show advanced settings"

![image](https://github.com/hamzajazib/rtlab/assets/82419998/c09f18ea-0ba8-41fc-8012-a8daa66d97e9)


4\. Select `Subscription`, `Cloud Shell region`, enter names for `Resource group`, `Storage account` and `File share` and press the "Create Storage" button

Note: Storage account must be unique across all Azure subscriptions globally, not just yours. The reason for that is that the name becomes part of the URL, e.g. `https://accountname.blob.core.windows.net`

![image](https://github.com/hamzajazib/rtlab/assets/82419998/062bdf53-61a7-4e28-9a17-8c4150f40156)


# Install/Update Terraform

1\. After getting a Cloud Shell (PS), check if terraform is installed and up to date

```powershell
#Check terraform version to see if it needs an update
terraform version
```

![image](https://github.com/hamzajazib/rtlab/assets/82419998/66a49af5-4b78-4431-b37a-045160c830da)


* * *

If the version is out of date, browse to [Terraform Downloads](https://www.terraform.io/downloads.html) and copy the download link of the latest version for Linux - AMD64

- Note: Azure Shell is based on Azure Linux (linux_amd64), so we need the Linux - AMD64 version

![image](https://github.com/hamzajazib/rtlab/assets/82419998/2553dd4a-c485-40a7-954d-6aee3ba40c1d)


```plaintext
https://releases.hashicorp.com/terraform/1.5.4/terraform_1.5.4_linux_amd64.zip
```

```bash
#Download terraform
curl -O <terraform_download_url>

#Unzip package
unzip <zip_file_downloaded_in_previous_step>

#Create bin directory if not present
mkdir bin

#Move terraform to bin directory
mv terraform bin/
```

![image](https://github.com/hamzajazib/rtlab/assets/82419998/e1648931-69c4-4fea-909e-2727937a02da)


Restart Cloud Shell

![image](https://github.com/hamzajazib/rtlab/assets/82419998/c1cdde9e-dee2-4cf2-86cb-4d36206a5d9b)


![image](https://github.com/hamzajazib/rtlab/assets/82419998/b4b235e1-5d35-4bc8-b430-8fd3f811124c)


Confirm terraform is updated

![image](https://github.com/hamzajazib/rtlab/assets/82419998/0999d9be-c0d3-4d84-8562-1b545112607e)


# Authenticate via a Microsoft account from Cloud Shell (using PowerShell)

```powershell
#Check current subscription
Get-AzSubscription
```

![image](https://github.com/hamzajazib/rtlab/assets/82419998/9614c387-699e-4da3-a4eb-630915faa318)


Save both `Subscription ID` and `tenantId` for upcoming steps

## Create a service principal using Azure PowerShell

The most common pattern is to interactively sign in to Azure, create a service principal, test the service principal, and then use that service principal for future authentication (either interactively or from your scripts).

```powershell
#Create service principal with Contributer role
$sp = New-AzADServicePrincipal -DisplayName <service_principal_name> -Role "Contributor"

#Display the App ID
$sp.AppId

#Display the autogenerated password
$sp.PasswordCredentials.SecretText
```

![image](https://github.com/hamzajazib/rtlab/assets/82419998/019bfa88-37a5-44b1-9f27-763dd98c7415)


Save both `AppId` and `PasswordCredentials.SecretText` for upcoming steps

## Specify service principal credentials in environment variables

Replace the following code with respective values gained from earlier steps and execute code to save values as environment variables

```powershell
#Save values as environment variables
$env:ARM_SUBSCRIPTION_ID="<azure_subscription_id>"
$env:ARM_TENANT_ID="<azure_subscription_tenant_id>"
$env:ARM_CLIENT_ID="<service_principal_app_id>"
$env:ARM_CLIENT_SECRET="<service_principal_password>"

#Check the environment variables
gci env:ARM_*
```

![image](https://github.com/hamzajazib/rtlab/assets/82419998/b1522a48-3a4a-4ebd-b842-cbbf32f03b6c)


## Specify service principal credentials in a Terraform provider block

1\. Clone/Download this GitHub repository on Windows computer

2\. Replace fields in `rtlab/Terraform/providers.tf` with respective values

```plaintext
provider "azurerm" {
    features {}
    subscription_id   = "<SUBSCRIPTIONID>"
    tenant_id         = "<TENANTID>"
    client_id         = "<CLIENTID>"
    client_secret     = "<CLIENTSECRET>"
}
```

# Generate VPN certificate

Pre-requisites:

- `winget` package manager

1\. Execute `p2s-vpn-cert-gen.ps1`

2\. Input private key when prompted with `Enter Password to Export Client Cert (with Private Key)`

3\. Input private key again when prompted to extract private key details via `openssl`

# Deploy Infrastructure

1\. Create zip archive of the `rtlab` folder

2\. Upload zip archive to Azure using Cloud Shell

![image](https://github.com/hamzajazib/rtlab/assets/82419998/e4f0edf7-ed26-427d-9b6f-c8403fd3a6cd)


3\. Extract archive

4\. Run `rtlab\tf-deploy.ps1`

![image](https://github.com/hamzajazib/rtlab/assets/82419998/11e4051e-9b08-4900-8b62-05f4425de646)


Wait for deployment to finish (takes around ~45-60 minutes)

![image](https://github.com/hamzajazib/rtlab/assets/82419998/446ce8b6-0409-41c9-a152-498705f27490)


### Output

Output containing credentials and SSH keys are saved to `rtlab/Terraform/outputs.txt`

```json
{
  "password_admin_ubuntu": {
    "sensitive": true,
    "type": "string",
    "value": "<REDACTED>"
  },
  "password_admin_soc": {
    "sensitive": true,
    "type": "string",
    "value": "<REDACTED>"
  },
  "password_admin_win1": {
    "sensitive": true,
    "type": "string",
    "value": "<REDACTED>"
  },
  "password_admin_win2": {
    "sensitive": true,
    "type": "string",
    "value": "<REDACTED>"
  },
  "password_admin_win3": {
    "sensitive": true,
    "type": "string",
    "value": "<REDACTED>"
  },
  "password_admin_winserver": {
    "sensitive": true,
    "type": "string",
    "value": "<REDACTED>"
  },
  "password_admin_winserver_safemode": {
    "sensitive": true,
    "type": "string",
    "value": "<REDACTED>"
  },
  "key_data_kali": {
    "sensitive": false,
    "type": "string",
    "value": "ssh-rsa <REDACTED> generated-by-azure"
  },
  "key_data_ubuntu": {
    "sensitive": false,
    "type": "string",
    "value": "ssh-rsa <REDACTED> generated-by-azure"
  },
  "resource_group_name": {
    "sensitive": false,
    "type": "string",
    "value": "RTLAB"
  }
}
<REDACTED:VPNClientConfigurationArchiveDownloadURL>
```

# Configure VPN client

1\. After successful deployment, download the VPN client configuration archive from the link in the output

![image](https://github.com/hamzajazib/rtlab/assets/82419998/8e4b59ca-df7c-4f54-8ef1-32b6c730c9fb)


2\. Extract archive

3\. Copy `PRIVATE KEY` data and `P2SChildCert` data from `rtlab\Terraform\VPNcerts\profileinfo.txt` and put them in `vpnclientconfiguration\OpenVPN\vpnconfig.ovpn` using any text editor

![image](https://github.com/hamzajazib/rtlab/assets/82419998/6127d869-72f1-4079-8c9b-44ddb1ff55d0)


![image](https://github.com/hamzajazib/rtlab/assets/82419998/5d0655a4-9476-466c-a1e8-0574b179a4b4)


![image](https://github.com/hamzajazib/rtlab/assets/82419998/acd56d47-294f-4bc3-a533-2b5fb7dd50c0)


![image](https://github.com/hamzajazib/rtlab/assets/82419998/a56a75f2-0484-4ec6-b2b5-ab09cf147f27)


# Put VMs to stopped(de-allocated) state

VMs on Azure are billed in both `running` and `stopped` state, as resources remain allocated in the datacenter for these two states. In the `stopped (deallocated)` state, VMs don't incur a cost, although OS disks reserved for the VMs will be still billed.

`rtlab/tf-deploy.ps1` automatically stops all VMs after deployment to save costs. However, after using lab VMs, please use the `rtlab/dealloc-all-vm.ps1` script to deallocate resources and save costs.

![image](https://github.com/hamzajazib/rtlab/assets/82419998/72a631c1-21bc-4472-80ad-d29d3b1066e1)


# View Console Output

On the VM console output for the custom script extension can be found in a JSON file located at : `C:\Packages\Plugins\Microsoft.Compute.CustomScriptExtension\<version>\Status`

Azure command execution and script handling logs (i.e logs detailing the downloading and running the script) can be found at : `C:\WindowsAzure\Logs\Plugins\Microsoft.Compute.CustomScriptExtension\<version>`

# Destroy resources

Run `rtlab/tf-destroy.ps1` to automatically destroy all resources created by the Terraform execution plan earlier
