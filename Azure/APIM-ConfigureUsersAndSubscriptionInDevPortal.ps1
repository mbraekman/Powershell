param(
    [string][Parameter(mandatory = $true)] $UsersConfigurationPath = $(throw "Make sure to provide the file path to the configuration file about the users and their subscriptions."),
    [string][Parameter(Mandatory = $true)] $ResourceGroupName = $(throw "Resource group name is required"),
    [string][parameter(Mandatory = $true)] $ServiceName = $(throw "API managgement service name is required"),
    [string][parameter(Mandatory = $false)] $ApiVersion = "2019-12-01",
    [string][parameter(Mandatory = $false)] $SubscriptionId,
    [string][parameter(Mandatory = $false)] $AccessToken
)

try
{
    $usersConfiguration = Get-Content $UsersConfigurationPath | Out-String | ConvertFrom-Json

    # Verify if any user has been included in the configuration file
    if($usersConfiguration.Length -gt 0){
    
        if($SubscriptionId -eq "" -or $AccessToken -eq ""){
            # Request accessToken in case the script contains records
            $token = Get-AzCachedAccessToken

            $AccessToken = $token.AccessToken
            $SubscriptionId = $token.SubscriptionId
        }

        $usersConfiguration | ForEach-Object {
            $user = $_;

            Write-Host("====================================")
            Write-Host("Processing configuration for $($user.firstName) $($user.lastName) ($($user.mailAddress))")

            $userParams = @{
                ResourceGroupName = $ResourceGroupName
                ServiceName = $ServiceName
                FirstName = $user.firstName 
                LastName = $user.lastName 
                MailAddress = $user.mailAddress
                Note = $user.note 
                ConfirmationType = $user.confirmationType 
                SendNotification = [boolean]@(if($user.receiveNotifications){ $true }else{ $false })
                LegacyDeveloperPortal = [boolean]@(if($user.portalVersion -eq 'legacy'){ $true }else{ $false })
                ApiVersion = $ApiVersion 
                SubscriptionId = $SubscriptionId 
                AccessToken = $AccessToken
            }

            .\APIM-InviteUserToDevPortal.ps1 @userParams
            
            $user.subscriptions | ForEach-Object {
                try
                {
                    $subscription = $_;
                
                    Write-Host("====================================")
                    Write-Host("Processing configuration for a subscription $($subscription.displayName)")

                    $params = @{
                        ResourceGroupName = $ResourceGroupName
                        ServiceName = $ServiceName 
                        UserId = $($user.mailAddress -replace '\W', '-') 
                        AllowTracing = [boolean]@(if($subscription.allowTracing){ $true }else{ $false })
                        SendNotification = [boolean]@(if($user.receiveNotifications){ $true }else{ $false })
                        LegacyDeveloperPortal = [boolean]@(if($user.portalVersion -eq 'legacy'){ $true }else{ $false })
                        ApiVersion = $ApiVersion 
                        SubscriptionId = $SubscriptionId 
                        AccessToken = $AccessToken
                    }
                    if($subscription.displayName -ne ''){
                        $params.DisplayName = $subscription.displayName 
                    }
                    if($subscription.name -ne ''){
                        $params.ApimSubscriptionId = $subscription.name 
                    }
                    if($subscription.scope.type -eq 'product'){
                        $params.ProductName = $subscription.scope.name
                    }
                    if($subscription.scope.type -eq 'api'){
                        $params.ApiName = $subscription.scope.name
                    }
                
                    .\APIM-CreateDevPortalSubscriptionForUser.ps1 @params
                }
                catch
                {
                    $ErrorMessage = $_.Exception.Message
                    Write-Warning "Error: $ErrorMessage"
                    Write-Error "Failed to process the configuration for the subscription $($subscription.displayName) for $($user.firstName) $($user.lastName)"
                }
            }
            
            Write-Host("====================================")
        } 
    }
    else
    {
        Write-Warning "The configuration file didn't contain any records."
    }
}
catch
{
    $ErrorMessage = $_.Exception.Message
    Write-Warning "Error: $ErrorMessage"
    throw "Failed to create process the configuration file to sync users/subscription in API Management Instance $ServiceName"
}