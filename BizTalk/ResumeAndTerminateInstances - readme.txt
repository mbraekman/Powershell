Prerequisites:
 - BizTalkFactory.Powershell.Extensions
   https://psbiztalk.codeplex.com/

Beware!
   Run the 32-bit version of powershell, otherwise you will get an exception indicating 
   the 'BizTalkFactory.Powershell.Extensions' snap-in has not been installed on this computer.

This script allows for you to automate the resume/terminate-actions on (non-)resumable instances.

The output of this script will be a log-file, indicating the amount of messages that have been terminated/suspended.
Everything related to the configuration of this script is located in the 'BizTalkPowerShell.config'-file.
This file is containing:
 - a list of applications, for which the check for suspended instances.
 - a list of ports, for which to check, based on the error-code, if the messages should be resumed.
 - a list of ports, for which to check if the messages should be terminated.
