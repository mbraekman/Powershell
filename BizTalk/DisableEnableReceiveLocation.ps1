$ReceiveLocationName = "rlo_PickUpFiles_FILE"
Try
{
    #
    # Get the Recieve Location of the specified name and Disable
    #
    Write-Host "Retrieving the Receive Location " $ReceiveLocationName
    $nameFilter = "name='" + $ReceiveLocationName.ToString() + "'"
    $location = get-wmiobject msbts_receivelocation -Namespace 'root\MicrosoftBizTalkServer' -Filter $nameFilter

    #
    # Disable the Recieve Location
    #
    Write-Host "Disabling the Receive Location " $ReceiveLocationName
    $location.Disable()

    # OR 

    #
    # Enable the Recieve Location
    #
    Write-Host "Enabling the Receive Location " $ReceiveLocationName
    $location.Enable()

    Write-Host "Finished"
}Catch
{
    Write-Host "An error occurred while attempting to disable/enable the receive location " $ReceiveLocationName
    Write-Host "ErrorMessage: " $_.Exception.Message
}