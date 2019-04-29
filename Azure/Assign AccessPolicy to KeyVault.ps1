# The ID of the subscription in which the keyVault is located
$subscriptionId = ''

# The ID of the user-account to be granted permissions - to be found in the AD
$userObjectId = ''

# The name of the keyVault to which the user is to be granted access.
$keyVaultName = ''

# Below permissions match the default "Key, Secret & Certificate Management"-template.
[String[]] $permissionsToSecrets = ("get","list","set","delete","recover","backup","restore")
[String[]] $permissionsToKeys = ("get","list","update","create","import","delete","recover","backup","restore")
[String[]] $permissionsToCertificates = ("get","list","update","create","import","delete","recover","backup","restore","Managecontacts","Getissuers","Listissuers","Setissuers","Deleteissuers","Manageissuers","Purge")

# Login to Azure
Login-AzureRmAccount

# Select the correct subscription
Select-AzureRmSubscription -SubscriptionId $subscriptionId

try{
    # Create/Update an AccessPolicy for the specified user, with the specified permissions.
    Set-AzureRmKeyVaultAccessPolicy -VaultName $keyVaultName -ObjectId $userObjectId -PermissionsToSecrets $permissionsToSecrets -PermissionsToKeys $permissionsToKeys -PermissionsToCertificates $permissionsToCertificates
    Write-Information "Access policy has been created."
}
catch
{
    $errorMessage = $_.Exception.Message
    Write-Error "Failed to create access policy: $errorMessage"
}