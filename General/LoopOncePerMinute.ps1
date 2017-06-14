## Create an Timer instance 
$timer = New-Object Timers.Timer
## Now setup the Timer instance to fire events
$timer.Interval = 60000     # fire every 60s
$timer.AutoReset = $true    # enable the event again after its been fired
$timer.Enabled = $true

## register your event
## $args[0] Timer object
## $args[1] Elapsed event properties
Register-ObjectEvent -InputObject $timer -EventName Elapsed -SourceIdentifier Notepad  -Action {notepad.exe}