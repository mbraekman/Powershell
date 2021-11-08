param (
    [string][Parameter(Mandatory=$true)] $keyVaultName = $(throw "Specify the name of the Key Vault in which to create the secret"),
    [string][Parameter(Mandatory=$true)] $secretName = $(throw "Specify the name of the secret to be created"),
    [bool][parameter(Mandatory = $false)] $loggedIn = $true,
    [string][parameter(Mandatory = $false)] $subscriptionId = ""
)

if(-not($loggedIn))
{
    # Parameter indicates that the user has not been authenticated yet.
    Write-Host('Logging in.')
    Connect-AzAccount -ErrorAction Stop
    Write-Host('Logged in.')
}
if($subscriptionId)
{
    # SubscriptionId has been provided - switching to the required Azure Subscription
    Write-Host('Selecting the subscription...')
    Select-AzSubscription -SubscriptionId $subscriptionId -ErrorAction Stop
    Write-Host('Selected the subscription.')
}

# Create a new SecureString-object, which does not have any value by default
$emptySecret = (new-object System.Security.SecureString)

# Create the new secret in Key Vault
Set-AzKeyVaultSecret -VaultName $keyVaultName -Name $secretName -SecretValue $emptySecret

Write-Host "The secret '$secretName' has been created in the Key Vault '$keyVaultName'"