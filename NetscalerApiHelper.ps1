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

    - Bind-CertTo-Ca
        Link a Certificate to an installed Certificate Authority
        Examples:
            Bind-CertTo-Ca -Cert "MyCert" -Ca "CotvIssuingCA"  

    - Get-CertExpiration
        Get the expiration time in days of an installed Certificate
        Examples:
            Get-CertExpiration -Name "MyCert"

    - Get-CertFilenames
        Get the filenames on a currently installed Certificate to delete them after updating
        Examples:
            Get-CertFilenames -Name "MyCert"

    - Update-Cert
        Update an installed Certificate with a new cert and key
        The new files must have a new unique name, like an appended timestamp
        Examples:
            Update-Cert -Name "MyCert" -Cert "MyCert_06062020-152530.cer" -Key "MyCert_06062020-152530.key"

    - Bind-CipherGroup
        Bind an existing ciphergroup by its name to a Loadbalancing Virtual Server
        Examples:
            Bind-CipherGroup -Lbvs "LBVS_MyServer_HTTPS" -CipherGroup "HIGHSECURITYCIPHERS"

    - Unbind-CipherGroup
        Unbind a ciphergroup by its name from a Loadbalancing Virtual Server
        Examples:
            Unbind-CipherGroup -Lbvs "LBVS_MyServer_HTTPS" -CipherGroup "DEFAULT"

    - New-SslProfile
        Create a new SSLProfile
        Examples:
            New-SslProfile -Name "Custom_Profile" -ssl3 DISABLED -tls1 DISABLED -tls11 DISABLED -tls12 ENABLED -tls13 ENABLED -HSTS ENABLED -IncludeSubdomains YES

    - Delete-SslProfile
        Delete an SSLProfile
        Examples:
            Delete-SslProfile -Name "Custom_Profile"

    - Bind-SslProfile
        Bind an SSLProfile to a Loadbalancing Virtual Server
        Examples:
            Bind-SslProfile -Lbvs "LBVS_MyServer_HTTPS" -SslProfile "Custom_Profile"
    '
}
if ($Endpoint -eq $null){Write-Host 'Endpoint not specified, please set $Endpoint variable like this. "https://hostname.domain.net/nitro/v1"' -ForegroundColor Magenta; Help; Return;}
if ($NSCred -eq $null){$NSCred = get-credential}
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
    $Error.Clear()
    $ErrorActionPreference="Stop"
    try{
        Write-host "Logout" -ForegroundColor Green
        $Response = invoke-webrequest -Uri "$Endpoint/config/logout" -Method:POST -Body '{"logout":{}}' -WebSession $Session -ContentType "application/json" 
        return ("StatusCode: " + $Response.StatusCode + " StatusDescription: " + $Response.StatusDescription)
    }
    catch
    {
        $error[0].ErrorDetails.Message | convertfrom-json | select -ExpandProperty message
    }
}
Function CommitChanges (){
    $Error.Clear()
    $ErrorActionPreference="Stop"
    try{
        Write-host "CommitChanges" -ForegroundColor Green
        $Response = invoke-webrequest -Uri "$Endpoint/config/nsconfig?action=save" -Method:POST -Body '{"nsconfig":{}}' -WebSession $Session -ContentType "application/json" 
        return ("StatusCode: " + $Response.StatusCode + " StatusDescription: " + $Response.StatusDescription)
    }
    catch
    {
        $error[0].ErrorDetails.Message | convertfrom-json | select -ExpandProperty message
    }
}
Function New-Lbvs (){
    param(
        [Parameter(Mandatory=$true)] [ValidateSet('ssl','http')] [string[]] $Type,
        [Parameter(Mandatory=$true)] [string[]] $Name,
        [Parameter(Mandatory=$true)] [string[]] $Port,
        [Parameter(Mandatory=$true)] [string[]] $IpAddress
    )
    $Error.Clear()
    $ErrorActionPreference="Stop"
    try{
        Write-host "New-Lbvs" -ForegroundColor Green
        $Body = '{"lbvserver":{"name":"'+$Name+'","ipv46":"'+$IpAddress+'","port":"'+$Port+'","servicetype":"'+$Type+'"}}'
        $Response = invoke-webrequest -Uri "$Endpoint/config/lbvserver" -Method:POST -Body $Body -WebSession $Session -ContentType "application/json"
        return ("StatusCode: " + $Response.StatusCode + " StatusDescription: " + $Response.StatusDescription)
    }
    catch
    {
        $error[0].ErrorDetails.Message | convertfrom-json | select -ExpandProperty message
    }
}
Function New-Server (){
    param(
        [Parameter(Mandatory=$true)] [string[]] $Name,
        [Parameter(Mandatory=$true)] [string[]] $IpAddress
    )
    $Error.Clear()
    $ErrorActionPreference="Stop"
    try{
        Write-host "New-Server: $Name, $IpAddress" -ForegroundColor Green
        $Body = '{
        "server":
            {
                "name":"'+ $Name +'", 
                "ipaddress":"'+ $IpAddress +'"
            }
        }'
        $Response = invoke-webrequest -Uri "$Endpoint/config/server" -Method:POST -Body $Body -WebSession $Session -ContentType "application/json"
        return ("StatusCode: " + $Response.StatusCode + " StatusDescription: " + $Response.StatusDescription)
    }
    catch
    {
        $error[0].ErrorDetails.Message | convertfrom-json | select -ExpandProperty message
    }
}
Function New-ServiceGroup (){
    param(
        [Parameter(Mandatory=$true)] [string[]] $Name,
        [Parameter(Mandatory=$true)] [ValidateSet('ssl','http')] [string[]] $Type
    )
    $Error.Clear()
    $ErrorActionPreference="Stop"
    try{
        Write-host "New-ServiceGroup" -ForegroundColor Green
        $Body = '{
        “servicegroup":
            {
                "servicegroupname":"'+ $Name +'", 
                ”servicetype":"'+ $Type +'"
            }
        }'
        $Response = invoke-webrequest -Uri "$Endpoint/config/servicegroup" -Method:POST -Body $Body -WebSession $Session -ContentType "application/json"
        return ("StatusCode: " + $Response.StatusCode + " StatusDescription: " + $Response.StatusDescription)
    }
    catch
    {
        $error[0].ErrorDetails.Message | convertfrom-json | select -ExpandProperty message
    }
}
Function New-Monitor (){
    param(
        [Parameter(Mandatory=$true)] [string[]] $Name,
        [Parameter(Mandatory=$true)] [string[]] $Endpoint,
        [Parameter(Mandatory=$true)] [string[]] $ResponseCode,
        [Parameter(Mandatory=$true)] [ValidateSet('true','false')] [string[]] $Secure
    )
    $Error.Clear()
    $ErrorActionPreference="Stop"
    try{
        Write-host "New-Monitor" -ForegroundColor Green
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
    }
    catch
    {
        $error[0].ErrorDetails.Message | convertfrom-json | select -ExpandProperty message
    }
}
Function Bind-SgMember (){
    param(
        [Parameter(Mandatory=$true)] [string[]] $Name,
        [Parameter(Mandatory=$true)] [string[]] $Port,
        [Parameter(Mandatory=$true)] [string[]] $Member
    )
    $Error.Clear()
    $ErrorActionPreference="Stop"
    try{
        Write-host "Bind-SgMember: $Member, $Port" -ForegroundColor Green
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
    }
    catch
    {
        $error[0].ErrorDetails.Message | convertfrom-json | select -ExpandProperty message
    }
}
Function Bind-SgMonitor (){
    param(
        [Parameter(Mandatory=$true)] [string[]] $Monitor,
        [Parameter(Mandatory=$true)] [string[]] $ServiceGroup
    )
    $Error.Clear()
    $ErrorActionPreference="Stop"
    try{
        Write-host "Bind-SgMonitor" -ForegroundColor Green
        $Body = '{
            “lbmonitor_servicegroup_binding":
            {
                "monitorname":"'+ $Monitor +'",
                "servicegroupname":"'+ $ServiceGroup +'"
            }
        }'
        $Response = invoke-webrequest -Uri "$Endpoint/config/lbmonitor_servicegroup_binding" -Method:POST -Body $Body -WebSession $Session -ContentType "application/json"
        return ("StatusCode: " + $Response.StatusCode + " StatusDescription: " + $Response.StatusDescription)
    }
    catch
    {
        $error[0].ErrorDetails.Message | convertfrom-json | select -ExpandProperty message
    }
}
Function Bind-Lbvs (){
    param(
        [Parameter(Mandatory=$true)] [string[]] $ServiceGroup,
        [Parameter(Mandatory=$true)] [string[]] $Lbvserver
    )
    $Error.Clear()
    $ErrorActionPreference="Stop"
    try{
        Write-host "Bind-Lbvs" -ForegroundColor Green
        $Body = '{"lbvserver_servicegroup_binding":{"servicegroupname":"'+ $ServiceGroup +'","name":"'+ $Lbvserver +'"}}'
        $Response = invoke-webrequest -Uri "$Endpoint/config/lbvserver_servicegroup_binding/Lbs_k8s_test-b_nginx" -Method:POST -Body $Body -WebSession $Session -ContentType "application/json"
        return ("StatusCode: " + $Response.StatusCode + " StatusDescription: " + $Response.StatusDescription)
    }
    catch
    {
        $error[0].ErrorDetails.Message | convertfrom-json | select -ExpandProperty message
    }
}
Function Delete-Lbvs (){
    param(
        [Parameter(Mandatory=$true)] [string[]] $Name
    )
    $Error.Clear()
    $ErrorActionPreference="Stop"
    try{
        Write-host "Delete-Lbvs: $Name" -ForegroundColor Green
        $Body = '{"lbvserver":{"name":"'+$Name+'","ipv46":"'+$IpAddress+'","port":"'+$Port+'","servicetype":"'+$Type+'"}}'
        $Response = invoke-webrequest -Uri "$Endpoint/config/lbvserver/$Name" -Method:DELETE -WebSession $Session -ContentType "application/json"
        return ("StatusCode: " + $Response.StatusCode + " StatusDescription: " + $Response.StatusDescription)
    }
    catch
    {
        $error[0].ErrorDetails.Message | convertfrom-json | select -ExpandProperty message
    }
}
Function Delete-ServiceGroup (){
    param(
        [Parameter(Mandatory=$true)] [string[]] $Name
    )
    $Error.Clear()
    $ErrorActionPreference="Stop"
    try{
        Write-host "Delete-ServiceGroup: $Name" -ForegroundColor Green
        $Response = invoke-webrequest -Uri "$Endpoint/config/servicegroup/$Name" -Method:DELETE -WebSession $Session -ContentType "application/json"
        return ("StatusCode: " + $Response.StatusCode + " StatusDescription: " + $Response.StatusDescription)
    }
    catch
    {
        $error[0].ErrorDetails.Message | convertfrom-json | select -ExpandProperty message
    }
}
Function Delete-Server (){
    param(
        [Parameter(Mandatory=$true)] [string[]] $Name
    )
    $Error.Clear()
    $ErrorActionPreference="Stop"
    try{
        Write-host "Delete-Server: $Name" -ForegroundColor Green
        $Response = invoke-webrequest -Uri "$Endpoint/config/server/$Name" -Method:DELETE -WebSession $Session -ContentType "application/json"
        return ("StatusCode: " + $Response.StatusCode + " StatusDescription: " + $Response.StatusDescription)
    }
    catch
    {
        $error[0].ErrorDetails.Message | convertfrom-json | select -ExpandProperty message
    }
}
Function Delete-Monitor (){
    param(
        [Parameter(Mandatory=$true)] [string[]] $Name
    )
    $Error.Clear()
    $ErrorActionPreference="Stop"
    try{
        Write-host "Delete-Monitor: $Name" -ForegroundColor Green
        $Response = invoke-webrequest -Uri ("$Endpoint/config/lbmonitor/"+$Name+"?args=type:HTTP") -Method:DELETE -WebSession $Session -ContentType "application/json"
        return ("StatusCode: " + $Response.StatusCode + " StatusDescription: " + $Response.StatusDescription)
    }
    catch
    {
        $error[0].ErrorDetails.Message | convertfrom-json | select -ExpandProperty message
    }
}
Function Upload-Cert(){
    param(
        [Parameter(Mandatory=$true)] [string[]] $Name,
        [Parameter(Mandatory=$true)] [string[]] $LocalPath
    )
    $Error.Clear()
    $ErrorActionPreference="Stop"
    try{
        Write-host "Upload-Cert: $Name" -ForegroundColor Green
        $Cert = Get-content $LocalPath | Select -Skip 1 | Select -SkipLast 1
        $SingleLine = $null
        foreach ($line in $cert){$SingleLine += $line}
        $Base64 = $SingleLine.Replace(" ","")

        $Body = '{"systemfile":{"filename":"'+ $Name +'","filelocation":"/nsconfig/ssl/","filecontent":"'+ $Base64 +'","fileencoding":"BASE64"}}'
        $Response = invoke-webrequest -Uri "$Endpoint/config/systemfile" -Method:POST -Body $Body -WebSession $Session -ContentType "application/json"
        return ("StatusCode: " + $Response.StatusCode + " StatusDescription: " + $Response.StatusDescription)
    }
    catch
    {
        $error[0].ErrorDetails.Message | convertfrom-json | select -ExpandProperty message
    }
}
Function Update-Cert(){
    param(
        [Parameter(Mandatory=$true)] [string[]] $Name,
        [Parameter(Mandatory=$true)] [string[]] $Cert,
        [Parameter(Mandatory=$true)] [string[]] $Key
    )
    $Error.Clear()
    $ErrorActionPreference="Stop"
    try{
        Write-host "Update-Cert: $Name" -ForegroundColor Green
        $Body = '{"sslcertkey":{"certkey":"'+$Name+'","cert":"'+$Cert+'","key":"'+$Key+'"}}'
        $Response = invoke-webrequest -Uri "$Endpoint/config/sslcertkey?action=update" -Method:POST -Body $Body -WebSession $Session -ContentType "application/json"
        return ("StatusCode: " + $Response.StatusCode + " StatusDescription: " + $Response.StatusDescription)
    }
    catch
    {
        $error[0].ErrorDetails.Message | convertfrom-json | select -ExpandProperty message
    }
}
Function Install-Cert(){
    param(
        [Parameter(Mandatory=$true)] [string[]] $Name,
        [Parameter(Mandatory=$true)] [string[]] $Cert,
        [Parameter(Mandatory=$true)] [string[]] $Key
    )
    $Error.Clear()
    $ErrorActionPreference="Stop"
    try{
        Write-host "Install-Cert: $Name" -ForegroundColor Green
        $Body = '{"sslcertkey":{"certkey":"'+$Name+'","cert":"'+$Cert+'","key":"'+$Key+'"}}'
        $Response = invoke-webrequest -Uri "$Endpoint/config/sslcertkey" -Method:POST -Body $Body -WebSession $Session -ContentType "application/json"
        return ("StatusCode: " + $Response.StatusCode + " StatusDescription: " + $Response.StatusDescription)
    }
    catch
    {
        $error[0].ErrorDetails.Message | convertfrom-json | select -ExpandProperty message
    }
}
Function Install-CA(){
    param(
        [Parameter(Mandatory=$true)] [string[]] $Name,
        [Parameter(Mandatory=$true)] [string[]] $Cert
    )
    $Error.Clear()
    $ErrorActionPreference="Stop"
    try{
        Write-host "Install-CA: $Name" -ForegroundColor Green
        $Body = '{"sslcertkey":{"certkey":"'+$Name+'","cert":"'+$Cert+'"}}' 
        $Response = invoke-webrequest -Uri "$Endpoint/config/sslcertkey" -Method:POST -Body $Body -WebSession $Session -ContentType "application/json"
        return ("StatusCode: " + $Response.StatusCode + " StatusDescription: " + $Response.StatusDescription)
    }
    catch
    {
        $error[0].ErrorDetails.Message | convertfrom-json | select -ExpandProperty message
    }
}
Function Uninstall-Cert(){
    param(
        [Parameter(Mandatory=$true)] [string[]] $Name
    )
    $Error.Clear()
    $ErrorActionPreference="Stop"
    try{
        Write-host "Uninstall-Cert: $Name" -ForegroundColor Green
        $Response = invoke-webrequest -Uri "$Endpoint/config/sslcertkey/$Name" -Method:DELETE -WebSession $Session -ContentType "application/json"
        return ("StatusCode: " + $Response.StatusCode + " StatusDescription: " + $Response.StatusDescription)
    }
    catch
    {
        $error[0].ErrorDetails.Message | convertfrom-json | select -ExpandProperty message
    }
}
Function Get-CertExpiration(){
    param(
        [Parameter(Mandatory=$true)] [string[]] $Name
    )
    $Error.Clear()
    $ErrorActionPreference="Stop"
    try{
        Write-host "Get-CertExpiration: $Name" -ForegroundColor Green
        $Response = invoke-webrequest -Uri ("$Endpoint/config/sslcertkey/$Name") -Method:GET -WebSession $Session -ContentType "application/json"
        return $Response.Content | ConvertFrom-Json | Select -Expand sslcertkey | Select -Expand daystoexpiration
    }
    catch
    {
        $error[0].ErrorDetails.Message | convertfrom-json | select -ExpandProperty message
    }
}
Function Get-CertFilenames(){
    param(
        [Parameter(Mandatory=$true)] [string[]] $Name
    )
    $Error.Clear()
    $ErrorActionPreference="Stop"
    try{
        Write-host "Get-CertFilenames: $Name" -ForegroundColor Green
        $Response = invoke-webrequest -Uri ("$Endpoint/config/sslcertkey/$Name") -Method:GET -WebSession $Session -ContentType "application/json"
        Write-host "Get-CertFilenames Cert: $($Response.Content | ConvertFrom-Json | Select -Expand sslcertkey | Select -Expand cert)"
        Write-host "Get-CertFilenames Key: $($Response.Content | ConvertFrom-Json | Select -Expand sslcertkey | Select -Expand key)"
        return $Response.Content | ConvertFrom-Json | Select -Expand sslcertkey | Select cert, key
    }
    catch
    {
        $error[0].ErrorDetails.Message | convertfrom-json | select -ExpandProperty message
    }
}
Function Delete-Cert(){
    param(
        [Parameter(Mandatory=$true)] [string[]] $Name
    )
    $Error.Clear()
    $ErrorActionPreference="Stop"
    try{
        Write-host "Delete-Cert: $Name" -ForegroundColor Green
        $Response = invoke-webrequest -Uri ("$Endpoint/config/systemfile/$Name" + "?args=filelocation:%2Fnsconfig%2Fssl") -Method:DELETE -WebSession $Session -ContentType "application/json"
        return ("StatusCode: " + $Response.StatusCode + " StatusDescription: " + $Response.StatusDescription)
    }
    catch
    {
        $error[0].ErrorDetails.Message | convertfrom-json | select -ExpandProperty message
    }
}
Function Bind-CertTo-Lbvs(){
    param(
        [Parameter(Mandatory=$true)] [string[]] $LBVS,
        [Parameter(Mandatory=$true)] [string[]] $Cert
    )
    $Error.Clear()
    $ErrorActionPreference="Stop"
    try{
        Write-host "Bind-CertTo-Lbvs: $LBVS, $Cert" -ForegroundColor Green
        $Body = '{"sslvserver_sslcertkey_binding":{"vservername":"'+$LBVS+'","certkeyname":"'+$Cert+'"}}'
        $Response = invoke-webrequest -Uri "$Endpoint/config/sslvserver_sslcertkey_binding" -Method:POST -Body $Body -WebSession $Session -ContentType "application/json"
        return ("StatusCode: " + $Response.StatusCode + " StatusDescription: " + $Response.StatusDescription)
    }
    catch
    {
        $error[0].ErrorDetails.Message | convertfrom-json | select -ExpandProperty message
    }
}
Function Bind-CertTo-Ca(){
    param(
        [Parameter(Mandatory=$true)] [string[]] $Cert,
        [Parameter(Mandatory=$true)] [string[]] $Ca
    )
    $Error.Clear()
    $ErrorActionPreference="Stop"
    try{
        Write-host "Bind-CertTo-Ca: $Cert, $Ca" -ForegroundColor Green
        $Body = '{"sslcertkey":{"certkey":"'+$Cert+'","linkcertkeyname":"'+$Ca+'"}}'
        $Response = invoke-webrequest -Uri "$Endpoint/config/sslcertkey?action=link" -Method:POST -Body $Body -WebSession $Session -ContentType "application/json"
        return ("StatusCode: " + $Response.StatusCode + " StatusDescription: " + $Response.StatusDescription)
    }
    catch
    {
        $error[0].ErrorDetails.Message | convertfrom-json | select -ExpandProperty message
    }
}
Function Bind-CipherGroup(){
    param(
        [Parameter(Mandatory=$true)] [ValidateSet('HIGHSECURITYCIPHERS', 'DEFAULT')] [string[]] $CipherGroup,
        [Parameter(Mandatory=$true)] [string[]] $Lbvs
    )
    $Error.Clear()
    $ErrorActionPreference="Stop"
    try{
        Write-host "Bind-CipherGroup: $Lbvs, $CipherGroup" -ForegroundColor Green
        $Body = '{"sslvserver_sslcipher_binding":{"vservername":"'+$Lbvs+'","ciphername":"'+$CipherGroup+'"}}'
        $Response = invoke-webrequest -Uri "$Endpoint/config/sslvserver_sslcipher_binding" -Method:PUT -Body $Body -WebSession $Session -ContentType "application/json"
        return ("StatusCode: " + $Response.StatusCode + " StatusDescription: " + $Response.StatusDescription)
    }
    catch
    {
        $error[0].ErrorDetails.Message | convertfrom-json | select -ExpandProperty message
    }
}
Function Unbind-CipherGroup(){
    param(
        [Parameter(Mandatory=$true)] [ValidateSet('HIGHSECURITYCIPHERS', 'DEFAULT')] [string[]] $CipherGroup,
        [Parameter(Mandatory=$true)] [string[]] $Lbvs
    )
    $Error.Clear()
    $ErrorActionPreference="Stop"
    try{
        Write-host "Unbind-CipherGroup: $Lbvs, $CipherGroup" -ForegroundColor Green
        $Response = invoke-webrequest -Uri "$Endpoint/config/sslvserver_sslcipher_binding/$($lbvs)?args=ciphername:$CipherGroup" -Method:DELETE -Body $Body -WebSession $Session -ContentType "application/json"
        return ("StatusCode: " + $Response.StatusCode + " StatusDescription: " + $Response.StatusDescription)
    }
    catch
    {
        $error[0].ErrorDetails.Message | convertfrom-json | select -ExpandProperty message
    }
}
Function New-SslProfile(){
    param(
        [Parameter(Mandatory=$true)] [string[]] $Name,
        [Parameter(Mandatory=$true)] [ValidateSet('ENABLED', 'DISABLED')] [string[]] $ssl3,
        [Parameter(Mandatory=$true)] [ValidateSet('ENABLED', 'DISABLED')] [string[]] $tls1,
        [Parameter(Mandatory=$true)] [ValidateSet('ENABLED', 'DISABLED')] [string[]] $tls11,
        [Parameter(Mandatory=$true)] [ValidateSet('ENABLED', 'DISABLED')] [string[]] $tls12,
        [Parameter(Mandatory=$true)] [ValidateSet('ENABLED', 'DISABLED')] [string[]] $tls13,
        [Parameter(Mandatory=$true)] [ValidateSet('ENABLED', 'DISABLED')] [string[]] $HSTS,
        [Parameter()] [int[]] $MaxAge = 1209600,
        [Parameter()] [ValidateSet('YES', 'NO')] [string[]] $IncludeSubdomains="YES"
    )
    $Error.Clear()
    $ErrorActionPreference="Stop"
    try{
        Write-host "New-SslProfile: $Name" -ForegroundColor Green
        $Body = '{"sslprofile":{"name":"'+$Name+'","ssl3":"'+$ssl3+'","tls1":"'+$tls1+'","tls11":"'+$tls11+'","tls12":"'+$tls12+'","tls13":"'+$tls13+'","hsts":"'+$HSTS+'","maxage":"'+$MaxAge+'","includesubdomains":"'+$IncludeSubdomains+'"}}'
        $Response = invoke-webrequest -Uri "$Endpoint/config/sslprofile" -Method:POST -Body $Body -WebSession $Session -ContentType "application/json"
        return ("StatusCode: " + $Response.StatusCode + " StatusDescription: " + $Response.StatusDescription)
    }
    catch
    {
        $error[0].ErrorDetails.Message | convertfrom-json | select -ExpandProperty message
    }
}
Function Delete-SslProfile(){
    param(
        [Parameter(Mandatory=$true)] [string[]] $Name
    )
    $Error.Clear()
    $ErrorActionPreference="Stop"
    try{
        Write-host "Delete-SslProfile: $Name" -ForegroundColor Green
        $Response = invoke-webrequest -Uri "$Endpoint/config/sslprofile/$Name" -Method:DELETE -Body $Body -WebSession $Session -ContentType "application/json"
        return ("StatusCode: " + $Response.StatusCode + " StatusDescription: " + $Response.StatusDescription)
    }
    catch
    {
        $error[0].ErrorDetails.Message | convertfrom-json | select -ExpandProperty message
    }
}
Function Bind-SslProfile(){
    param(
        [Parameter(Mandatory=$true)] [string[]] $SslProfile,
        [Parameter(Mandatory=$true)] [string[]] $Lbvs
    )
    $Error.Clear()
    $ErrorActionPreference="Stop"
    try{
        Write-host "Bind-SslProfile: $Lbvs, $CipherGroup" -ForegroundColor Green
        $Body = '{"sslvserver":{"vservername":"'+$Lbvs+'","sslprofile":"'+$SslProfile+'"}}'
        $Response = invoke-webrequest -Uri "$Endpoint/config/sslvserver" -Method:PUT -Body $Body -WebSession $Session -ContentType "application/json"
        return ("StatusCode: " + $Response.StatusCode + " StatusDescription: " + $Response.StatusDescription)
    }
    catch
    {
        $error[0].ErrorDetails.Message | convertfrom-json | select -ExpandProperty message
    }
}

<# ToDo Functions
- Create Content Switch Virtual Server
- Create Content Switch Policy
- Create Bindings for content switch objects
#>