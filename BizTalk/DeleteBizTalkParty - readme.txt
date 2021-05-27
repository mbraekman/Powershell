Use this PS-script to remove all/a single Party from the BizTalk Party Settings.

To remove a single Party, call the script using the following method:
 > .\DeleteBizTalkParty.ps1 'partyName'

To remove all parties, call the script using the following method:
 > .\DeleteBizTalkParty.ps1


This can be executed as part of a BTDF (un)deployment, in combination with the *.exe within the accompanied zip-file.:
<Target Name="CustomUndeployTarget">     
	<Exec Command="DeleteParty.exe $(DeleteParty_BizTalkDbServer)" ContinueOnError="False" />   
</Target>


More information, see here: 
https://docs.microsoft.com/en-us/biztalk/core/deleteparty-biztalk-server-sample