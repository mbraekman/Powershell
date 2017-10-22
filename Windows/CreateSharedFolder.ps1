# Create shared folders
$Shares=[WMICLASS]"WIN32_Share"
 
Function CreateSharedFolder ($Foldername, $Sharename) 
{ 
	# Create the folder if it does not yet exist 
	IF (!(TEST-PATH $Foldername)) 
	{ 
		NEW-ITEM $Foldername -type Directory 
	} 

	# Double-check if the share doesn't exist before creating it
	If (!(GET-WMIOBJECT Win32_Share -filter "Name='$Sharename'"))
	{ 
		$Shares.Create($Foldername,$Sharename,0) 
		Write-Host $Sharename "created"
	} 
}
 
 CreateSharedFolder -Foldername "D:\Share" -Sharename "SharedFolder"
 
 