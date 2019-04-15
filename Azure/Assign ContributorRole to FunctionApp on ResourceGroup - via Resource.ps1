$resourceGroupName = "%ResourceGroupName%"
$functionAppName = "%FunctionAppName%"
$functionAppResourceGroupName = "%FunctionAppResourceGroupName%"

Write-Host "Assigning Contributor access for the FunctionApp to the resource group."

try{
    $funtionApp = Get-AzureRmResource -ResourceGroupName $functionAppResourceGroupName -Name $functionAppName
    [guid]$flowhandlerJobPrincipalId = $funtionApp.identity.PrincipalId
    New-AzureRmRoleAssignment -ObjectId $flowhandlerJobPrincipalId -RoleDefinitionName "Contributor" -ResourceGroupName $resourceGroupName

    Write-Host "Contributor access granted!"
}catch [Microsoft.Rest.Azure.CloudException]
{
    [Microsoft.Rest.Azure.CloudException]$cloudException = $_.Exception
    Write-Warning "[CloudException] Failed to grant access!"
    $ErrorMessage = $_.Exception.Message
    Write-Warning "Error: $ErrorMessage"
}catch
{
    Write-Warning "Failed to grant access!"
    $ErrorMessage = $_.Exception.Message
    Write-Warning "Error: $ErrorMessage"
}