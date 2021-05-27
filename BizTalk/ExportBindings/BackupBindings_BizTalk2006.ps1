#initialize environment
$SqlServerInstance = "SqlInstance16"
$SqlCatalog = "BizTalkMgmtDb"
$Server = "localhost"
 
#Set the variables that handle the file output
$Bindingextensie = ".xml"
$Backupfolder = "Backup_BizTalk_Bindings"
$DateTime = Get-Date -format M.d.yyyy
$scriptPath = split-path -parent $MyInvocation.MyCommand.Definition
 
#Eventviewer variables
$logname = "application"
$Source = "BackupBizTalkBindings"
$eventidError = "2000"
$eventidInformational = "1000"
$eventidInformationalBackuplocation = "1001"
$errormessage = "The backup of the BizTalk binding files failed."
$informationalmessage = "The backup of the BizTalk binding files succeeded. The files are stored in $scriptPath\$Backupfolder"
$informationalmessageBackuplocation = "The folder $scriptPath\$Backupfolder does not exist. The backup of the binding files failed."
$Regloc = "SYSTEM\CurrentControlSet\Services\EventLog"    
$Hive = [Microsoft.Win32.RegistryHive]“LocalMachine”;
$regKey = [Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey($Hive,$server);
$ref = $regKey.OpenSubKey(“$Regloc\$logname\$Source\”); 
 
#Check if the directory to which the backups are stored exist. If not, create the directory.
if (!(Test-Path $scriptPath\$Backupfolder))
    {
       new-item $scriptPath\$Backupfolder -type directory | out-null
    }
 
#Connect the BizTalk Management database
[void] [System.reflection.Assembly]::LoadWithPartialName("Microsoft.BizTalk.ExplorerOM")
$Catalog = New-Object Microsoft.BizTalk.ExplorerOM.BtsCatalogExplorer
$Catalog.ConnectionString = "SERVER=$SqlServerInstance;DATABASE=$SqlCatalog;Integrated Security=SSPI"
 
 
#Creates a backup of all binding files
foreach ($App in $Catalog.Applications)
    {
    $name = $App.Name
    $exportbinding = "BTSTask.exe exportbindings /ApplicationName:$name /destination:$scriptPath\$Backupfolder\$name\$name_$DateTime$Bindingextensie"
    invoke-expression $exportbinding | out-null
    }

