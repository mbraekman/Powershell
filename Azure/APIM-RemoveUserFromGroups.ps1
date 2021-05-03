param(
    [string][Parameter(Mandatory = $true)] $ResourceGroupName = $(throw "Resource group name is required"),
    [string][parameter(Mandatory = $true)] $ServiceName = $(throw "API managgement service name is required"),
    [string][parameter(Mandatory = $true)] $UserId = $(throw "The UserId is required"),
    [string][parameter(Mandatory = $false)] $GroupId, # In case you only want to remove a user from a specific group
    [string][parameter(Mandatory = $false)] $ApiVersion = "2019-12-01",
    [string][parameter(Mandatory = $false)] $SubscriptionId,
    [string][parameter(Mandatory = $false)] $AccessToken
)

function RemoveUserFromGroup{
    param(
        [string]$UserId,
        [string]$GroupId
    )

    $fullDeleteUrl = "https://management.azure.com/subscriptions/$SubscriptionId/resourceGroups/$ResourceGroupName/providers/Microsoft.ApiManagement/service/$ServiceName/groups/$GroupId/users/$($UserId)?api-version=$ApiVersion"

    try
    {
        Write-Host "Removing the user (id: $($UserId)) from group (id: $($GroupId))"

        $params = @{
            Method = 'Delete'
            Headers = @{ 
	            'authorization'="Bearer $AccessToken"
            }
            URI = $fullDeleteUrl
        }

        $web = Invoke-WebRequest @params -ErrorAction Stop
   
        Write-Verbose $web
    
        Write-Host "The user (id: $UserId) has been removed from the specified group (id: $GroupId)."
    }
    catch {
        Write-Warning "Failed to remove the user (id: $UserId) from the group (id: $GroupId) for the developer portal of APIM instance $ServiceName"
        $ErrorMessage = $_.Exception.Message
        Write-Warning "Error: $ErrorMessage"
        Write-Warning $_ | ConvertTo-Json
    }
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

if($GroupId -ne '')
{
    RemoveUserFromGroup -UserId $UserId -GroupId $GroupId
}
else
{
    # Build the full URL to link a user to a group
    $fullListUrl = "https://management.azure.com/subscriptions/$SubscriptionId/resourceGroups/$ResourceGroupName/providers/Microsoft.ApiManagement/service/$ServiceName/users/$UserId/groups?api-version=$ApiVersion"
  
    try
    {
        Write-Host "Retreiving all groups linked to the user (id: $($UserId))"

        $params = @{
            Method = 'Get'
            Headers = @{ 
	            'authorization'="Bearer $AccessToken"
            }
            URI = $fullListUrl
        }

        $linkedGroupsResponse = Invoke-WebRequest @params -ErrorAction Stop
   
        Write-Verbose $linkedGroupsResponse

        $linkedGroups = ConvertFrom-Json $linkedGroupsResponse
        if($linkedGroups.Count -gt 0)
        {
            $linkedGroups.value | ForEach-Object {
                $linkedGroup = $_;
                
                if($linkedGroup.properties.type -ne 'system')
                {
                    Write-Host "About to remove user (id: $UserId) from group '$($linkedGroup.properties.displayName)'"

                    RemoveUserFromGroup -UserId $UserId -GroupId $linkedGroup.name
                }
                else
                {
                    Write-Warning "User (id: $UserId) cannot be removed from a system-group (group: $($linkedGroup.properties.displayName))."
                }
            }
        }
        else
        {
            Write-Host "The user (id: $UserId) does not have any linked groups."
        }

    }
    catch {
        Write-Warning "Failed to remove the user (id: $UserId) from all linked groups for the developer portal of APIM instance $ServiceName"
        $ErrorMessage = $_.Exception.Message
        Write-Warning "Error: $ErrorMessage"
        Write-Warning $_ | ConvertTo-Json
    }
}