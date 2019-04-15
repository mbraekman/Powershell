$resourceGroupName = "%ResourceGroupName%"

Write-Host "Retrieving locks in resourceGroup '$resourceGroupName'"

$locks = Get-AzureRmResourceLock -ResourceGroupName $resourceGroupName

if($locks.Count > 0)
{
    Write-Host "Start removing all locks in resourceGroup '$resourceGroupName'"

    Foreach($lock in $locks)
    {
        $lockId = $lock.LockId
        Write-Host "Removing the lock with ID:" $lockId
        #Remove-AzureRmResourceLock -LockId $lockId -Force
    }

    Write-Host "All locks in resourceGroup '$resourceGroupName' have been removed"
}
else
{
    Write-Host "No locks to remove."
}