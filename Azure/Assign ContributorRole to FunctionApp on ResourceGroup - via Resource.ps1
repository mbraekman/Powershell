param (
    [Parameter(Mandatory=$true)][string]$ResourceGroupName = $(throw "ResourceGroupName is required"),
	[Parameter(Mandatory=$true)][string]$FunctionAppResourceGroupName = $(throw "FunctionAppResourceGroupName is required"),
	[Parameter(Mandatory=$true)][string]$FunctionAppName = $(throw "FunctionAppName is required")
)

Write-Host "Assigning Contributor-rights to the FunctionApp onto resource group '$ResourceGroupName'."

try{
    $functionApp = Get-AzureRmResource -ResourceGroupName $FunctionAppResourceGroupName -Name $FunctionAppName
    [guid]$functionAppPrincipalId = $functionApp.identity.PrincipalId
    New-AzureRmRoleAssignment -ObjectId $functionAppPrincipalId -RoleDefinitionName "Contributor" -ResourceGroupName $ResourceGroupName

    Write-Host "Contributor access granted!"
}catch
{
    $ErrorMessage = $_.Exception.Message
    if($ErrorMessage.Contains("already exists"))
    {
        Write-Host "Access has already been granted"
    }
    else{
        Write-Warning "Failed to grant access!"
        Write-Host "Error: $ErrorMessage"
    }
}