$ConfirmPreference="none"
Import-Module Vmware.powercli
Connect-VIServer -Server "myhost.cotv.dk" | out-null

$report = @()
$clusterName = "*" 

foreach($cluster in Get-Cluster -Name $clusterName){
    $esx = $cluster | Get-VMHost    
    $ds = Get-Datastore -VMHost $esx | where {$_.Type -eq "VMFS" -and $_.Extensiondata.Summary.MultipleHostAccess}
        
    $row = "" | Select VCname,DCname,Clustername,"Total Physical Memory (MB)",
                "Configured Memory MB","Configured Memory %","Available Memory (MB)","Available Memory %",
                "Total CPU (Mhz)","Configured CPU (Mhz)","Configured CPU %","Available CPU (Mhz)","Available CPU %"
    $row.VCname = $cluster.Uid.Split(':@')[1]
    $row.DCname = (Get-Datacenter -Cluster $cluster).Name
    $row.Clustername = $cluster.Name
    $row."Total Physical Memory (MB)" = [math]::Round(($esx | Measure-Object -Property MemoryTotalMB -Sum).Sum)
    $row."Configured Memory MB" = [math]::Round(($esx | Measure-Object -Property MemoryUsageMB -Sum).Sum)
    $row."Configured Memory %" = [math]::Round((([math]::Round(($esx | Measure-Object -Property MemoryUsageMB -Sum).Sum) / $row."Total Physical Memory (MB)") * 100 ), 2)
    $row."Available Memory (MB)" = [math]::Round(($esx | Measure-Object -InputObject {$_.MemoryTotalMB - $_.MemoryUsageMB} -Sum).Sum)
    $row."Available Memory %" = [math]::Round((([math]::Round(($esx | Measure-Object -InputObject {$_.MemoryTotalMB - $_.MemoryUsageMB} -Sum).Sum) / $row."Total Physical Memory (MB)") * 100 ), 2)
    $row."Total CPU (Mhz)" = [math]::Round(($esx | Measure-Object -Property CpuTotalMhz -Sum).Sum)
    $row."Configured CPU (Mhz)" = [math]::Round(($esx | Measure-Object -Property CpuUsageMhz -Sum).Sum)
    $row."Configured CPU %" = [math]::Round((([math]::Round(($esx | Measure-Object -Property CpuUsageMhz -Sum).Sum) / $row."Total CPU (Mhz)") * 100 ), 2)
    $row."Available CPU (Mhz)" = [math]::Round(($esx | Measure-Object -InputObject {$_.CpuTotalMhz - $_.CpuUsageMhz} -Sum).Sum)
    $row."Available CPU %" = [math]::Round((([math]::Round(($esx | Measure-Object -InputObject {$_.CpuTotalMhz - $_.CpuUsageMhz} -Sum).Sum) / $row."Total CPU (Mhz)") * 100 ), 2)
    $report += $row
} 
$report | ft * #Export-Csv "D:\Cluster-Report.csv" -NoTypeInformation -UseCulture

Disconnect-VIServer -Server "myhost.cotv.dk" | out-null