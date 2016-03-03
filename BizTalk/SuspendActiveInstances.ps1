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
function bts-suspend-instance([string]$msgId)
{
    if(!($msgId -eq “”))
    {
       " Suspend {0}" -f $msgId
       $msg = get-wmiobject MSBTS_ServiceInstance -namespace 'root\MicrosoftBizTalkServer' -filter “InstanceID = '$msgId'”
       $msg.Suspend() | Out-Null
    "   - Done"
    }
    else
    {
       "MessageId missing"
    }
}

#
# list resumable suspended instances
#
function bts-get-active-instances()
{
    get-wmiobject MSBTS_ServiceInstance -namespace 'root\MicrosoftBizTalkServer' -filter "ServiceStatus=2 and ServiceClass != '16'"
}

#
# list resumable suspended instances
#
function bts-get-dehydrated-instances()
{
    get-wmiobject MSBTS_ServiceInstance -namespace 'root\MicrosoftBizTalkServer' -filter "ServiceStatus=8 and ServiceClass != '16'"
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
    $logFileName = "SuspendActiveInstances_" + (Get-Date).ToString("yyyyMMdd-HHmmss") + ".log"
    $logFilePath = $logFolder + "\" + $logFileName
    
    Write-Output "-------------------------------------------"  | Out-File $logFilePath -Append
    Write-Output "Suspending active and dehydrated instances."  | Out-File $logFilePath -Append
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
    
	#the max-time the instances are allowed to be running
	$runningTime = $config.BizTalkPowerShellConfig.Running.TimeRunning
	
	if($runningTime -ne $null)
	{
        $output = "Maximum time for running instances: " + $runningTime
        Write-Output $output  | Out-File $logFilePath -Append
        Write-Host $output

        Write-Output "-------------------------------------------"  | Out-File $logFilePath -Append

            $counter = 0
            $dtTimeLimit = (GET-DATE) - [timespan]$runningTime

            $output = "Retrieve active instances"
            Write-Output $output  | Out-File $logFilePath -Append
            Write-Host $output
            bts-get-active-instances | 
            %{ 
                $timezone = [string]($_.ActivationTime).Substring(21,3);
                $msgTime = [datetime]::ParseExact([string]($_.ActivationTime).Substring(0,14), "yyyyMMddHHmmss", $null);
                
                if([datetime]$msgTime -lt $dtTimeLimit )
                {
                    $counter++; 
                    Write-output $_.ServiceName
                    Write-Host "Suspending:" $_.InstanceId
                    bts-suspend-instance($_.InstanceId)
                }
             } | Out-File $logFilePath -Append
             
             
            Write-Output "-------------------------------------------"  | Out-File $logFilePath -Append
            $output = "Retrieve dehydrated instances"
            Write-Output $output  | Out-File $logFilePath -Append
            Write-Host $output
            bts-get-dehydrated-instances | 
            %{ 
                $timezone = [string]($_.ActivationTime).Substring(21,3);
                $msgTime = [datetime]::ParseExact([string]($_.ActivationTime).Substring(0,14), "yyyyMMddHHmmss", $null);
                
                if([datetime]$msgTime -lt $dtTimeLimit)
                {
                    $counter++; 
                    Write-output $_.ServiceName
                    Write-Host "Suspending:" $_.InstanceId
                    bts-suspend-instance($_.InstanceId)
                }
             } | Out-File $logFilePath -Append
                   
             
            Write-Output "-------------------------------------------"  | Out-File $logFilePath -Append
            $output = "Amount of instances suspended: " + $counter
            Write-Output $output  | Out-File $logFilePath -Append
            Write-Host $output
        
	}
}

Write-Output "-------------------------------------------"  | Out-File $logFilePath -Append
Write-Output "Finished"  | Out-File $logFilePath -Append
Write-Host "Finished"
