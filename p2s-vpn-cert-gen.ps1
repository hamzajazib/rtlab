$CertLocation = "$pwd\Terraform\VPNcerts"
if((Test-Path -Path $CertLocation -ErrorAction SilentlyContinue) -eq $false){
    mkdir $CertLocation
    Set-Location $CertLocation
}
else {
    Set-Location $CertLocation
}

Write-Host "Removing previous certificates" -ForegroundColor Blue
gci cert:\CurrentUser\My | ? { $_.FriendlyName -eq 'P2SRoot' } | foreach { Remove-Item $_.PSPath }
gci cert:\CurrentUser\My | ? { $_.FriendlyName -eq 'P2SClient' } | foreach { Remove-Item $_.PSPath }

if ( Test-Path -Path "$CertLocation\P2SRootCert.cer" -PathType Leaf )
{
	Remove-Item -path "$CertLocation\P2SRootCert.cer"
	Write-Host "Removed $CertLocation\P2SRootCert.cer" -ForegroundColor Green
}

if ( Test-Path -Path "$CertLocation\P2SChildCert.cer" -PathType Leaf )
{
	Remove-Item -path "$CertLocation\P2SChildCert.cer"
	Write-Host "Removed $CertLocation\P2SChildCert.cer" -ForegroundColor Green
}

if ( Test-Path -Path "$CertLocation\P2SChildCert.pfx" -PathType Leaf )
{
	Remove-Item -path "$CertLocation\P2SChildCert.pfx"
	Write-Host "Removed $CertLocation\P2SChildCert.pfx" -ForegroundColor Green
}

Write-Host "Generating new certificates" -ForegroundColor Blue

# Create a self-signed root certificate
$params = @{
    Type = 'Custom'
    Subject = 'CN=P2SRootCert'
    FriendlyName = 'P2SRoot'
    KeySpec = 'Signature'
    KeyExportPolicy = 'Exportable'
    KeyUsage = 'CertSign'
    KeyUsageProperty = 'Sign'
    KeyLength = 2048
    HashAlgorithm = 'sha256'
    NotAfter = (Get-Date).AddMonths(24)
    CertStoreLocation = 'Cert:\CurrentUser\My'
    
}
$cert = New-SelfSignedCertificate @params

# Generate a client certificate
New-SelfSignedCertificate `
    -Type 'Custom' `
    -Subject 'CN=P2SChildCert' `
    -DnsName 'P2SChildCert' `
    -FriendlyName "P2SClient" `
    -KeySpec 'Signature' `
    -KeyExportPolicy 'Exportable' `
    -KeyLength 2048 `
    -HashAlgorithm 'sha256' `
    -NotAfter (Get-Date).AddMonths(18) `
    -CertStoreLocation 'Cert:\CurrentUser\My' `
    -Signer $cert `
    -TextExtension @('2.5.29.37={text}1.3.6.1.5.5.7.3.2')

Write-Host "Generated new certificates" -ForegroundColor Green

#Export Certficates
Write-Host "Exporting Certificates" -ForegroundColor Blue
$RootCert = (Get-ChildItem -Path "Cert:\CurrentUser\My\" | Where-Object -Property subject -Match P2SRootCert)
$ClientCert = (Get-ChildItem -Path "Cert:\CurrentUser\My\" | Where-Object -Property subject -Match P2SChildCert)

Export-Certificate -Type CERT -Cert $RootCert -FilePath "$CertLocation\P2SRootCertTemp.cer"
Export-Certificate -Type CERT -Cert $ClientCert -FilePath "$CertLocation\P2SChildCert.cer"

C:\windows\system32\certutil.exe -encode "$CertLocation\P2SRootCertTemp.cer" 'P2SRootCert.cer'
Remove-Item -path "$CertLocation\P2SRootCertTemp.cer"

Write-Host "~Root Certificate~"
Get-Content $CertLocation\P2SRootCert.cer #Store this output to variables.tf

$SecurePassword = Read-Host -Prompt "Enter Password to Export Client Cert (with Private Key)" -AsSecureString
$ThumbPrint = $ClientCert.Thumbprint
$ExportPrivateCertPath = "Cert:\CurrentUser\My\$ThumbPrint"
Export-PfxCertificate -FilePath "$CertLocation\P2SChildCert.pfx" -Password $SecurePassword -Cert $ExportPrivateCertPath

Write-Host "Exported Certificates" -ForegroundColor Green

# Install OpenSSL Light and get configuration
winget install openssl-light
Invoke-WebRequest -Uri 'http://web.mit.edu/crypto/openssl.cnf' -OutFile "$CertLocation\openssl.cnf"
Set-Location $CertLocation

#if (-not (Test-Path $profile)) {
    #New-Item -Path $profile -ItemType File -Force
#}
#'$env:path = "C:\ProgramData\chocolatey\bin;C:\Windows\System32;C:\Windows\System32\WindowsPowerShell\;c:\windows;c:\windows\system32\wbem;c:\windows\system32\openssh;c:\program files\git\cmd;%USERPROFILE%\AppData\Local\Microsoft\WindowsApps;C:\Program Files\Microsoft VS Code Insiders\bin;%USERPROFILE%\AppData\Local\GitHubDesktop\bin;%USERPROFILE%\AppData\Local\Microsoft\WindowsApps;C:\Program Files (x86)\Microsoft Visual Studio"' | Out-File $profile -Append
#'$env:path = "C:\Program Files\OpenSSL\bin"' | Out-File $profile -Append
#'$env:OPENSSL_CONF = "C:\temp\VPN\openssl.cnf"' | out-file $profile -Append
#. $profile

#############################
#    Extract Private Key    #
#############################
#. $profile
$OpenSSLArgs = "pkcs12 -in $CertLocation\P2SChildCert.pfx -nodes -out $CertLocation\profileinfo.txt"
Start-Process "${env:ProgramFiles}\OpenSSL-Win64\bin\openssl" $OpenSSLArgs
Write-Host "Extracted Private Key" -ForegroundColor Green

#Export P2SRootCert for Terraform
$cert = Get-Content $CertLocation\P2SRootCert.cer
$certstring = "$cert"
$certstring = $certstring.Replace("-----BEGIN CERTIFICATE----- ","")
$certstring = $certstring.Replace(" -----END CERTIFICATE-----","")
$certstring | Out-File -FilePath $CertLocation\P2SRootCert.txt -NoNewline -Force