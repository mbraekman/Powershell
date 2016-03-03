# Funtion used to export MSI's
function CleanResourceFile([string]$applicationName, [string]$baseAddress){
    Write-Output "Exporting resource-specifications for $applicationName"

    $resourceFileName = "$baseAddress\$applicationName-ResourceSpecTemp.xml"

    BTSTask ListApp /ApplicationName:$applicationName /ResourceSpec:$resourceFileName

    If (!($?))
    {
        # throw "Could not export resource specification. Verify application name."
        Write-Output "Could not export resource specification. Verify application name."
    }
    else
    {
        Write-Output "Reading resource-specifications for $applicationName"
        $xmlResource = [xml] (Get-Content $resourceFileName)

        # Remove the web-directories which would be included in the MS
        Write-Output "Removing web directories..."
        $delnodes = $xmlResource.SelectNodes("/*[local-name()='ResourceSpec' and namespace-uri()='http://schemas.microsoft.com/BizTalk/ApplicationDeployment/ResourceSpec/2004/12']/*[local-name()='Resources' and namespace-uri()='http://schemas.microsoft.com/BizTalk/ApplicationDeployment/ResourceSpec/2004/12']/*[local-name()='Resource' and namespace-uri()='http://schemas.microsoft.com/BizTalk/ApplicationDeployment/ResourceSpec/2004/12'][@Type='System.BizTalk:WebDirectory']")

        ForEach($delnode in $delnodes)
        {
            [void]$xmlResource.ResourceSpec.Resources.RemoveChild($delnode)
        }

        # Remove the bindings which would be included in the MSI
        Write-Output "Removing Default binding info..."
        $delnodes = $xmlResource.SelectNodes("/*[local-name()='ResourceSpec' and namespace-uri()='http://schemas.microsoft.com/BizTalk/ApplicationDeployment/ResourceSpec/2004/12']/*[local-name()='Resources' and namespace-uri()='http://schemas.microsoft.com/BizTalk/ApplicationDeployment/ResourceSpec/2004/12']/*[local-name()='Resource' and namespace-uri()='http://schemas.microsoft.com/BizTalk/ApplicationDeployment/ResourceSpec/2004/12'][@Type='System.BizTalk:BizTalkBinding']")

        ForEach($delnode in $delnodes)
        {
            [void]$xmlResource.ResourceSpec.Resources.RemoveChild($delnode)
        }
    
        Write-Output "Saving modified resource-specifications for $applicationName"
        $xmlResource.Save("$resourceFileName")

        Write-Output "Exporting application $applicationName..."

        BTSTask ExportApp /ApplicationName:$applicationName /Package:$baseAddress\$applicationName.msi /ResourceSpec:$resourceFileName

        If (!($?))
        {
            throw "Could not export application. Verify application name and parameters."
        }
        
        Write-Output "Cleaning up..."
        # Remove-Item $pwd\ResourceSpecTemp.xml

        Write-Output "Finsished exporting the MSI for $applicationName"
    }
}

$applicationNames = @("BizTalk Application 1",
					  "BizTalk EDI Application")

$currentDate = (Get-Date).ToString("yyyyMMdd")
$baseAddress = "D:\Backup\" + $currentDate + "\"
$SqlServer = "."
$DBName = "BizTalkMgmtDb"

# Check if the backup-folder exist if not create it 
If (!(Test-Path $baseAddress)) {
   md $baseAddress
}

foreach($appName in $applicationNames)
{
    $appBindingFile = $baseAddress + $appName + "-binding.xml"
    
    # Export the bindings
    BTSTask ExportBindings /Destination:$appBindingFile /ApplicationName:$appName /Server:$SqlServer /Database:$DBName
    
    If ($?){
        # Export an MSI for each of the applications
        CleanResourceFile $appName $baseAddress
    }
}