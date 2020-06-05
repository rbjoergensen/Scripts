Import-Module Vmware.powercli | out-null

Connect-VIServer -Server "myhost.cotv.dk" | out-null

$Portgroups = "1000", "2000", "3000"

Foreach ($Portgroup in $Portgroups)
{
    $Error.Clear()
    $ErrorActionPreference="stop"
    try{
        Get-VDSwitch -Name "vDS1" | New-VDPortgroup -Name "PG_$Portgroup" -NumPorts 8 -VlanId $Portgroup
    }
    catch {
        $Error[0].Exception.Message
    }
}

Disconnect-VIServer "myhost.cotv.dk" -Confirm:$false | out-null