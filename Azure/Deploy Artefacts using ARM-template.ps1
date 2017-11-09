#Deploy Logic App using ARM-template

Login-AzureRmAccount

Select-AzureRmSubscription -SubscriptionName <yourSubscriptionName>

$ResourceGroupName = "MyResourceGroup"
$ResourceLocation = "North Europe"
$DeploymentName = "MyDeployment"
$ARMTemplatePath = "c:\MyTemplates\DeploymentARMTemplate.json"

New-AzureRmResourceGroup -Name $ResourceGroupName -Location $ResourceLocation
New-AzureRmResourceGroupDeployment -Name $DeploymentName -ResourceGroupName $ResourceGroupName -TemplateFile $ARMTemplatePath