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
    $outputFilePath = "$destinationDirectory/$fileName"
    Copy-Item -Force $filePath -Destination $outputFilePath
    $(Get-Item $outputFilePath).lastwritetime=$(Get-Date)

}