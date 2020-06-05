Import-Module Vmware.powercli

Function UpdateRule ($RuleName, $VmNames, $Cluster, $VIServer){
    Connect-VIServer -Server $VIServer | out-null
    $antiAffinityVMs = @()
    foreach ($Vm in $VmNames)
    {
        $antiAffinityVMs += Get-VM -Name $Vm
    }

    $ErrorActionPreference="SilentlyContinue"
    try{$Rule = Get-DrsRule -Cluster $Cluster -Name $RuleName}catch{$Rule=$null}
    if ($Rule)
    {
        write-host "Rule" $Rule.name "exists - Checking if all listed vms are members"
        foreach ($vm in $VmNames){write-host $vm}
        $VmIDsRule = $Rule | select -ExpandProperty VMIds | Sort-Object
        $VMIDsAll = $antiAffinityVMs | select -ExpandProperty ID  | Sort-Object
    
        $Compare = Compare-Object -ReferenceObject $VmIDsRule -DifferenceObject $VMIDsAll
        if ($Compare -ne $null)
        {
            Write-host $rule.name "Does not contain the correct virtual machines - Updating rule"
            $ErrorActionPreference="Stop"
            Set-DrsRule -Rule $Rule -VM $antiAffinityVMs -Enabled $true -Confirm:$false
        }
        Write-host "Rule is up to date"
    }
    else
    {
        write-host "Rule $RuleName does not exist - Creating rule"
        $ErrorActionPreference="Stop"
        New-DrsRule -Cluster $Cluster -Name $RuleName -KeepTogether $false -VM $antiAffinityVMs
    }
    $ErrorActionPreference="Stop"
    Write-host "-------------------------------------------------------"
    Disconnect-VIServer $VIServer -Confirm:$false | out-null
}

$VirtualMachines = @("MyVm1", "MyVm2", "MyVm3")
UpdateRule -Cluster "Production" -VIServer "myhost.cotv.dk" -VmNames $VirtualMachines -RuleName "MyVms"