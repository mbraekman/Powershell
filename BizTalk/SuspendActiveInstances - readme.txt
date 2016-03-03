Prerequisites:
 - BizTalkFactory.Powershell.Extensions
   https://psbiztalk.codeplex.com/

Beware!
   Run the 32-bit version of powershell, otherwise you will get an exception indicating 
   the 'BizTalkFactory.Powershell.Extensions' snap-in has not been installed on this computer.

This script allows for you to automate the suspending of active instances.

The output of this script will be a log-file, indicating the amount of messages that have been suspended.
Everything related to the configuration of this script is located in the 'BizTalkPowerShell.config'-file.
This file is containing:
 - RunningTime: the time an instance is allowed to be active, before it being suspended.

