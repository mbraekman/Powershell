param(
   [string][parameter(Mandatory = $true)] $templatePath,
   [string][parameter(Mandatory = $true)] $resourceGroup,
   [string][parameter(Mandatory = $false)] $parameterPath,
   [string][parameter(Mandatory = $false)] $deploymentName = (Get-Date -f yyyyMMdd-HHmmss),
   [bool][parameter(Mandatory = $false)] $loggedIn = $true,
   [string][parameter(Mandatory = $false)] $subscriptionId = ""

)

### Based on the fact whether you are passing along the subscriptionId, the script is assuming you are already logged in/connected to the correct Azure Subscription or this still needs to happen.
### Below command allows you to easily deploy a resource using ARM-template + parameter-file within a certain resourceGroup

if(-not($loggedIn))
{
    # Parameter indicates that the user has not been authenticated yet.
    Write-Host('Logging in.')
    Connect-AzAccount
    Write-Host('Logged in.')
}
if($subscriptionId)
{
    # SubscriptionId has been provided - switching to the required Azure Subscription
    Write-Host('Selecting the subscription...')
    Select-AzSubscription -SubscriptionId $subscriptionId -ErrorAction Stop
    Write-Host('Selected the subscription.')
}

# Perform the deployment based on the provided ARM-template and parameter file, if provided.
Write-Host('Executing deployment...')
if($parameterPath)
{
    New-AzResourceGroupDeployment -Name $deploymentName -ResourceGroupName $resourceGroup -TemplateFile $templatePath -TemplateParameterFile $parameterPath -ErrorAction Stop
}
else
{
    New-AzResourceGroupDeployment -Name $deploymentName -ResourceGroupName $resourceGroup -TemplateFile $templatePath -ErrorAction Stop
}
Write-Host('Deployment completed.')