param
(
    [Parameter(Mandatory)]
    [String]$ResourceGroupName,

    [Parameter(Mandatory)]
    [String]$StorageAccountName,

    [Parameter(Mandatory)]
    [String]$FileShareName,

    [Parameter(Mandatory)]
    [String]$DestinationFolderName,

    [Parameter(Mandatory)]
    [String]$SourceFolderPath,

    [Parameter()]
    [String]$FileMask = ""
)

try{
    Write-Host -ForegroundColor Green "Upload files to file share.."   
    
    ## Get the storage account context  
    $ctx=(Get-AzStorageAccount -ResourceGroupName $ResourceGroupName -Name $StorageAccountName).Context  
    
    ## Get the file share  
    $fileShare=Get-AZStorageShare -Context $ctx -Name $FileShareName 
      
    ## Loop all files in the source-folder
    foreach($file in Get-ChildItem ("$SourceFolderPath") -File)
    {
        ## Does the file match the FileMask
        if($file.Name.EndsWith($FileMask,"CurrentCultureIgnoreCase"))
        {
            ## Upload the file  
            Set-AzStorageFileContent -Share $fileShare -Source $file.FullName -Path $DestinationFolderName -Force 
            Write-Host -ForegroundColor Green "Uploaded the file to File Share: " $($file.Name)
        }
    }

    ## Upload the file  
    Set-AzStorageFileContent -Share $fileShare -Source $fileName -Path $directoryPath -Force 

    Write-Host -ForegroundColor Green "Files have been uploaded.." 
}
catch
{
    $ErrorMessage = $_.Exception.Message
    Write-Error "Failed to upload files to directory '$FolderName' in file-share '$FileShareName'. Reason: $ErrorMessage"
    return $null
}