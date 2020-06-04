# Based on haveibeenpwned REST API
# https://haveibeenpwned.com/API/v2#SearchingPwnedPasswordsByRange

Function Get-StringHash([String] $String,$HashName){
    $StringBuilder = New-Object System.Text.StringBuilder
    [System.Security.Cryptography.HashAlgorithm]::Create($HashName).ComputeHash([System.Text.Encoding]::UTF8.GetBytes($String))|%{
    [Void]$StringBuilder.Append($_.ToString("x2"))
    }
    $StringBuilder.ToString()
}

$PassPwned = $false

$password = "Password"
$hash = Get-StringHash -String $Password -HashName "SHA1"
$hashFirst5 = $Hash.substring(0,5)

$response = $null
$response = Invoke-WebRequest -Uri "https://api.pwnedpasswords.com/range/$HashFirst5"
$pwnHashes = $response | select -expand Content

Foreach ($pwnHash in $pwnHashes.split("`n"))
{
    $fullHash = "$hashFirst5$($pwnHash.split(':')[0])"
    if ($hash -eq $fullHash)
    {
        Write-Host "MyPass:      $($hash)"
        Write-Host "PwnPass:     $($fullHash)"
        Write-Host "PwnPassHits: $($pwnHash.split(':')[1])"
        $PassPwned = $true
    }
}

Write-Host "PassPwned:   $PassPwned"
