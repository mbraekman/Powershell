#Set-ExecutionPolicy Unrestricted


$configFile="PasswordReplacer-Config.xml"
$bindingFile="Application.BindingInfo.xml"


function Update-ConfigBindings()
{Param(
		[Xml] $xmlBindingConfig
		)
		$bindingConfigContent = [Xml] (Get-Content $bindingFile)
		
		#Get the Password configuration for Send & Receiveports from the config
		$configSendPorts = $xmlBindingConfig.BindingInfo.SendPortCollection
		$configReceivePorts = $xmlBindingConfig.BindingInfo.ReceivePortCollection
		
		
		#Update Send Ports
		#Get Send Ports in Binding
		$nodeSendPorts = $bindingConfigContent.BindingInfo.SendPortCollection
		
		if($nodeSendPorts)
		{
			#Loop all sendports in binding
			foreach($SendPort in $nodeSendPorts.SendPort)
			{
				#Search for a matching item in the config
				$configPort = $configSendPorts.SendPort | Where-Object { $_.GetAttribute("Name") -match $SendPort.GetAttribute("Name") }
				if ($configPort)
				{
					if ($SendPort.PrimaryTransport.TransportTypeData)
					{
						#If match found replace this item
						$transportTypeData = $SendPort.PrimaryTransport.TransportTypeData
						$SendPort.PrimaryTransport.TransportTypeData = $SendPort.PrimaryTransport.TransportTypeData.Replace("******",$configPort.Password)					
					}
				}
			}
		}
		
		
		
		$nodeReceivePorts = $bindingConfigContent.BindingInfo.ReceivePortCollection
		
		if($nodeReceivePorts)
		{
			#Loop all receivePorts in binding
			foreach($ReceivePort in $nodeReceivePorts.ReceivePort)
			{
				
				#Search for a matching item in the config
				if ($configReceivePorts.ReceivePort)
				{
				$configPort = $configReceivePorts.ReceivePort | Where-Object { $_.GetAttribute("Name") -match $ReceivePort.GetAttribute("Name") }
					if ($configPort)
					{
						#Loop all Locations for the receiveport
						foreach($bindingReceiveLocation in $ReceivePort.ReceiveLocations.ReceiveLocation)
						{					
							if ($configPort.ReceiveLocations.ReceiveLocation)
							{
								$configReceiveLocation = $configPort.ReceiveLocations.ReceiveLocation | Where-Object { $_.GetAttribute("Name") -match $bindingReceiveLocation.GetAttribute("Name") }
								if ($configReceiveLocation)
								{
									$bindingReceiveLocation.ReceiveLocationTransportTypeData = $bindingReceiveLocation.ReceiveLocationTransportTypeData.Replace("******",$configReceiveLocation.Password)					
								}
							}
						}					
					}
				}
			}
		}
		
		#And Save
		$bindingConfigContent.Save($bindingFile)
			
}



$xmlBindingConfig =  [Xml] (Get-Content $configFile)
Update-ConfigBindings $xmlBindingConfig
#Write-BindingFiles $bindingConfigFile $xmlBindingConfig
	  
	  