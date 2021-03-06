﻿param
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

function VerifyAzureFileShareExists 
{
    try{
        $fileShare=Get-AzStorageShare -Context $ctx -Name $FileShareName -ErrorAction Stop 
        return $true
    }
    catch [Microsoft.Azure.Storage.StorageException]
    {
        if($Error[0].Exception.Message -like "*does not exist*")
        {
            Write-Host -ForegroundColor Red "The given file-share '$FileShareName' does not seem to exist in storage account '$StorageAccountName'."
            Write-Error "The given file-share '$FileShareName' does not seem to exist in storage account '$StorageAccountName'."
            return $false
        }
        else
        {
            throw
        }
    }
}


try{
    Write-Host -ForegroundColor Green "Upload files to file share.."   
    
    ## Get the storage account context  
    $ctx=(Get-AzStorageAccount -ResourceGroupName $ResourceGroupName -Name $StorageAccountName).Context  
    
    ## Get the file share  
    if(VerifyAzureFileShareExists)
    {
        ## Loop all files in the source-folder
        foreach($file in Get-ChildItem ("$SourceFolderPath") -File)
        {
            ## Does the file match the FileMask
            if($file.Name.EndsWith($FileMask,"CurrentCultureIgnoreCase"))
            {
                ## Upload the file  
                Set-AzStorageFileContent -Context $ctx -ShareName $FileShareName -Source $file.FullName -Path $DestinationFolderName -Force 
                Write-Host -ForegroundColor Green "Uploaded the file to File Share: " $($file.Name)
            }
        }

        Write-Host -ForegroundColor Green "Files have been uploaded.." 
    }
}
catch
{
    $ErrorMessage = $_.Exception.Message
    Write-Error "Failed to upload files to directory '$DestinationFolderName' in file-share '$FileShareName'. Reason: $ErrorMessage"
    return $null
}