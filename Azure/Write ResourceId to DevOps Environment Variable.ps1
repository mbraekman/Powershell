param(
   [string][parameter(Mandatory = $true)] $resourceGroupName,
   [string][parameter(Mandatory = $true)] $resourceName,
   [string][parameter(Mandatory = $true)] $variableName,
   [string][parameter(Mandatory = $false)] $environmentVariableName = "ArmOutputs"
)

$resource = Get-AzureRmResource -ResourceGroupName $resourceGroupName -Name $resourceName

$json = '{"' + $variableName + '": {"type":"string","value":"' + $resource.ResourceId + '"}}'

Write-Host "##vso[task.setvariable variable=$environmentVariableName;]$json "
Write-Host "Environment variable 'env:$environmentVariableName' has been set to $json"