param (
    [string][Parameter(Mandatory=$true)] $SubscriptionId = $(throw "Specify the id of the subscription hosting the event grid."),
    [string][Parameter(Mandatory=$true)] $EventGridResourceGroup = $(throw "Specify the name of the common resource group hosting the event grid."),
    [string][Parameter(Mandatory=$true)] $EventGridTopic = $(throw "Specify the name of the topic of the event grid."),
    [string][Parameter(Mandatory=$true)] $EventGridSubscriptionName = $(throw "Specify the name of the subscription."),
    [string][Parameter(Mandatory=$true)] $EventGridDeadLetterStorage = $(throw "Specify the name of the event grid dead letter storage."),
    [string][Parameter(Mandatory=$true)] $EventGridDeadLetterContainer = $(throw "Specify the name of the event grid dead letter storage container."),
    [string][Parameter(Mandatory=$true)] $FunctionAppResourceGroup = $(throw "Specify the name of the resource group hosting the app service."),
    [string][Parameter(Mandatory=$true)] $FunctionAppName = $(throw "Specify the name of the app service."),
    [string][Parameter(Mandatory=$true)] $EventHandlerFunctionName = $(throw "Specify the name event handler function."),
    [string][Parameter(Mandatory=$true)] $SubjectName = $(throw "Specify the value to be used in the subject-begins-with parameter.")
)


$eventGridRGPath = "/subscriptions/$SubscriptionId/resourceGroups/$EventGridResourceGroup"
$eventGridTopicResourceId = "$eventGridRGPath/providers/Microsoft.EventGrid/topics/$EventGridTopic"

$eg = az eventgrid event-subscription show --name $EventGridSubscriptionName --source-resource-id $eventGridTopicResourceId | ConvertFrom-Json

if ($eg -eq $null)
{
  az eventgrid event-subscription create `
  --name $EventGridSubscriptionName `
  --deadletter-endpoint $eventGridRGPath/providers/Microsoft.Storage/storageAccounts/$EventGridDeadLetterStorage/blobServices/default/containers/$EventGridDeadLetterContainer `
  --endpoint-type azurefunction `
  --endpoint /subscriptions/$SubscriptionId/resourceGroups/$FunctionAppResourceGroup/providers/Microsoft.Web/sites/$FunctionAppName/functions/$EventHandlerFunctionName `
  --subject-begins-with $SubjectName `
  --source-resource-id $eventGridTopicResourceId
}