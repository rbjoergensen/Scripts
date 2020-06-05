Clear
if ($Endpoint -eq $null){$Endpoint = "https://<something.net>/nitro/v1"; Write-Host "Endpoint not specified as Endpoint variable. Defaulting to $Endpoint" -ForegroundColor Magenta}
if ($NSCred -eq $null){$NSCred = get-credential}
$Session = New-Object Microsoft.PowerShell.Commands.WebRequestSession
Function Help (){
    Clear-Host
    Write-Host '
    This helper will prompt you to enter a set of credentials to authenticate with and to specify the variable Endpoint

    This helper contains the following functions:
    ---------------------------------------------
    - Login
        Starts a session

    - Logout
        Ends a session

    - CommitChanges
        Saves the changes permanently

    - New-Lbvs ()
        Create a new Loadbalancing Virtual Server
        Examples:
            New-Lbvs -Name "LBVS_MyServer_HTTPS" -Type "ssl" -Port "443" -IpAddress "10.1.1.25"
            New-Lbvs -Name "LBVS_MyServer_HTTP" -Type "http" -Port "80" -IpAddress "10.1.1.26"

    - New-Server ()
        Create a new Server
        Examples:
            New-Server -Name "MyBackendServer" -IpAddress 10.1.2.50"

    - New-ServiceGroup ()
        Create a new Service Group
        Examples:
            New-ServiceGroup -Name "SG_MyServiceGroup_HTTPS" -Type "ssl"
            New-ServiceGroup -Name "SG_MyServiceGroup_HTTP" -Type "http"

    - New-Monitor ()
        Create a new Monitor
        Examples:
            New-Monitor -Name "MON_MyMonitorDefault_HTTPS" -Endpoint "/health" -ResponseCode "200" -Secure "true"
            New-Monitor -Name "MON_MyMonitorDefault_HTTP" -Endpoint "/health" -ResponseCode "200" -Secure "false"

    - Bind-SgMember ()
        Bind a Server to a Service Group
        Examples:
            Bind-SgMember -Name "SG_MyServiceGroup_HTTPS" -Port "30262" -Member "MyBackendServer"
            Bind-SgMember -Name "SG_MyServiceGroup_HTTP" -Port "30261" -Member "MyBackendServer"

    - Bind-SgMonitor ()
        Bind a monitor to a Service Group
        Examples:
            Bind-SgMonitor -Monitor "MON_MyMonitorDefault_HTTPS" -ServiceGroup "SG_MyServiceGroup_HTTPS" -Secure "True"
            Bind-SgMonitor -Monitor "MON_MyMonitorDefault_HTTP" -ServiceGroup "SG_MyServiceGroup_HTTP" -Secure "False"

    - Bind-Lbvs ()
        Bind a Service Group to a Loadbalancing Virtual Server
        Examples:
            Bind-Lbvs -ServiceGroup "SG_MyServiceGroup_HTTPS" -Lbvserver "LBVS_MyServer_HTTPS"
            Bind-Lbvs -ServiceGroup "SG_MyServiceGroup_HTTP" -Lbvserver "LBVS_MyServer_HTTP"

    - Delete-Lbvs ()
        Delete a Loadbalancing Virtual Server
        Examples:
            Delete-Lbvs -Name "LBVS_MyServer_HTTPS"

    - Delete-ServiceGroup ()
        Delete a Service Group
        Examples:
            Delete-ServiceGroup -Name "SG_MyServiceGroup_HTTPS"

    - Delete-Server ()
        Delete a Server
        Examples:
            Delete-Server -Name "MyBackendServer"

    - Delete-Monitor ()
        Delete a Monitor
        Examples:
            Delete-Monitor "MON_MyMonitorDefault_HTTPS"

    - Upload-Cert ()
        Upload a Certificate or Certificate Authority
        Make sure the name is unique or you can have problems with certificates switching place!
        Examples:
            Upload-Cert -Name "MyCert.cer" -LocalPath "C:\Certificates\MyCert.cer"
            Upload-Cert -Name "MyCert.key" -LocalPath "C:\Certificates\MyCert.key"
            Upload-Cert -Name "CotvIssuingCA.cer" -LocalPath "C:\Certificates\CotvIssuingCA.cer"

    - Install-Cert ()
        Install a Certificate
        Examples:
            Install-Cert -Name "MyCert" -Cert "MyCert.cer" -Key "MyCert.key"

    - Install-CA ()
        Install a Certificate Authority
        Examples:
            Install-CA -Name "CotvIssuingCA" -Cert "CotvIssuingCA.cer"

    - Uninstall-Cert ()
        Uninstall a Certificate or Certificate Authority
        Examples:
            Uninstall-Cert -Name "MyCert"
            Uninstall-Cert -Name "CotvIssuingCA"

    - Delete-Cert ()
        Delete a Certificate
        Examples:
            Delete-Cert -Name "MyCert.cer"
            Delete-Cert -Name "MyCert.key"

    - Bind-CertTo-Lbvs ()
        Bind a Certificate to a Loadbalancing Virtual Server
        Examples:
            Bind-CertTo-Lbvs -LBVS "LBVS_MyServer_HTTPS" -Cert "MyCert"
    '
}
Function Login (){
    $Error.Clear()
    $ErrorActionPreference="Stop"
    try{
        Write-host "Login" -ForegroundColor Green
        $Body = '{"login":{"username":"'+$NSCred.UserName+'","password":"'+$NSCred.GetNetworkCredential().password+'","timeout":900}}'
        $Response = invoke-webrequest -Uri "$Endpoint/config/login" -Method:POST -Body $Body -ContentType "application/vnd.com.citrix.netscaler.login+json" -WebSession $Session
        Write-host ("StatusCode: " + $Response.StatusCode + " StatusDescription: " + $Response.StatusDescription)
    }
    catch
    {
        $error[0].ErrorDetails.Message | convertfrom-json
    }
}
Function Logout (){
    Write-host "Logout" -ForegroundColor Green
    $Error.Clear()
    $ErrorActionPreference="Stop"
    try{
        $Response = invoke-webrequest -Uri "$Endpoint/config/logout" -Method:POST -Body '{"logout":{}}' -WebSession $Session -ContentType "application/json" 
        return ("StatusCode: " + $Response.StatusCode + " StatusDescription: " + $Response.StatusDescription)
    }
    catch
    {
        $error[0].ErrorDetails.Message | convertfrom-json | select -ExpandProperty message
    }
}
Function CommitChanges (){
	Write-host "CommitChanges" -ForegroundColor Green
    $Error.Clear()
    $ErrorActionPreference="Stop"
    try{
    $Response = invoke-webrequest -Uri "$Endpoint/config/nsconfig?action=save" -Method:POST -Body '{"nsconfig":{}}' -WebSession $Session -ContentType "application/json" 
    return ("StatusCode: " + $Response.StatusCode + " StatusDescription: " + $Response.StatusDescription)
    }catch{$error[0].ErrorDetails.Message | convertfrom-json | select -ExpandProperty message}
}
Function New-Lbvs ($Name, $Type, $Port, $IpAddress){
    Write-host "Lbvserver" -ForegroundColor Green
    $Error.Clear()
    $ErrorActionPreference="Stop"
    try{
    $Body = '{"lbvserver":{"name":"'+$Name+'","ipv46":"'+$IpAddress+'","port":"'+$Port+'","servicetype":"'+$Type+'"}}'
    $Response = invoke-webrequest -Uri "$Endpoint/config/lbvserver" -Method:POST -Body $Body -WebSession $Session -ContentType "application/json"
    return ("StatusCode: " + $Response.StatusCode + " StatusDescription: " + $Response.StatusDescription)
    }catch{$error[0].ErrorDetails.Message | convertfrom-json | select -ExpandProperty message}
}
Function New-Server ($Name, $IpAddress){
    Write-host "Server: $Name, $IpAddress" -ForegroundColor Green
    $Error.Clear()
    $ErrorActionPreference="Stop"
    try{
    $Body = '{
    "server":
        {
            "name":"'+ $Name +'", 
            "ipaddress":"'+ $IpAddress +'"
        }
    }'
    $Response = invoke-webrequest -Uri "$Endpoint/config/server" -Method:POST -Body $Body -WebSession $Session -ContentType "application/json"
    return ("StatusCode: " + $Response.StatusCode + " StatusDescription: " + $Response.StatusDescription)
    }catch{$error[0].ErrorDetails.Message | convertfrom-json | select -ExpandProperty message}
}
Function New-ServiceGroup ($Name, $Type){
    Write-host "ServiceGroup" -ForegroundColor Green
    $Error.Clear()
    $ErrorActionPreference="Stop"
    try{
    $Body = '{
    “servicegroup":
        {
            "servicegroupname":"'+ $Name +'", 
            ”servicetype":"'+ $Type +'"
        }
    }'
    $Response = invoke-webrequest -Uri "$Endpoint/config/servicegroup" -Method:POST -Body $Body -WebSession $Session -ContentType "application/json"
    return ("StatusCode: " + $Response.StatusCode + " StatusDescription: " + $Response.StatusDescription)
    }catch{$error[0].ErrorDetails.Message | convertfrom-json | select -ExpandProperty message}
}
Function New-Monitor ($Name, $Endpoint, $ResponseCode, $Secure){
    Write-host "Monitor" -ForegroundColor Green
    $Error.Clear()
    $ErrorActionPreference="Stop"
    try{
    if ($Secure -eq "true")
    {
        $Body = '{
        “lbmonitor":
            {
                "monitorname":"'+ $Name +'",
                "type":"HTTP",
                ”httprequest”:”GET '+ $Endpoint +'”,
                "respcode":["'+ $ResponseCode +'"],
                "secure":"yes"
            }
        }'
    }
    else
    {
        $Body = '{
        “lbmonitor":
            {
                "monitorname":"'+ $Name +'",
                "type":"HTTP",
                ”httprequest”:”GET '+ $Endpoint +'”,
                "respcode":["'+ $ResponseCode +'"],
                "secure":"no"
            }
        }'
    }
    $Response = invoke-webrequest -Uri "$Endpoint/config/lbmonitor" -Method:POST -Body $Body -WebSession $Session -ContentType "application/json"
    return ("StatusCode: " + $Response.StatusCode + " StatusDescription: " + $Response.StatusDescription)
    }catch{$error[0].ErrorDetails.Message | convertfrom-json | select -ExpandProperty message}
}
Function Bind-SgMember ($Name, $Port, $Member){
    Write-host "SGMemberBinding: $Member, $Port" -ForegroundColor Green
    $Error.Clear()
    $ErrorActionPreference="Stop"
    try{
    $Body = '{
    “servicegroup_servicegroupmember_binding":
        {
            "servicegroupname":“'+ $Name +'",
            "port":'+ $Port +',
            ”servername”:”'+ $Member +'”
        }
    }'
    $Response = invoke-webrequest -Uri "$Endpoint/config/servicegroup_servicegroupmember_binding" -Method:POST -Body $Body -WebSession $Session -ContentType "application/json"
    return ("StatusCode: " + $Response.StatusCode + " StatusDescription: " + $Response.StatusDescription)
    }catch{$error[0].ErrorDetails.Message | convertfrom-json | select -ExpandProperty message}
}
Function Bind-SgMonitor ($Monitor, $ServiceGroup){
    Write-host "MonitorBinding" -ForegroundColor Green
    $Error.Clear()
    $ErrorActionPreference="Stop"
    try{
    $Body = '{
        “lbmonitor_servicegroup_binding":
        {
            "monitorname":"'+ $Monitor +'",
            "servicegroupname":"'+ $ServiceGroup +'"
        }
    }'
    $Response = invoke-webrequest -Uri "$Endpoint/config/lbmonitor_servicegroup_binding" -Method:POST -Body $Body -WebSession $Session -ContentType "application/json"
    return ("StatusCode: " + $Response.StatusCode + " StatusDescription: " + $Response.StatusDescription)
    }catch{$error[0].ErrorDetails.Message | convertfrom-json | select -ExpandProperty message}
}
Function Bind-Lbvs ($ServiceGroup, $Lbvserver){
    Write-host "LbvserverBinding" -ForegroundColor Green
    $Error.Clear()
    $ErrorActionPreference="Stop"
    try{
    $Body = '{"lbvserver_servicegroup_binding":{"servicegroupname":"'+ $ServiceGroup +'","name":"'+ $Lbvserver +'"}}'
    $Response = invoke-webrequest -Uri "$Endpoint/config/lbvserver_servicegroup_binding/Lbs_k8s_test-b_nginx" -Method:POST -Body $Body -WebSession $Session -ContentType "application/json"
    return ("StatusCode: " + $Response.StatusCode + " StatusDescription: " + $Response.StatusDescription)
    }catch{$error[0].ErrorDetails.Message | convertfrom-json | select -ExpandProperty message}
}
Function Delete-Lbvs ($Name){
    Write-host "DeleteLbvserver: $Name" -ForegroundColor Green
    $Error.Clear()
    $ErrorActionPreference="Stop"
    try{
    $Body = '{"lbvserver":{"name":"'+$Name+'","ipv46":"'+$IpAddress+'","port":"'+$Port+'","servicetype":"'+$Type+'"}}'
    $Response = invoke-webrequest -Uri "$Endpoint/config/lbvserver/$Name" -Method:DELETE -WebSession $Session -ContentType "application/json"
    return ("StatusCode: " + $Response.StatusCode + " StatusDescription: " + $Response.StatusDescription)
    }catch{$error[0].ErrorDetails.Message | convertfrom-json | select -ExpandProperty message}
}
Function Delete-ServiceGroup ($Name){
    Write-host "DeleteServiceGroup: $Name" -ForegroundColor Green
    $Error.Clear()
    $ErrorActionPreference="Stop"
    try{
    $Response = invoke-webrequest -Uri "$Endpoint/config/servicegroup/$Name" -Method:DELETE -WebSession $Session -ContentType "application/json"
    return ("StatusCode: " + $Response.StatusCode + " StatusDescription: " + $Response.StatusDescription)
    }catch{$error[0].ErrorDetails.Message | convertfrom-json | select -ExpandProperty message}
}
Function Delete-Server ($Name){
    Write-host "DeleteServer: $Name" -ForegroundColor Green
    $Error.Clear()
    $ErrorActionPreference="Stop"
    try{
    $Response = invoke-webrequest -Uri "$Endpoint/config/server/$Name" -Method:DELETE -WebSession $Session -ContentType "application/json"
    return ("StatusCode: " + $Response.StatusCode + " StatusDescription: " + $Response.StatusDescription)
    }catch{$error[0].ErrorDetails.Message | convertfrom-json | select -ExpandProperty message}
}
Function Delete-Monitor ($Name){
    Write-host "DeleteMonitor: $Name" -ForegroundColor Green
    $Error.Clear()
    $ErrorActionPreference="Stop"
    try{
    $Response = invoke-webrequest -Uri ("$Endpoint/config/lbmonitor/"+$Name+"?args=type:HTTP") -Method:DELETE -WebSession $Session -ContentType "application/json"
    return ("StatusCode: " + $Response.StatusCode + " StatusDescription: " + $Response.StatusDescription)
    }catch{$error[0].ErrorDetails.Message | convertfrom-json | select -ExpandProperty message}
}
Function Upload-Cert($Name, $LocalPath){
    Write-host "UploadCert: $Name" -ForegroundColor Green
    $Error.Clear()
    $ErrorActionPreference="Stop"
    try{

    $Cert = Get-content $LocalPath | Select -Skip 1 | Select -SkipLast 1
    $SingleLine = $null
    foreach ($line in $cert){$SingleLine += $line}
    $Base64 = $SingleLine.Replace(" ","")

    $Body = '{"systemfile":{"filename":"'+ $Name +'","filelocation":"/nsconfig/ssl/","filecontent":"'+ $Base64 +'","fileencoding":"BASE64"}}'
    $Response = invoke-webrequest -Uri "$Endpoint/config/systemfile" -Method:POST -Body $Body -WebSession $Session -ContentType "application/json"
    return ("StatusCode: " + $Response.StatusCode + " StatusDescription: " + $Response.StatusDescription)
    }catch{$error[0].ErrorDetails.Message | convertfrom-json | select -ExpandProperty message}
}
Function Install-Cert($Name, $Cert, $Key){
    Write-host "InstallCert: $Name" -ForegroundColor Green
    $Error.Clear()
    $ErrorActionPreference="Stop"
    try{
    $Body = '{"sslcertkey":{"certkey":"'+$Name+'","cert":"'+$Cert+'","key":"'+$Key+'"}}'
    $Response = invoke-webrequest -Uri "$Endpoint/config/sslcertkey" -Method:POST -Body $Body -WebSession $Session -ContentType "application/json"
    return ("StatusCode: " + $Response.StatusCode + " StatusDescription: " + $Response.StatusDescription)
    }catch{$error[0].ErrorDetails.Message | convertfrom-json | select -ExpandProperty message}
}
Function Install-CA($Name, $Cert){
    Write-host "InstallCA: $Name" -ForegroundColor Green
    $Error.Clear()
    $ErrorActionPreference="Stop"
    try{
    $Body = '{"sslcertkey":{"certkey":"'+$Name+'","cert":"'+$Cert+'"}}' 
    $Response = invoke-webrequest -Uri "$Endpoint/config/sslcertkey" -Method:POST -Body $Body -WebSession $Session -ContentType "application/json"
    return ("StatusCode: " + $Response.StatusCode + " StatusDescription: " + $Response.StatusDescription)
    }catch{$error[0].ErrorDetails.Message | convertfrom-json | select -ExpandProperty message}
}
Function Uninstall-Cert($Name){
    Write-host "UninstallCert: $Name" -ForegroundColor Green
    $Error.Clear()
    $ErrorActionPreference="Stop"
    try{
    $Response = invoke-webrequest -Uri "$Endpoint/config/sslcertkey/$Name" -Method:DELETE -WebSession $Session -ContentType "application/json"
    return ("StatusCode: " + $Response.StatusCode + " StatusDescription: " + $Response.StatusDescription)
    }catch{$error[0].ErrorDetails.Message | convertfrom-json | select -ExpandProperty message}
}
Function Delete-Cert($Name){
    Write-host "DeleteCert: $Name" -ForegroundColor Green
    $Error.Clear()
    $ErrorActionPreference="Stop"
    try{
    $Response = invoke-webrequest -Uri ("$Endpoint/config/systemfile/$Name" + "?args=filelocation:%2Fnsconfig%2Fssl") -Method:DELETE -WebSession $Session -ContentType "application/json"
    return ("StatusCode: " + $Response.StatusCode + " StatusDescription: " + $Response.StatusDescription)
    }catch{$error[0].ErrorDetails.Message | convertfrom-json | select -ExpandProperty message}
}
Function Bind-CertTo-Lbvs($LBVS, $Cert){
    Write-host "BindCertLbvs: $LBVS, $Cert" -ForegroundColor Green
    $Error.Clear()
    $ErrorActionPreference="Stop"
    try{
    $Body = '{"sslvserver_sslcertkey_binding":{"vservername":"'+$LBVS+'","certkeyname":"'+$Cert+'"}}'
    $Response = invoke-webrequest -Uri "$Endpoint/config/sslvserver_sslcertkey_binding" -Method:POST -Body $Body -WebSession $Session -ContentType "application/json"
    return ("StatusCode: " + $Response.StatusCode + " StatusDescription: " + $Response.StatusDescription)
    }catch{$error[0].ErrorDetails.Message | convertfrom-json | select -ExpandProperty message}
}

<# ToDo Functions
- Bind certificate to Root CA
- Set Cipher Group (and remove default)
- Set TLS versions
- Create Content Switch Virtual Server
- Create Content Switch Policy
- Create Bindings for content switch objects
#>
