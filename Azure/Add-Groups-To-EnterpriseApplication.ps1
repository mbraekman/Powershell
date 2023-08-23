# This script will ensure that all AD Groups related to specific PlantIds will be granted access to an enterprise application (service principal)

Param(
  [string] [Parameter(Mandatory=$true)] $applicationName,
  [string] [Parameter(Mandatory=$true)] $groupPrefix,
  [Switch] [Parameter(Mandatory=$false)] $signIn
)

if($signIn){
    # Connect to Azure AD
    Connect-AzureAD
}

# Get the application registration details
$app =  Get-AzureADApplication -SearchString $applicationName

# Get the enterprise application (service principal) for the app you want to assign the groups to
$servicePrincipal = Get-AzureADServicePrincipal -SearchString $applicationName

$counter = 0;

if($null -eq $servicePrincipal)
{
    Write-Error "No application could be found matching the given name."
}
else
{
    # Get all groups that apply to be granted access to the application
    $groups = Get-AzureADGroup -SearchString $groupPrefix

    foreach($group in $groups)
    {
       Write-Host 'Adding following group to the application:' $group.DisplayName
       
       # Create the user app role assignment
       try
       {
            New-AzureADGroupAppRoleAssignment -ObjectId $group.ObjectId -PrincipalId $group.ObjectId -ResourceId $servicePrincipal.ObjectId -Id ([Guid]::Empty) -ErrorAction Stop
            $counter++
       }
       catch [Microsoft.Open.AzureAD16.Client.ApiException]
       {
           $errorMessage = $_.Exception.Message
           if($errorMessage.Contains("EntitlementGrant entry already exists."))
           {
            Write-Host "Group was already granted access to this application."
           }
           else
           {
            Write-Error "Failed to add group"
            Write-Warning $errorMessage
           }
       }
    }
}

Write-Host $counter 'groups have been added'