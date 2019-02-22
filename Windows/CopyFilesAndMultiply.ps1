param(
    [string]$sourceDirectory  = "",
    [string]$destinationDirectory = "",
    [int]$amountOfCopies = 1,
    [string]$extension = ".xml"
)

$sourceDirFileCount = $(Get-ChildItem $sourceDirectory | Measure-Object ).Count
Write-Host "Source: " 
Write-Host "$sourceDirectory [$sourceDirFileCount files]"
Write-Host "Destination: "
Write-Host $destinationDirectory

$counter = 0
$total = $sourceDirFileCount * $amountOfCopies
Write-Output "Copying files:"
foreach($file in Get-ChildItem $sourceDirectory) 
{
    for($i = 0; $i -lt $amountOfCopies;$i++)
    {
        $counter++
        $filePath = $file.FullName
        $fileName = $file.Name.Replace($file.Extension, '')
        $outputFilePath = "$destinationDirectory/$($fileName)_$($i+1)$($file.Extension)"
        Write-Host "[$counter/$total] $($outputFilePath)"

        Copy-Item -Force $filePath -Destination $outputFilePath
        $(Get-Item $outputFilePath).lastwritetime=$(Get-Date)
    }
}