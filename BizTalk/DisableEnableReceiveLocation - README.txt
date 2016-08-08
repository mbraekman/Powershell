Prerequisites:
 - BizTalkFactory.Powershell.Extensions
   https://psbiztalk.codeplex.com/

Beware!
   Run the 32-bit version of powershell, otherwise you will get an exception indicating 
   the 'BizTalkFactory.Powershell.Extensions' snap-in has not been installed on this computer.

This script allows for you to automate the disabling/enabling of a specific receive locations, based on the name of this location.

The script can be configured using the variables on the first 3 lines:
 - $ReceiveLocationName:
   The name of the receive location that needs to be disabled/enabled.

