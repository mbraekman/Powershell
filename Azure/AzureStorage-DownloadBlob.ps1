param(
   [String][Parameter(Mandatory = $true)]$ResourceGroupName,
   [String][Parameter(Mandatory = $true)]$StorageAccountName,
   [string][parameter(Mandatory = $true)] $storageContainerName,
   [string][parameter(Mandatory = $true)] $blobName,
   [string][parameter(Mandatory = $true)] $targetFolderPath,
   [string][Parameter(Mandatory = $false)] $sasToken

)

## Get the storage account context  

$storageContext = $null
if(!$sasToken) {
    Write-Host 'Using service principal'
    $storageAccount = Get-AzStorageAccount -ResourceGroupName $ResourceGroupName -Name $StorageAccountName
    $storageContext = $storageAccount.Context
}
else
{
    Write-Host 'Using sas token'
    $storageContext = New-AzStorageContext -StorageAccountName $storageAccountName -SasToken $sasToken
}

#Get the blob content and write to the given location
Get-AzStorageBlobContent -Container $storageContainerName -Blob $blobName -Destination $targetFolderPath -Context $storageContext