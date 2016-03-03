Prerequisites:
 - BizTalkFactory.Powershell.Extensions
   https://psbiztalk.codeplex.com/

Beware!
   Run the 32-bit version of powershell, otherwise you will get an exception indicating 
   the 'BizTalkFactory.Powershell.Extensions' snap-in has not been installed on this computer.

This script allows for you to automate the disabling of all the receive locations for a specific application.

The script can be configured using the variables on the first 3 lines:
 - $SqlServer:
   The name of the SQL-server on which the BizTalk-databases have been deployed.
 - $DBName:
   The name of the BizTalkMgmtDb-database.
   i.e.  BizTalkMgmtDb
 - $Application:
   The name of the application for which the receive locations should be disabled
   i.e.  BizTalk Application 1

