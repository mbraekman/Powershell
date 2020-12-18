param(
   [string][parameter(Mandatory = $true)] $targetFolderPath,
   [string][parameter(Mandatory = $true)] $storageContainerName,
   [string][parameter(Mandatory = $true)] $storageAccountResourceId,
   [string][parameter(Mandatory = $false)] $storageContainerPermissions = "Off",
   [string][parameter(Mandatory = $false)] $prefix = ""
)

#Storage Account details
$storageAccountResource = Get-AzureRmResource -ResourceId $storageAccountResourceId
$storageAccount = Get-AzureRmStorageAccount -ResourceGroupName $storageAccountResource.ResourceGroupName -Name $storageAccountResource.Name


#Create the blob container if not yet made
try{
    Get-AzureStorageContainer -Context $storageAccount.Context -Name $storageContainerName -ErrorAction Stop
}
catch{
    Write-Host "Creating Storage Container $storageContainerName"
    New-AzureStorageContainer -Context $storageAccount.Context -Name $storageContainerName -Permission $storageContainerPermissions
} 



foreach($file in Get-ChildItem ("$targetFolderPath") -File)
{
    #Read schema name
	$blobFileName = $prefix + $file.Name

    #upload the files to blob storage.
    $blobUri = (Set-AzureStorageBlobContent -File $file.FullName -Container $storageContainerName -Blob $blobFileName -Context $storageAccount.Context -Force).ICloudBlob.uri.AbsoluteUri
    Write-Host "Uploaded the file to Blob Storage: " $($blobUri)
}