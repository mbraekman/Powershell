param(
    [string][Parameter(mandatory = $true)] $UsersConfigurationPath = $(throw "Make sure to provide the file path to the configuration file about the users and their subscriptions."),
    [string][Parameter(Mandatory = $true)] $ResourceGroupName = $(throw "Resource group name is required"),
    [string][parameter(Mandatory = $true)] $ServiceName = $(throw "API management service name is required"),
    [string][parameter(Mandatory = $false)] $ApiVersion = "2019-12-01",
    [string][parameter(Mandatory = $false)] $SubscriptionId,
    [string][parameter(Mandatory = $false)] $AccessToken,
    [switch][parameter(Mandatory = $false)] $StrictlyFollowConfig = $false
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

        ### Users
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

            $userId = .\APIM-InviteUserToDevPortal.ps1 @userParams
            
            ### Groups
            ### In case the actual setup should strictly follow the provided config, remove the references first
            if($StrictlyFollowConfig)
            {
                .\APIM-RemoveUserFromGroups.ps1 -ResourceGroupName $ResourceGroupName -ServiceName $ServiceName -UserId $userId -ApiVersion $ApiVersion -SubscriptionId $SubscriptionId -AccessToken $AccessToken
            }


            ### Exclude system-groups since memberships cannot be changed
            $user.groups | Where-Object {$_.type -ne "system"} | ForEach-Object {
                try
                {
                    $group = $_;
                    
                    Write-Host("====================================")
                    Write-Host("Processing configuration for group $($group.displayName)")

                    $groupParams = @{
                        ResourceGroupName = $ResourceGroupName
                        ServiceName = $ServiceName 
                        DisplayName = $group.displayName
                        ApiVersion = $ApiVersion 
                        SubscriptionId = $SubscriptionId 
                        AccessToken = $AccessToken
                    }

                    if($group.id -ne ''){
                        $groupParams.GroupId = $group.id
                    }
                    if($group.type -ne ''){
                        $groupParams.GroupType = $group.type
                    }
                    if($group.description -ne ''){
                        $groupParams.Description = $group.description
                    }

                    $groupId = .\APIM-CreateDevPortalGroup.ps1 @groupParams

                    ## Add the user to this group
                    $groupUserParams = @{
                        ResourceGroupName = $ResourceGroupName
                        ServiceName = $ServiceName 
                        GroupId = $groupId
                        UserId = $userId
                        ApiVersion = $ApiVersion 
                        SubscriptionId = $SubscriptionId 
                        AccessToken = $AccessToken
                    }

                    .\APIM-LinkUserToGroupDevPortal.ps1 @groupUserParams
                }
                catch
                {
                    $ErrorMessage = $_.Exception.Message
                    Write-Warning "Error: $ErrorMessage"
                    Write-Error "Failed to process the configuration for group $($group.displayName) for $($user.firstName) $($user.lastName)"
                }
            }

            ### Subscriptions
            ### In case the actual setup should strictly follow the provided config, remove those subscriptions which are no longer referenced in the config.
            if($StrictlyFollowConfig)
            {
                ## TO DO
                # List all current subscriptions
                # compare to configuration
                # if not present in configuration -> remove
                # if present in configuration -> update -> done below
                # if present in configuration, but doesn't exist in the list -> create new subscription -> done below
            }


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