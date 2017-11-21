#Parameters
$downloadNuGetTo = “C:\Codit\Install”
$bizTalkInstallFolder = “C:\Program Files (x86)\Microsoft BizTalk Server 2016”

#Download NuGet
Write-Host “Downloading Nuget”
$sourceNugetExe = “https://dist.nuget.org/win-x86-commandline/latest/nuget.exe”
$targetNugetExe = “$downloadNuGetTo\nuget.exe”
Invoke-WebRequest $sourceNugetExe -OutFile $targetNugetExe

#Download the right version of WinSCP
Write-Host “Downloading WinSCP from NuGet”
Invoke-Expression “$targetNugetExe Install WinSCP -Version 5.7.7 -OutputDirectory $downloadNuGetTo”

#Copy WinSCP items to BizTalk Folder
Write-Host “Copying WinSCP Nuget to BizTalk Folder”
Copy-Item “$downloadNuGetTo\WinSCP.5.7.7\content\WinSCP.exe” $bizTalkInstallFolder
Copy-Item “$downloadNuGetTo\WinSCP.5.7.7\lib\WinSCPnet.dll” $bizTalkInstallFolder