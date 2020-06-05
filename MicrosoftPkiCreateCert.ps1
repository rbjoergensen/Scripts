$SANs   = @("testcert.cotv.dk", "www.testcert.cotv.dk")
$Folder  = $SANs[0]

$Error.Clear()
$ErrorActionPreference="Stop"
try{
$CertDir = "\\cotv.net\files\certificates\$Folder"
$PkiSrv  = "MyPkiServer"
$Keyout  = "$CertDir\certificate.key"
$Request = "$CertDir\req.conf"
$CSR     = "$CertDir\certificate.csr"
$CER     = "$CertDir\certificate.cer"
$RSP     = "$CertDir\certificate.rsp"
$PFX     = "$CertDir\certificate.pfx"
$DecKey  = "$CertDir\certificate.key"

$password = ConvertTo-SecureString "%{password}" -AsPlainText -Force
$cred = New-Object System.Management.Automation.PSCredential ("%{username}", $password)

$RequestContent = "[req]
prompt = no
default_bits = 2048
distinguished_name = req_distinguished_name
req_extensions = req_ext
[req_distinguished_name]
countryName = DK
localityName = MyCity
organizationName = CalloftheVoid
commonName = "+ $SANs[0] +"
[req_ext]
subjectAltName = @alt_names
[alt_names]"
New-Item -Path $Request -Force
$RequestContent | Add-Content -Path $Request

$Count = 1
foreach ($SAN in $SANs)
{
    Add-Content -Path $Request -Value ("DNS.$Count = " + $SAN)
    $Count++
}

cd "C:\Program Files\OpenSSL-Win64\bin"
$erroractionpreference="silentlycontinue"
try{
Write-Host "Generate CSR"
$CMD = 'openssl req -new -newkey rsa:2048 -sha256 -nodes -out "' + $CSR + '" -keyout "' + $Keyout + '" -config "' + $Request + '"'
cmd /c "$CMD"
}catch{}
$erroractionpreference="stop"

Write-Host "Copy CSR to PKI Server"
copy-item -Path $CSR -Destination "\\$PkiSrv\d$\CertificateAutomation\"

Write-Host "Generate CER on PKI Server"
invoke-command -ComputerName $PkiSrv -Credential $Cred -ScriptBlock {
    $CSR      = "D:\CertificateAutomation\certificate.csr"
    $CER      = "D:\CertificateAutomation\certificate.cer"
    $Config   = "$PkiSrv.cotv.net\Cotv Issuing CA 1"
    $Template = "CertificateTemplate: CotvWebserverTemplate1"
    $CMD      = 'certreq -q -f -config "' + $Config + '" -submit -attrib "' + $Template + '" ' + $CSR + ' ' + $CER
    cmd /c "$CMD"
}

Write-Host "Move CER to certificate dir"
Move-Item -Path "\\$PkiSrv\d$\CertificateAutomation\certificate.cer" -Destination $CER -Force
Move-Item -Path "\\$PkiSrv\d$\CertificateAutomation\certificate.rsp" -Destination $RSP -Force
Remove-Item -Path "\\$PkiSrv\d$\CertificateAutomation\certificate.csr"

Write-Host "Generate PFX"
$CMD = 'openssl pkcs12 -export -out "'+$PFX+'" -inkey "'+$Keyout+'" -in "'+$CER+'" -passout pass:' + "%{keypass}"
cmd /c "$CMD"
}catch{throw $error}