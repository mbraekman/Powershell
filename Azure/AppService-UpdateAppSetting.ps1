param(
     [Parameter(Mandatory=$true)][string]$ResourceGroupName = $(throw "ResourceGroup is required"),
     [Parameter(Mandatory=$true)][string]$AppServiceName = $(throw "AppServiceName is required"),
     [Parameter(Mandatory=$true)][string]$AppServiceSettingName = $(throw "AppServiceSettingName is required"),
     [Parameter(Mandatory=$true)][string]$AppServiceSettingValue = $(throw "AppServiceSettingValue is required"),
     [Parameter(Mandatory=$false)][switch]$PrintSettingValuesIfVerbose
)

# verify if the app service exists
Write-Host "Checking if the app service with name '$appServiceName' can be found in the resource group '$ResourceGroupName'."
$appService = Get-AzWebApp -ResourceGroupName $ResourceGroupName -Name $appServiceName -ErrorAction Ignore

if($appService -eq $null) 
{
    Write-Error "No app service with name '$appServiceName' could be found in the resource group '$ResourceGroupName'."
    exit;
}

# Get current app settings in a hash table
Write-Host "App service has been found."
Write-Host "Extracting the existing application settings."
$appServiceSettings = $appService.SiteConfig.AppSettings

$existingSettings = @{ }
Write-Verbose "Existing app settings:"
foreach ($setting in $appServiceSettings) 
{
    $existingSettings[$setting.Name] = $setting.value
    if($PrintSettingValuesInVerbose) 
    {
        Write-Verbose "$($setting.Name): $($setting.Value)"
    }
    else 
    {
        Write-Verbose "$($setting.Name)"
    }
}

# Add/update the provided setting
$existingSettings[$AppServiceSettingName] = $AppServiceSettingValue

# Update the App Service Settings
Write-Host "Setting the application setting with name '$AppServiceSettingName'."
try 
{
    $updatedAppService = Set-AzWebApp -ResourceGroupName $ResourceGroupName -Name $appServiceName -AppSettings $existingSettings

    if($VerbosePreference -ne [System.Management.Automation.ActionPreference]::SilentlyContinue)
    {
        Write-Verbose "Updated app settings:"
        foreach($setting in $updatedAppService.SiteConfig.AppSettings) 
        {
            if($PrintSettingValuesInVerbose)
            {
                Write-Verbose "$($setting.Name): $($setting.Value)"
            }
            else
            {
                Write-Verbose "$($setting.Name)"
            }
        }
    }
}
catch 
{
    Write-Error "The app service settings could not be updated. Details: $_.Exception.Message"
}

Write-Host "Successfully updated the application settings of the app service '$AppServiceName' within resource group '$ResourceGroupName'."