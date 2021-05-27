#===================#
#=== Main Script ===#
#===================#

#=== Make sure the ExplorerOM assembly is loaded ===#

[void] [System.reflection.Assembly]::LoadWithPartialName("Microsoft.BizTalk.ExplorerOM")

#=== Connect to the BizTalk Management database ===#

$Catalog = New-Object Microsoft.BizTalk.ExplorerOM.BtsCatalogExplorer
$Catalog.ConnectionString = "SERVER=.;DATABASE=BizTalkMgmtDb;Integrated Security=SSPI"

#=======================================#
#=== If no party name is specified   ===#
#=== just list the parties.          ===#
#=======================================#

if ($args[0] -eq $null)
{
  Write-Host `r`nNo party name provided for delete operation.`r`n`r`nListing Parties on local Biztalk Server:

  $Catalog.Parties | Format-List Name
}

#==========================================#
#=== Delete the specified party by name ===#
#==========================================#

else
{
  $party = $Catalog.Parties[$args[0]]
  Write-Host `r`nRemoving Party named `"($args[0])`"`r`n
  $catalog.RemoveParty($party)
  $catalog.SaveChanges()
}