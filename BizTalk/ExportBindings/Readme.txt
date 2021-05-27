
Adjust the environment variables in the powershell script (.ps1 file), in a normal case, only $SqlServerInstance needs to be adjusted.
Use 32-bit powershell if BizTalk 2006 R2! (Or if the system throws an error complaining that 64bit is not supported).
(C:\Windows\SysWOW64\WindowsPowerShell\v1.0)

Try to run following cmd: adjust path so it points to the script on the machine, or use a .bat file

---
C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe -File C:\Tools\BizTalk.Backupbindings\BackupBindings.ps1
pause
---

If you run into this error:
---
File C:\Users\Administrator\Desktop\BackupBindings.ps1 cannot be loaded b
ecause the execution of scripts is disabled on this system. Please see "get-hel
p about_signing" for more details.
    + CategoryInfo          : NotSpecified: (:) [], ParentContainsErrorRecordE
   xception
    + FullyQualifiedErrorId : RuntimeException
---
=> open a new powershell window and excecute following command: Set-ExecutionPolicy RemoteSigned

---
It is possible you receive errors regarding the eventlog, if so, just throw that part away, it is only usefull for troubleshooting
---

---
Now check if you have the export of bindings, then you can create a sheduled task that executes the command weekly 
=> Create a sheduled task that starts powershell and executes the script, or call a .bat file
---

Do not forget that the files won't be removed automatic!