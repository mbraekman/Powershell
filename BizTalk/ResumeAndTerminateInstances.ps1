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
# resume instance
#
function bts-resume-instance([string]$msgId)
{
    if(!($msgId -eq “”))
    {
       "  Resume {0}" -f $msgId
       $msg = get-wmiobject MSBTS_ServiceInstance -namespace 'root\MicrosoftBizTalkServer' -filter “InstanceID = '$msgId'”
       $msg.Resume() | Out-Null
    "   - Done"
    }
    else
    {
       "  MessageId missing"
    }
}
#
# terminate non resumable instance
#
function bts-terminate-instance([string]$msgId)
{
    if(!($msgId -eq “”))
    {
       "  Terminate {0}" -f $msgId
       $msg = get-wmiobject MSBTS_ServiceInstance -namespace 'root\MicrosoftBizTalkServer' -filter “InstanceID = '$msgId'”
       $msg.Terminate() | Out-Null
       "   - Done"
   }
   else
    {
       "  MessageId missing"
   }
}
#
# list resumable suspended instances
#
function bts-get-resumable-suspended([string]$serviceName)
{
    get-wmiobject MSBTS_ServiceInstance -namespace 'root\MicrosoftBizTalkServer' -filter "ServiceStatus=4 and ServiceName LIKE '%$serviceName%'"
}

function bts-get-resumable-suspended([string]$serviceName, [string]$errorCode, [string]$errorDescription)
{
    if(($errorCode -ne "") -and ($errorDescription -ne ""))
    {
        get-wmiobject MSBTS_ServiceInstance -namespace 'root\MicrosoftBizTalkServer' -filter "ServiceStatus=4 and ServiceName LIKE '%$serviceName%' and ErrorId LIKE '%$errorCode%' and ErrorDescription LIKE '%$errorDescription%'"
    }
    elseIf(($errorCode -ne "") -and ($errorDescription -eq ""))
    {
        get-wmiobject MSBTS_ServiceInstance -namespace 'root\MicrosoftBizTalkServer' -filter "ServiceStatus=4 and ServiceName LIKE '%$serviceName%' and ErrorId LIKE '%$errorCode%'"
    }
    elseIf(($errorCode -eq "") -and ($errorDescription -ne ""))
    {
        get-wmiobject MSBTS_ServiceInstance -namespace 'root\MicrosoftBizTalkServer' -filter "ServiceStatus=4 and ServiceName LIKE '%$serviceName%' and ErrorDescription LIKE '%$errorDescription%'"
    }
    else
    {
        get-wmiobject MSBTS_ServiceInstance -namespace 'root\MicrosoftBizTalkServer' -filter "ServiceStatus=4 and ServiceName LIKE '%$serviceName%'"
    }
}
#
# list resumable suspended instances
#
function bts-get-nonresumable-suspended([string]$serviceName)
{
    get-wmiobject MSBTS_ServiceInstance -namespace 'root\MicrosoftBizTalkServer' -filter "ServiceStatus=32 and ServiceName LIKE '%$serviceName%'"
}

function bts-get-nonresumable-suspended([string]$serviceName, [string]$errorCode, [string]$errorDescription)
{
    if(($errorCode -ne "") -and ($errorDescription -ne ""))
    {
        get-wmiobject MSBTS_ServiceInstance -namespace 'root\MicrosoftBizTalkServer' -filter "ServiceStatus=32 and ServiceName LIKE '%$serviceName%' and ErrorId LIKE '%$errorCode%' and ErrorDescription LIKE '%$errorDescription%'"
    }
    elseIf(($errorCode -ne "") -and ($errorDescription -eq ""))
    {
        get-wmiobject MSBTS_ServiceInstance -namespace 'root\MicrosoftBizTalkServer' -filter "ServiceStatus=32 and ServiceName LIKE '%$serviceName%' and ErrorId LIKE '%$errorCode%'"
    }
    elseIf(($errorCode -eq "") -and ($errorDescription -ne ""))
    {
        get-wmiobject MSBTS_ServiceInstance -namespace 'root\MicrosoftBizTalkServer' -filter "ServiceStatus=32 and ServiceName LIKE '%$serviceName%' and ErrorDescription LIKE '%$errorDescription%'"
    }
    else
    {
        get-wmiobject MSBTS_ServiceInstance -namespace 'root\MicrosoftBizTalkServer' -filter "ServiceStatus=32 and ServiceName LIKE '%$serviceName%'"
    }
}


#
# main script
#

$p = Get-ScriptDirectory
$p2 = $p + "\BizTalkPowerShell.config"

$logFilePath = "";

Write-Host "Getting config file from" $p2
[xml]$config = Get-Content $p2

if ($config -ne $null)
{
    $logFolder = $config.BizTalkPowerShellConfig.LogFolder
    $logFileName = "ResumeAndTerminateInstances_" + (Get-Date).ToString("yyyyMMdd-HHmmss") + ".log"
    $logFilePath = $logFolder + "\" + $logFileName
    
    Write-Output "-------------------------------------------"  | Out-File $logFilePath -Append
    Write-Output " Resume and terminate suspended instances."  | Out-File $logFilePath -Append
    Write-Output "-------------------------------------------"  | Out-File $logFilePath -Append
    
    $output = "SQL Server: " + $config.BizTalkPowerShellConfig.SQLServer
    Write-Output $output  | Out-File $logFilePath -Append
    Write-Host $output
    
    $output = "BizTalkMgmtDb: " + $config.BizTalkPowerShellConfig.MgmtDbName
    Write-Output $output  | Out-File $logFilePath -Append
    Write-Host $output
    
    Write-Host "Logfile: " + $logFilePath
    
    $InitializeDefaultBTSDrive = $false
    Add-PSSnapin –Name BizTalkFactory.PowerShell.Extensions
    New-PSDrive -Name BizTalk -PSProvider BizTalk -Root BizTalk:\ -Instance $config.BizTalkPowerShellConfig.SQLServer -Database $config.BizTalkPowerShellConfig.MgmtDbName 
    
	#Terminate the non-resumable instances for which the service name was mentioned in the config.
	$terminates = $config.BizTalkPowerShellConfig.Terminate.ServiceName
	
    Write-Output "-------------------------------------------"  | Out-File $logFilePath -Append

	if($terminates -ne $null)
	{
        $totalTerminateCounter = 0
		foreach($terminate in $terminates)
		{
            $output = "Terminating instances for service name " + $terminate.Name
            Write-Output $output  | Out-File $logFilePath -Append
            Write-Host $output

            $serviceName = $terminate.Name
            $errors = $terminate.Error
            $counter = 0
            
            if($errors -ne $null)
            {
                foreach($errorNode in $errors)
                {
                    #$errorSpecificCounter = 0
                    #$output = " With errorcode '" + $errorNode.Code + "' - '" + $errorNode.Description + "':"
                    #Write-Output $output  | Out-File $logFilePath -Append
                    #Write-Host $output
                    bts-get-nonresumable-suspended $serviceName $errorNode.Code $errorNode.Description | %{ $counter++; bts-terminate-instance($_.InstanceID) } | Out-File $logFilePath -Append
                    
                    #$output = " Amount terminated with errorcode  '" + $errorNode.Code + "' - '" + $errorNode.Description + "': " + $errorSpecificCounter
                    #Write-Output $output  | Out-File $logFilePath -Append
                    #Write-Host $output
                }
            }
            else
            {
                bts-get-nonresumable-suspended($serviceName) | %{ $counter++; bts-terminate-instance($_.InstanceID) } | Out-File $logFilePath -Append
            }
            $totalTerminateCounter = $totalTerminateCounter + $counter

            $output = " Amount of instances terminated: " + $counter
            Write-Output $output  | Out-File $logFilePath -Append
            Write-Host $output
        }
        Write-Output " --------------------------- "  | Out-File $logFilePath -Append
        $output = "Total amount of instances terminated: " + $totalTerminateCounter
        Write-Output $output  | Out-File $logFilePath -Append
        Write-Host $output
	}

    Write-Output "-------------------------------------------"  | Out-File $logFilePath -Append
    #Resume instances for which the service name was mentioned in the config.
	$resumes = $config.BizTalkPowerShellConfig.Resume.ServiceName
	 
	if ($resumes -ne $null)
    {
        $totalResumeCounter = 0
        foreach ($resume in $resumes)
        {
            $output = "Resuming instances for service name " + $resume.Name
            Write-Output $output  | Out-File $logFilePath -Append
            Write-Host $output

            $serviceName = $resume.Name
            $errors = $resume.Error
            $counter = 0
            
            if($errors -ne $null)
            {
                foreach($errorNode in $errors)
                {
                    #$errorSpecificCounter = 0
                    #$output = " With errorcode '" + $errorNode.Code + "' - '" + $errorNode.Description + "':"
                    #Write-Output $output  | Out-File $logFilePath -Append
                    #Write-Host $output
                    bts-get-resumable-suspended $serviceName $errorNode.Code $errorNode.Description | %{ $counter++; bts-resume-instance($_.InstanceID) } | Out-File $logFilePath -Append
                    
                    #$output = " Amount resumed with errorcode  '" + $errorNode.Code + "' - '" + $errorNode.Description + "': " + $errorSpecificCounter
                    #Write-Output $output  | Out-File $logFilePath -Append
                    #Write-Host $output
                }
            }
            else
            {
                bts-get-resumable-suspended($serviceName) | %{ $counter++; bts-resume-instance($_.InstanceID) } | Out-File $logFilePath -Append
            }
            $totalResumeCounter = $totalResumeCounter + $counter

            $output = " Amount of instances resumed: " + $counter
            Write-Output $output  | Out-File $logFilePath -Append
            Write-Host $output
		}
        Write-Output " --------------------------- "  | Out-File $logFilePath -Append
        $output = "Total amount of instances resumed: " + $totalResumeCounter
        Write-Output $output  | Out-File $logFilePath -Append
        Write-Host $output
	}
}


Write-Output "-------------------------------------------"  | Out-File $logFilePath -Append
Write-Output "Finished"  | Out-File $logFilePath -Append
Write-Host "Finished"