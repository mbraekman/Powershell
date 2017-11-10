Add-AzureRmAccount


Function Add-LoadBalancerRulesForSSO {


  param(
    [string]$subscriptionId,
    [string]$clusterResourceGroupName,
    [string]$loadBalancerName,
    [string]$LoadbalancerFrontEndName,
    [int]$startport,
    [int]$endport
  )
  
  Set-AzureRmContext -Subscriptionid $subscriptionId

  $loadbalancer = Get-AzureRmLoadBalancer -Name $LoadBalancerName -ResourceGroupName $ClusterResourceGroupName
  $FrontEndConfig = Get-AzureRmLoadBalancerFrontendIpConfig -LoadBalancer $loadbalancer -Name $LoadbalancerFrontEndName
  $BackendPool = $Loadbalancer | Get-AzureRmLoadBalancerBackendAddressPoolConfig
  $Probe = Get-AzureRmLoadBalancerProbeConfig -LoadBalancer $loadbalancer -Name "$LoadbalancerFrontEndName-probe" 

  $count = $startport
  while ($count -ne $endport ) {
    $loadbalancer | Add-AzureRmLoadBalancerRuleConfig -Name "$LoadbalancerFrontEndName-rule_$count" -FrontendIpConfiguration $FrontendConfig -BackendAddressPool $BackendPool -Probe $Probe -Protocol TCP -FrontendPort $count -BackendPort $count 
    $loadbalancer | Set-AzureRmLoadBalancer
    $count++
    }
}


#Example usage:

$vars = @{
  subscriptionId = '1234-5678-910'
  clusterResourceGroupName = 'biztalk-sql-cluster-rg'
  loadBalancerName = 'SqlIlb'
  LoadbalancerFrontEndName = 'LB-Frontend-SSO' 
  startPort = 20000
  endPort = 20022
}

Add-LoadBalancerRulesForSSO $vars 
