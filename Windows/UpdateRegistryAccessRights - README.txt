Beware!
   Run the powershell-prompt as administrator.

This script will assign full control access to the registry-key:
	HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\EventLog
This could be usefull when running applications which will write information to the eventlog.

The script can be configured using the variables on the first 3 lines:
 - $Username
   The user for which full access-rights should be granted.

