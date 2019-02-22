param(
    [string]$sourceDirectory  = "",
    [string]$destinationDirectory = ""
)

$sourceDirFileCount = $(Get-ChildItem $sourceDirectory | Measure-Object ).Count
Write-Host "Source: " 
Write-Host "$sourceDirectory [$sourceDirFileCount files]"
Write-Host "Destination: "
Write-Host $destinationDirectory

$counter = 0
Write-Output "Copying files:"
foreach($file in Get-ChildItem $sourceDirectory) 
{
    $counter++
    Write-Host "[$counter/$sourceDirFileCount] $($file.FullName)"
    $filePath = $file.FullName
    $fileName = $file.Name
    Copy-Item -Force $filePath -Destination $destinationDirectory/$fileName
    $(Get-Item $file.Fullname).lastwritetime=$(Get-Date)

}