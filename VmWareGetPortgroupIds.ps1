Import-Module Vmware.powercli

Connect-VIServer -Server "myhost.cotv.dk" | out-null

get-virtualportgroup | sort-object name

Disconnect-VIServer "myhost.cotv.dk" -Confirm:$false | out-null