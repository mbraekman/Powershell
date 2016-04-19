function Get-ScriptDirectory
{
    $Invocation = (Get-Variable MyInvocation -Scope 1).Value;
    if($Invocation.PSScriptRoot)
    {
        $Invocation.PSScriptRoot;
    }
    Elseif($Invocation.MyCommand.Path)
    {
        Split-Path $Invocation.MyCommand.Path
    }
    else
    {
        $Invocation.InvocationName.Substring(0,$Invocation.InvocationName.LastIndexOf("\"));
    }
}

#
# main script
#

$p = Get-ScriptDirectory
$p2 = $p + "\ChangeServiceStartupType.config"

$logFilePath = "";

Write-Host "Getting config file from" $p2
[xml]$config = Get-Content $p2

if ($config -ne $null)
{
    $logFolder = $config.PowerShellConfig.LogFolder
    $logFileName = "ResumeAndTerminateInstances_" + (Get-Date).ToString("yyyyMMdd-HHmmss") + ".log"
    $logFilePath = $logFolder + "\" + $logFileName
	
    Write-Output "-------------------------------------------"  | Out-File $logFilePath -Append
    Write-Output "  Change startupType of Windows services.  "  | Out-File $logFilePath -Append
    Write-Output "-------------------------------------------"  | Out-File $logFilePath -Append
	
	$services = $config.PowerShellConfig.Services.Service
	if ($services -ne $null)
    {
        $totalResumeCounter = 0
        foreach ($service in $services)
        {
			$serviceName = $service.name
			$startupMode = $service.startupType
			$result = Get-WmiObject -Query "Select StartMode From Win32_Service Where Name='$serviceName'"
			$currentStartupMode = $result.StartMode
			
			Write-Output " $serviceName "  | Out-File $logFilePath -Append
			Write-Output "  Current Mode 	- $currentStartupMode"  | Out-File $logFilePath -Append
			Write-Output "  New Mode 		- $startupMode"  | Out-File $logFilePath -Append
			
			Set-Service "$serviceName" -startuptype "$startupMode"
		}
	}
	
    Write-Host "Logfile: " + $logFilePath
}