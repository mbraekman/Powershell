
Import-Module azure
Add-AzureAccount

Select-AzureSubscription "Visual Studio Premium met MSDN"

### Source VHD (West US) - anonymous access container ###
$srcUri = "bloburi"

### Target Storage Account (East US) ###
$storageAccount = "youraccount"
$storageKey = "yourstoragekey"

### Create the destination context for authenticating the copy
$destContext = New-AzureStorageContext  –StorageAccountName $storageAccount `
                                        -StorageAccountKey $storageKey  
 
### Target Container Name
$containerName = "copiedvhd"

### Create the target container in storage
New-AzureStorageContainer -Name $containerName -Context $destContext 
 
### Start the Asynchronous Copy ###
$blob1 = Start-AzureStorageBlobCopy -srcUri $srcUri `
                                    -DestContainer $containerName `
                                    -DestBlob "image.vhd" `
                                    -DestContext $destContext 
