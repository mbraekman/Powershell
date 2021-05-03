param(
    [string][Parameter(Mandatory = $true)] $ResourceGroupName = $(throw "Resource group name is required"),
    [string][parameter(Mandatory = $true)] $ServiceName = $(throw "API managgement service name is required"),
    [string][parameter(Mandatory = $true)] $DisplayName = $(throw "The displayName is required"), # Specify the displayName to be assigned to the group - this has to be unique per APIM instance.
    [string][parameter(Mandatory = $false)] $GroupId = $($($DisplayName -replace '[^\w-]', '') -replace ' ', '-').ToLower(),
    [string][parameter(Mandatory = $false)] $Description, # the value to be assigned as the subscription.
    [string][parameter(Mandatory = $false)][ValidateSet('custom', 'external', 'system')] $GroupType = "custom",
    [string][parameter(Mandatory = $false)] $ExternalId = $null,
    [string][parameter(Mandatory = $false)] $ApiVersion = "2019-12-01",
    [string][parameter(Mandatory = $false)] $SubscriptionId,
    [string][parameter(Mandatory = $false)] $AccessToken
)

# Validate of the APIM-instance for the given information exists
try
{
    $apimContext = Get-AzApiManagement -ResourceGroupName $ResourceGroupName -Name $ServiceName -ErrorAction Stop
}
catch
{
    $ErrorMessage = $_.Exception.Message
    Write-Warning "Error: $ErrorMessage"
    throw "No API Management instance named '$ServiceName' could be found in resource group '$ResourceGroupName'"
}

if($SubscriptionId -eq "" -or $AccessToken -eq ""){
    # Request accessToken in case the script contains records
    $token = Get-AzCachedAccessToken

    $AccessToken = $token.AccessToken
    $SubscriptionId = $token.SubscriptionId
}

# Build the full URL to create a group in APIM
$fullUrl = "https://management.azure.com/subscriptions/$SubscriptionId/resourceGroups/$ResourceGroupName/providers/Microsoft.ApiManagement/service/$ServiceName/groups/$($GroupId)?api-version=$ApiVersion"
  
try
{
    Write-Host "Attempting to create/update the group '$($DisplayName)'"
    
    $jsonRequest = ConvertTo-Json -Depth 2 @{
            'properties' = @{
                'displayName' = $DisplayName
                'description' = $Description
                'externalId' = $ExternalId
                'type' = $GroupType
            }
        }

    $params = @{
        Method = 'Put'
        Headers = @{ 
	        'authorization'="Bearer $AccessToken"
        }
        URI = $fullUrl
        Body = $jsonRequest
    }

    $web = Invoke-WebRequest @params -ErrorAction Stop
   
    Write-Verbose $web

    Write-Host "Group '$($DisplayName)' has been created/updated."

    return $GroupId
}
catch {
    Write-Warning "Failed to create/update the group '$($DisplayName)' for the developer portal of APIM instance $ServiceName"
    $ErrorMessage = $_.Exception.Message
    Write-Warning "Error: $ErrorMessage"
    Write-Warning $_ | ConvertTo-Json
}