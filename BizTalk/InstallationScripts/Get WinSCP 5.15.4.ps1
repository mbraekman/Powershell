#Parameters
$downloadNuGetTo = “C:\_CoditTools\Install”
$bizTalkInstallFolder = “C:\Program Files (x86)\Microsoft BizTalk Server"

#Download NuGet
Write-Host “Downloading Nuget”
$sourceNugetExe = “https://dist.nuget.org/win-x86-commandline/latest/nuget.exe”
$targetNugetExe = “$downloadNuGetTo\nuget.exe”
Invoke-WebRequest $sourceNugetExe -OutFile $targetNugetExe

#Download the right version of WinSCP
Write-Host “Downloading WinSCP from NuGet”
Invoke-Expression “$targetNugetExe Install WinSCP -Version 5.15.4 -OutputDirectory $downloadNuGetTo”

#Copy WinSCP items to BizTalk Folder
Write-Host “Copying WinSCP Nuget to BizTalk Folder”
Copy-Item “$downloadNuGetTo\WinSCP.5.15.4\tools\WinSCP.exe” $bizTalkInstallFolder
Copy-Item “$downloadNuGetTo\WinSCP.5.15.4\lib\net\WinSCPnet.dll” $bizTalkInstallFolder