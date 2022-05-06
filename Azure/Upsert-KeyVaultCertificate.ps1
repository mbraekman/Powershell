## Give in params as follows:
## Update-KeyVaultSecrets.ps1 -keyVaultName "mykeyvault" -certificateName "myCertificate" -certificatePath "pathToCertificate" -certificatePassword "password"
## This will result in a certificate named "myCertificate".

Param(
  [string] [Parameter(Mandatory=$true)] $keyVaultName,
  [string] [Parameter(Mandatory=$true)] $certificateName,
  [string] [Parameter(Mandatory=$true)] $certificatePath,
  [string] [Parameter(Mandatory=$true)] $certificatePassword
)

## Verify access to Key Vault
$keyVault = Get-AzKeyVault -Name $keyVaultName
if($null -eq $keyVault) {
  Write-Error "Key Vault could not be found"
}

## Check if a file can be found on the given certificateFilePath
$certificateFile = Get-Content $certificatePath -ErrorAction SilentlyContinue
if($null -eq $certificateFile) {
  Write-Error "No certificate could be found at the given location"
}

$securePassword = ConvertTo-SecureString $certificatePassword -AsPlainText -Force
Import-AzKeyVaultCertificate -VaultName $keyVaultName -Name $certificateName -FilePath $certificatePath -Password $securePassword
