param(
    [string][Parameter(Mandatory = $true)] $ResourceGroupName = $(throw "Resource group name is required"),
    [string][parameter(Mandatory = $true)] $ServiceName = $(throw "API managgement service name is required"),
    [string][parameter(Mandatory = $true)] $UserId = $(throw "The id of the user for whom a subscription is to be created. This can be provided either as the full path starting with '/subscriptions/' or the internal APIM user-name, e.g. firstname-lastname-company-com"),
    [string][parameter(Mandatory = $false)] $ProductName = $(if($ApiName -eq ''){throw "Either a productName or apiName is required in order to set the scope, e.g.: -ProductName '{productName}' or -ApiName '{apiName}'"}),
    [string][parameter(Mandatory = $false)] $ApiName = $(if($ProductName -eq ''){throw "Either a productName or apiName is required in order to set the scope, e.g.: -ProductName '{productName}' or -ApiName '{apiName}'"}),
    [string][parameter(Mandatory = $false)] $DisplayName, # Specify the displayName to be assigned to the subscription - this has to be unique per APIM instance.
    [string][parameter(Mandatory = $false)] $ApimSubscriptionId, # the value to be assigned as the id of the subscription.
    [switch][parameter(Mandatory = $false)] $AllowTracing = $false,
    [switch][parameter(Mandatory = $false)] $SendNotification = $false,
    [switch][parameter(Mandatory = $false)] $LegacyDeveloperPortal = $false,
    [string][parameter(Mandatory = $false)] $ApiVersion = "2019-12-01",
    [string][parameter(Mandatory = $false)] $SubscriptionId,
    [string][parameter(Mandatory = $false)] $AccessToken
)
   
function RetrieveScopeObject{
    param(
        [string] $endpointUrl,
        [string] $scopeType,
        [string] $scopeName
    )

    $params = @{
            Method = 'Get'
            Headers = @{ 
	            'authorization'="Bearer $AccessToken"
            }
            URI = $endpointUrl
        }
        
        $jsonScopeObjectsResponse = Invoke-WebRequest @params -ErrorAction Stop
        Write-Verbose $jsonScopeObjectsResponse
        
        $scopeObjectsResponse = ConvertFrom-Json $jsonScopeObjectsResponse
        if($scopeObjectsResponse.Count -ne 1)
        {
            throw "The $scopeType '$scopeName' could not be found."
        }
        
        return $scopeObjectsResponse.Value[0]
}

$AppType = 'developerPortal' # developerPortal = new portal | portal = legacy portal
if($LegacyDeveloperPortal)
{
    $AppType = 'portal'
}

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

try
{
    # Verifying the existance of the user
    Write-Verbose "Collecting the user information..."
    
    # Build the full URL to get the APIM user
    if($UserId.StartsWith('/subscriptions/'))
    {
        $fullGetUserUrl = "https://management.azure.com$($UserId)?api-version=$ApiVersion"   
    }
    else
    {
        $fullGetUserUrl = "https://management.azure.com/subscriptions/$SubscriptionId/resourceGroups/$ResourceGroupName/providers/Microsoft.ApiManagement/service/$ServiceName/users/$($UserId)?api-version=$ApiVersion"
    }
    
    $params = @{
        Method = 'Get'
        Headers = @{ 
	        'authorization'="Bearer $AccessToken"
        }
        URI = $fullGetUserUrl
    }

    $jsonUserResponse = Invoke-WebRequest @params -ErrorAction Stop
    Write-Verbose $jsonUserResponse

    $userResponse = ConvertFrom-Json $jsonUserResponse
}
catch
{
    $ErrorMessage = $_.Exception.Message
    Write-Warning "Error: $ErrorMessage"
    throw "Failed to retrieve a user with id '$UserId' from the APIM instance '$ServiceName'"
}

$scopeType = ""
$scopeObject = ""
$scopeName = ""
try
{   
    Write-Verbose "Validating Scope..."
    if($ProductName -ne '')
    {
        $scopeType = "Product"
        $scopeName = $ProductName
        Write-Verbose "Collecting the product information..."
    }
    
    elseif($ApiName -ne '')
    {
        $scopeType = "API"
        $scopeName = $ApiName
        Write-Verbose "Collecting the API information..."
    }
    
    # Validate existance of the scope-object
    $scopeFilter = [uri]::EscapeUriString('$filter=properties/displayName eq ' + "'$scopeName'")
    $listScopeObjectsUrl = "https://management.azure.com/subscriptions/$SubscriptionId/resourceGroups/$ResourceGroupName/providers/Microsoft.ApiManagement/service/$ServiceName/$($scopeType.ToLower())s?api-version=$ApiVersion&" + $scopeFilter
        
    $scopeObject = RetrieveScopeObject -endpointUrl $listScopeObjectsUrl -scopeType $scopeType.ToLower() -scopeName $scopeName
}
catch
{
    $ErrorMessage = $_.Exception.Message
    Write-Warning "Error: $ErrorMessage"
    throw "Failed to retrieve the id for $scopeType '$scopeName' from the APIM instance '$ServiceName' in order to define the scope of the subscription."
}

if($userResponse)
{
    try
    {
        Write-Host "Attempting to create subscription to $scopeType '$($scopeObject.properties.DisplayName)' for $($userResponse.properties.firstName) $($userResponse.properties.lastName)"
        if($DisplayName -eq '')
        {
            $DisplayName = "$($userResponse.properties.firstName) $($userResponse.properties.lastName) ($($scopeObject.properties.displayName))"
        }
        if($ApimSubscriptionId -eq '')
        {
            $ApimSubscriptionId = "subscription-$($scopeType.ToLower())-$($scopeObject.name)-$($userResponse.name)"
        }

        # Log some information about the subscription to be created
        Write-Host "Subscription Owner: $($userResponse.properties.firstName) $($userResponse.properties.lastName) ($($userResponse.properties.email))"
        Write-Host "Subscription Scope - $($scopeType): $($scopeObject.properties.displayName)"
        Write-Host "Subscription DisplayName: $DisplayName"
        Write-Host "Subscription Id: $ApimSubscriptionId"

        # Build the full URL to create a subscription in APIM
        $fullUrl = "https://management.azure.com/subscriptions/$SubscriptionId/resourceGroups/$ResourceGroupName/providers/Microsoft.ApiManagement/service/$ServiceName/subscriptions/$($ApimSubscriptionId)?notify=$SendNotification&api-version=$ApiVersion&appType=$AppType"
        
        $jsonRequest = ConvertTo-Json -Depth 2 @{
                'properties' = @{
                    'ownerId' = $userResponse.id
                    'scope' = $scopeObject.id
                    'displayName' = $DisplayName
                    'state' = 'active'
                    'allowTracing' = $($AllowTracing.ToBool())
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

        Write-Host "Subscription to $scopeType '$($scopeObject.properties.DisplayName)' for $($userResponse.properties.firstName) $($userResponse.properties.lastName) has been created"    
    }
    catch 
    {
        $ErrorMessage = $_.Exception.Message
        Write-Warning "Error: $ErrorMessage"
        throw "Failed to create a subscription to $scopeType '$($scopeObject.properties.DisplayName)' for $($userResponse.properties.firstName) $($userResponse.properties.lastName) on the developer portal of the APIM instance $ServiceName"
    }
}