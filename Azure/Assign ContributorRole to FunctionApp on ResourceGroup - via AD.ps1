param (
    [Parameter(Mandatory=$true)][string]$resourceGroupName = $(throw "ResourceGroupName is required"),
	[Parameter(Mandatory=$true)][string]$functionAppName = $(throw "FunctionAppName is required")
)

Write-Host "Assigning Contributor access for the FlowHandlerJob to the resource group."

try{
    $functionAppADPrincipal = Get-AzADServicePrincipal $functionAppName
    New-AzureRmRoleAssignment -ObjectId $functionAppADPrincipal.Id -RoleDefinitionName "Contributor" -ResourceGroupName $resourceGroupName

    Write-Host "Contributor access granted!"
}catch [Microsoft.Rest.Azure.CloudException]
{
    Write-Warning "Failed to grant access!"
    $ErrorMessage = $_.Exception.Message
    Write-Warning "Error: $ErrorMessage"
}catch
{
    Write-Warning "Failed to grant access!"
    $ErrorMessage = $_.Exception.Message
    Write-Warning "Error: $ErrorMessage"
}