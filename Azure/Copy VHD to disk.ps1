Import-Module azure
Add-AzureAccount

# Select the subscription containing the required image.
Select-AzureSubscription "<SubscriptionName>"
 
# Set the path to the vhd-file
$sourceVHD = "https://<namespace>.blob.core.windows.net/Images/<image-name>.vhd"
# Set the destination file path
$destinationVHD = "F:\VM\<image-name>.vhd"
 
# Start the process of saving the VHD-file to disk.
Save-AzureVhd -Source $sourceVHD -LocalFilePath $destinationVHD `
             -NumberOfThreads 5