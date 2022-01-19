param (
    [Parameter(Mandatory = $false)][string] $ResourceGroupName = "",
    [Parameter(Mandatory = $true)][string] $KeyVaultName = $(throw "Name of the Azure Key Vault is required"),
    [Parameter(Mandatory = $true)][string] $SecretName = $(throw "Name of the secret is required"),
    [Parameter(Mandatory = $true)][string] $SecretValue = $(throw "Value of the secret is required")
)

$keyVault = $null
if($ResourceGroupName -eq '') {
    Write-Verbose "Looking for the Azure Key Vault with name '$KeyVaultName'..."
    $keyVault = Get-AzKeyVault -VaultName $KeyVaultName
} else {
    Write-Verbose "Looking for the Azure Key Vault with name '$KeyVaultName' in resourcegroup '$ResourceGroupName'.."
    $keyVault = Get-AzKeyVault -VaultName $KeyVaultName -ResourceGroupName $ResourceGroupName
}

# Get all current versions of the secret
$secretVersions = Get-AzKeyVaultSecret -VaultName $KeyVaultName -Name $SecretName -IncludeVersions | Where-Object {$_.Enabled}

Foreach ($secret in $SecretVersions)
{
    if($secret.Enabled)
    {
        Set-AzKeyVaultSecretAttribute -VaultName $KeyVaultName -Name $SecretName -Version $secret.Version -Enable $false
        Write-Host "Disabled the secret with version " $secret.Version
    }
}

# Add new secret value
Write-Host 'Adding the new version of the secret'
Set-AzKeyVaultSecret -VaultName $KeyVaultName -Name $SecretName -SecretValue ($SecretValue | ConvertTo-SecureString -AsPlainText -Force) -ErrorAction Stop
Write-Host 'Added the new version of the secret'