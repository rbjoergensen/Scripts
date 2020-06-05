# Based on https://github.com/rmbolger/Posh-ACME/blob/master/Tutorial.md

# Variables
$r53Secret         = ConvertTo-SecureString -String "MyAwsSecretKey" -AsPlainText -Force
$r53Params         = @{R53AccessKey="MyAwsAccountKey"; R53SecretKey=$r53Secret}
$pfxPass           = "MyPfxPassword"
$friendlyName      = "LetsEncrypt - $($domainNames[0])"
$domainNames       = @("test.cotv.dk", "www.test.cotv.dk")
$letsEncryptServer = "LE_STAGE" # "LE_STAGE", "LE_PROD", "https://acme-staging-v02.api.letsencrypt.org/directory"
$contact           = "devops@cotv.dk"
$outputDir         = "C:\Users\Solenya\Desktop\Vault"
$zipFile           = "$outputDir\CertificateFiles.zip"

New-PACertificate $domainNames -AcceptTOS -Contact $contact -DnsPlugin Route53 -PluginArgs $r53Params -PfxPass $pfxPass -FriendlyName $friendlyName -DirectoryUrl $letsEncryptServer -Verbose
# Move the files from the AppData folder
$certFolder = (Get-Item -Path (Get-PACertificate | Select -ExpandProperty CertFile)).DirectoryName
Move-Item -Path "$certFolder\*" -Destination $outputDir -Verbose -Force
# Zip the files
Compress-Archive -LiteralPath (Get-Childitem -Path $outputDir -Recurse).FullName -DestinationPath $zipFile -Force

<# 
> Get-PACertificate
Subject       : CN=test.cotv.dk
NotBefore     : 6/5/2020 11:03:33 AM
NotAfter      : 9/3/2020 11:03:33 AM
KeyLength     : 2048
Thumbprint    : 0000000000000000000000000000000000000000
AllSANs       : {test.cotv.dk, www.test.cotv.dk}
CertFile      : C:\Users\Solenya\AppData\Local\Posh-ACME\acme-staging-v02.api.letsencrypt.org\00000000\test.cotv.dk\cert.cer
KeyFile       : C:\Users\Solenya\AppData\Local\Posh-ACME\acme-staging-v02.api.letsencrypt.org\14031526\test.cotv.dk\cert.key
ChainFile     : C:\Users\Solenya\AppData\Local\Posh-ACME\acme-staging-v02.api.letsencrypt.org\14031526\test.cotv.dk\chain.cer
FullChainFile : C:\Users\Solenya\AppData\Local\Posh-ACME\acme-staging-v02.api.letsencrypt.org\14031526\test.cotv.dk\fullchain.cer
PfxFile       : C:\Users\Solenya\AppData\Local\Posh-ACME\acme-staging-v02.api.letsencrypt.org\14031526\test.cotv.dk\cert.pfx
PfxFullChain  : C:\Users\Solenya\AppData\Local\Posh-ACME\acme-staging-v02.api.letsencrypt.org\14031526\test.cotv.dk\fullchain.pfx
PfxPass       : System.Security.SecureString
#>
