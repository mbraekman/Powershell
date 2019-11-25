param(
    [Parameter(Mandatory=$true)][string]$Action = $(throw "Action is required [start|stop]"),
    [Parameter(Mandatory=$true)][string]$ResourceGroupName = $(throw "ResourceGroup is required"),
    [Parameter(Mandatory=$true)][string]$DataFactoryName = $(throw "The name of the data factory is required"),
    [Parameter(Mandatory=$true)][string]$DataFactoryTriggerName = $(throw "The name of the trigger is required"),
    [Parameter(Mandatory=$false)][switch]$FailWhenTriggerIsNotFound = $false
)

try
{
    $DataFactory = Get-AzureRmDataFactoryV2 -ResourceGroupName $ResourceGroupName -Name $DataFactoryName -ErrorAction Stop
}
catch
{
    throw "Error finding data factory '$DataFactoryName' in resource group '$ResourceGroupName'"
}

try {
    $DataFactoryTrigger = Get-AzureRmDataFactoryV2Trigger -ResourceGroupName $ResourceGroupName -DataFactoryName $DataFactoryName -Name $DataFactoryTriggerName -ErrorAction Stop
}
catch {
    $message = "Error retrieving trigger '$DataFactoryTriggerName' in data factory '$DataFactoryName'"
    if($FailWhenTriggerIsNotFound)
    {
        throw $message
    }
    else {
        Write-Host $message
        Write-Host "Skipping the '$Action'-operation."
        $Action = "skip"
    }
}

if($Action -eq "start")
{
    try {
        if($null -ne $DataFactoryTrigger)
        {
            Start-AzureRmDataFactoryV2Trigger -ResourceGroupName $ResourceGroupName -DataFactoryName $DataFactoryName -Name $DataFactoryTriggerName -Force -ErrorAction Stop
        }
    }
    catch {
        throw "Error starting trigger '$DataFactoryTriggerName' in data factory '$DataFactoryName'"
    }
}

if($Action -eq "stop")
{
    try {
        if($null -ne $DataFactoryTrigger)
        {
            Stop-AzureRmDataFactoryV2Trigger -ResourceGroupName $ResourceGroupName -DataFactoryName $DataFactoryName -Name $DataFactoryTriggerName -Force -ErrorAction Stop
        }
    }
    catch {
        throw "Error stopping trigger '$DataFactoryTrigger' in data factory '$DataFactoryName'"
    }
}