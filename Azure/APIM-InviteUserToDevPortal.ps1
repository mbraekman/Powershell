param(
    [string][Parameter(Mandatory = $true)] $ResourceGroupName = $(throw "Resource group name is required"),
    [string][parameter(Mandatory = $true)] $ServiceName = $(throw "API managgement service name is required"),
    [string][parameter(Mandatory = $true)] $FirstName = $(throw "The first name of the user is required"),
    [string][parameter(Mandatory = $true)] $LastName = $(throw "API last name of the user is required"),
    [string][parameter(Mandatory = $true)] $MailAddress = $(throw "The mail-address of the user is required"),
    [string][parameter(Mandatory = $false)] $UserId = $($MailAddress -replace '\W', '-'),
    [string][parameter(Mandatory = $false)] $Password,
    [string][parameter(Mandatory = $false)] $Note,
    [switch][parameter(Mandatory = $false)] $SendNotification = $false,
    [string][parameter(Mandatory = $false)][ValidateSet('invite', 'signup')] $ConfirmationType = "invite", #signup | invite
    [switch][parameter(Mandatory = $false)] $LegacyDeveloperPortal = $false,
    [string][parameter(Mandatory = $false)] $ApiVersion = "2019-12-01",
    [string][parameter(Mandatory = $false)] $SubscriptionId,
    [string][parameter(Mandatory = $false)] $AccessToken
)

# Possible values for the Confirmation type are: invite | signup
# For more information: https://docs.microsoft.com/en-us/rest/api/apimanagement/2019-12-01/user/createorupdate??WT.mc_id=AZ-MVP-5003203#confirmation"

# $confirmationType = 'invite' #signup | invite
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

# Build the full URL to create a user in APIM
$apimMgmtEndpoint = "https://management.azure.com/subscriptions/{subscriptionId}/resourceGroups/$ResourceGroupName/providers/Microsoft.ApiManagement/service/$ServiceName/users/$($UserId)?notify=$SendNotification&api-version=$ApiVersion"
$fullUrl = $apimMgmtEndpoint.Replace('{subscriptionId}', $SubscriptionId)
    
try
{
    if($ConfirmationType -eq 'invite')
    {
        Write-Host "Attempting to invite $FirstName $LastName ($mailAddress)"
    }
    else
    {
        Write-Host "Attempting to create account for $FirstName $LastName ($mailAddress)"
    }
    
    $jsonRequest = ConvertTo-Json -Depth 3 @{
            'properties' = @{
                'firstName' = $FirstName
                'lastName' = $LastName
                'email' = $MailAddress
                'confirmation' = $ConfirmationType
                'appType' = $appType
                'password' = $Password
                'note' = $Note
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

    if($ConfirmationType -eq 'invite')
    {
        Write-Host "Invitation has been sent to $FirstName $LastName ($mailAddress)"
    }
    else
    {
        Write-Host "Account has been created for $FirstName $LastName ($mailAddress)"
        if($Password -eq ''){
            Write-Host "Since no password was provided, one has been generated. Please advice the user to change this password the first time logging in."
        }
    }

    return $UserId
}
catch {
    Write-Warning "Failed to create an account for the $FirstName $LastName ($MailAddress) for the developer portal of APIM instance $ServiceName"
    $ErrorMessage = $_.Exception.Message
    Write-Warning "Error: $ErrorMessage"
}