#Install-Module AzureRM.Compute,AzureRM.Network

Import-Module AzureRM.Compute
Import-Module AzureRM.Network

#Log in to Azure and select the correct subscription
Login-AzureRMAccount
Select-AzureRmSubscription -SubscriptionName '<name of the subscription>'

$useExistingVN = $true
$existingVNRgName = '<resource group that contains the existing Virtual Network>'
$existingVNName = '<name of the existing Virtual Network>'
$useExistingIP = $true
$existingIPRgName = '<resource group that contains the existing Public IP>'
$existingIPName = '<name of the existing Public IP>'
$useExistingNIC = $true
$existingNICRgName = '<resource group that contains the existing NIC>'
$existingNICName = '<name of the existing NIC>'

$resourceGroupNameImage = '<name of the resourcegroup where the image is located>'
$imageName = '<name of the image>'

$resourceGroupNameVM = '<name of the resourcegroup where the VM should be created>'
$location = '<region that should host the VM>' # i.e. 'West Europe'
$vmName = '<Name to be assigned to the VM>'
$computerName = '<computerName to be assigned>'
$vmSize = '<size to be assigned to the VM>' # i.e. Basic_A2
$accountType = '<type of storage account>' # i.e. StandardLRS

#Retrieve information about the image to use
$image = Get-AzureRmImage -ImageName $imageName -ResourceGroupName $resourceGroupNameImage

If($useExistingVN)
{
    "Retrieving information of existing Virtual Network";
    $virtualNetwork = Get-AzureRmVirtualNetwork -Name $existingVNName -ResourceGroupName $existingVNRgName
}
Else
{
    "About to create a new Virtual Network";
    $subnetName = '<name of the subnet>'
    $singleSubnet = New-AzureRmVirtualNetworkSubnetConfig -Name $subnetName -AddressPrefix 10.0.0.0/24
    $virtualNetwork = New-AzureRmVirtualNetwork -Name $existingVNName -ResourceGroupName $existingVNRgName -Location $location -AddressPrefix 10.0.0.0/16 -Subnet $singleSubnet
}

If($useExistingIP)
{
    "Retrieving information of existing Public IP";
    $publicIP = Get-AzureRmPublicIpAddress -Name $existingIPName -ResourceGroupName $existingIPRgName
}
Else
{
    "About to create a new Public IP";
    $publicIP = New-AzureRmPublicIpAddress -Name $existingIPName -ResourceGroupName $existingIPRgName -Location $location -AllocationMethod Dynamic
}

If($useExistingNIC)
{
    "Retrieving information of existing Network Interface";
	$nic = Get-AzureRmNetworkInterface -Name $existingNICName -ResourceGroupName $existingNICRgName
}
Else
{
    "About to create a new Network Interface";
	$nic = New-AzureRmNetworkInterface -Name $Interface -ResourceGroupName $existingNICRgName -Location $location -SubnetId $virtualNetwork.Subnets[0].Id -PublicIpAddressId $publicIP.Id
}

# Specify the credentials to be set up on the VM
$cred = Get-Credential

# Initialize + prepare VM settings
$vm = New-AzureRmVMConfig -VMName $vmName -VMSize $vmSize
$vm = Set-AzureRmVMSourceImage -VM $vm -ID $image.ID
$vm = Set-AzureRmVMOSDisk -VM $vm -StorageAccountType $accountType -DiskSizeInGB 128 -CreateOption FromImage -Caching ReadWrite
$vm = Set-AzureRmVMOperatingSystem -VM $vm -Windows -ComputerName $computerName -Credential $cred -ProvisionVMAgent -EnableAutoUpdate
$vm = Add-AzureRmVMNetworkInterface -VM $vm -Id $nic.Id

# Create the VM
#New-AzureRm -VM $vm -ResourceGroupName $resourceGroupNameVM -Location $location
"Finished";