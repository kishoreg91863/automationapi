
$var = (& '.\Get-Accounts.ps1' -PVWAURL https://asscvppvcpvwa01.cis.neustar.com/PasswordVault -List -Keywords "tester").id
#$idr = $var.id
#$addr = $var.address
write-output "$var"
#Write-Output "$addr"

# start deleting the account
For ($i=0; $i -lt $var.Length; $i++) {
    if ($var) {
        & '.\Delete.ps1' -AccountID $var
        }
        else {Write-Host "[ERROR] incorrect result "}
    }