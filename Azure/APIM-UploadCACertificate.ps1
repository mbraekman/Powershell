param(
   [string][parameter(Mandatory = $true)] $ResourceGroup = $(throw "Resource group is required"),
   [string][parameter(Mandatory = $true)] $ServiceName = $(throw "API Management service name is required"),
   [string][parameter(Mandatory = $true)] $CertificateFilePath = $(throw "Certificate file-path is required")

)

Write-Host "Loading Public Certificate"
$rootCA = New-AzApiManagementSystemCertificate -StoreName "Root" -PfxPath $CertificateFilePath
$systemCert = @($rootCa)

Write-Host "Retrieving API Management Service Instance"
$apimContext = Get-AzApiManagement -ResourceGroupName $ResourceGroup -Name $ServiceName
$systemCertificates = $apimContext.SystemCertificates
$systemCertificates += $systemCert
$apimContext.SystemCertificates = $systemCertificates

Write-Host "Uploading the SystemCertificate (This might take some time...)"
    
$result = Set-AzApiManagement -InputObject $apimContext -PassThru
$result
Write-Host "Finished"
