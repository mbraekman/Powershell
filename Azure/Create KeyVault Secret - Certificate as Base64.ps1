# Use this script to upload a certificate as plain text (multiline-support) into Azure KeyVault

param (
    [string][Parameter(Mandatory=$true)] $filePath = $(throw "The path to the file is required."),
    [string][Parameter(Mandatory=$true)] $keyVaultName = $(throw "The path to the file is required."),
    [string][Parameter(Mandatory=$true)] $secretName = $(throw "The path to the file is required."),
    [bool][parameter(Mandatory = $false)] $loggedIn = $true,
    [string][parameter(Mandatory = $false)] $subscriptionId = ""
)

if(-not($loggedIn))
{
    # Parameter indicates that the user has not been authenticated yet.
    Write-Host('Logging in.')
    Connect-AzureRmAccount -ErrorAction Stop
    Write-Host('Logged in.')
}
if($subscriptionId)
{
    # SubscriptionId has been provided - switching to the required Azure Subscription
    Write-Host('Selecting the subscription...')
    Select-AzureRmSubscription -SubscriptionId $subscriptionId -ErrorAction Stop
    Write-Host('Selected the subscription.')
}

# Perform the deployment based on the provided ARM-template and parameter file, if provided.
Write-Host("Creating KeyVault secret...")

$fileContentInBytes = get-content $filePath -Encoding Byte
$fileContentAsBase64 = [System.Convert]::ToBase64String($fileContentInBytes)
Set-AzKeyVaultSecret -VaultName $keyVaultName -SecretName $secretName -SecretValue (ConvertTo-SecureString -String $fileContentAsBase64 -force -AsPlainText ) -ErrorAction Stop

Write-Host("Secret '$secretName' has been created.")