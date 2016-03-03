This script allows for you to create a back-up of both the bindings and the MSI's of a specified set of applications.

On opening the ps-file, you will find a variable '$applicationNames' on line 56, which is in fact the list of application-names which need to be backed up.
The next variables need to be used to make sure the script can create/save the backup-files.
 - $baseAddress
	The location on disk where the backups should be stored.
 - $SqlServer
	The name of the server on which the BizTalk-databases have been created.
	i.e.: SQLDEV01\SQL_2012
 - $DBName
	The name of the BizTalkMgmtDb-database. In case this might have gotten a different name, during the installation.
	i.e.: BizTalkMgmtDb
	      BizTalkMgmtDb_TEST