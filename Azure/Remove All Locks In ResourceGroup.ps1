# If executed from Azure DevOps release pipeline, set Azure PowerShell Version to 5.1.1
# Currently, using the latest version will return 0 locks.

param (
    [Parameter(Mandatory=$true)][string]$resourceGroupName = $(throw "ResourceGroupName is required")
)

Write-Host "Retrieving locks in resourceGroup '$resourceGroupName'"

$locks = Get-AzureRmResourceLock -ResourceGroupName $resourceGroupName

if($locks.Count -gt 0)
{
    Write-Host "Start removing all locks in resourceGroup '$resourceGroupName'"

    Foreach($lock in $locks)
    {
        $lockId = $lock.LockId
        Write-Host "Removing the lock with ID:" $lockId
        Remove-AzureRmResourceLock -LockId $lockId -Force
    }

    Write-Host "All locks in resourceGroup '$resourceGroupName' have been removed"
}
else
{
    Write-Host "No locks to remove."
}