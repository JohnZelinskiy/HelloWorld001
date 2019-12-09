<# Script to retrieve specific CDP Info
www.pragmaticio.com
Usage: Include Cluster, VMhost or VirtualCenter name in execution
example: To connect to a cluster called "Production" -- .\get-cdp.ps1 -Cluster Production
example: To connect to a VirtualCenter Server called "ProductionVC" -- .\get-cdp.ps1 -VCServer ProductionVC
example: To connect to a host called host1.local -- .\get-cdp.ps1 -VMhost host1.local

Add/remove Info as required
#>
param(
[string]$VMhost,
[string]$Cluster,
[string]$VCServer
)
If ($VMhost){$vmh = Get-VMHost -Name $VMhost} 
If ($Cluster){$vmh = Get-Cluster $Cluster | Get-VMHost}
If ($VCServer){$vmh = Get-VMhost -Server $VCServer }
$vmh | % {Get-View $_.ID} | `
  % { $esxname = $_.Name; Get-View $_.ConfigManager.NetworkSystem} | `
  % { foreach ($physnic in $_.NetworkInfo.Pnic) {
    $pnicInfo = $_.QueryNetworkHint($physnic.Device)
    foreach( $hint in $pnicInfo ){
       if ( $hint.ConnectedSwitchPort ) {
        $hint.ConnectedSwitchPort | select @{n="VMHost";e={$esxname}},@{n="VMNic";e={$physnic.Device}},DevId,Address,PortId,vLan
        }
      }
    }
  }
