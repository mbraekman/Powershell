param(
    [string][Parameter(Mandatory = $true)] $ResourceGroupName = $(throw "Resource group name is required"),
    [string][parameter(Mandatory = $true)] $ServiceName = $(throw "API managgement service name is required"),
    [string][parameter(Mandatory = $true)] $GroupId = $(throw "The GroupId is required"),
    [string][parameter(Mandatory = $true)] $UserId = $(throw "The UserId is required"),
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

# Build the full URL to link a user to a group
$fullUrl = "https://management.azure.com/subscriptions/$SubscriptionId/resourceGroups/$ResourceGroupName/providers/Microsoft.ApiManagement/service/$ServiceName/groups/$($GroupId)/users/$($UserId)?api-version=$ApiVersion"
  
try
{
    Write-Host "Attempting to link a user (id: $($UserId)) to a group (id: $($GroupId))"

    $params = @{
        Method = 'Put'
        Headers = @{ 
	        'authorization'="Bearer $AccessToken"
        }
        URI = $fullUrl
    }

    $web = Invoke-WebRequest @params -ErrorAction Stop
   
    Write-Verbose $web

    Write-Host "The user (id: $UserId) has been linked the specified group (id: $GroupId)."
}
catch {
    Write-Warning "Failed to link the user (id: $UserId) to the group (id: $GroupId) for the developer portal of APIM instance $ServiceName"
    $ErrorMessage = $_.Exception.Message
    Write-Warning "Error: $ErrorMessage"
    Write-Warning $_ | ConvertTo-Json
}