Login-AzureRmAccount

$ClusterNetworkName = "<MyClusterNetworkName>" # the cluster network name. e.g.: 'Cluster Network 1'
$IPResourceName = "<IPResourceName>" # the IP Address resource name. e.g.: 'IP Address 10.2.1.35'
$ILBIP = "<n.n.n.n>" # the IP Address of the Internal Load Balancer (ILB). e.g. '10.2.1.35'
                     # This is the static IP address for the load balancer you configured in the Azure portal.
[int]$ProbePort = <nnnnn>  # The port-number that has been assigned to the Health probe. e.g. 60001

Import-Module FailoverClusters

Get-ClusterResource $IPResourceName | Set-ClusterParameter -Multiple @{"Address"="$ILBIP";"ProbePort"=$ProbePort;"SubnetMask"="255.255.255.255";"Network"="$ClusterNetworkName";"EnableDhcp"=0} 
