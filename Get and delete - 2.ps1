$snow = (& '.\runjson.ps1' | ConvertFrom-Json)
$host1 = $snow.host
Write-Host "$host1"
foreach ($element in $host1) {
Write-Host "$element"
$var = (& '.\Get-Accounts.ps1' -PVWAURL https://pvwaabc_url.com/PasswordVault -List -Keywords "$host1")
$idr = $var.id
$addr = $var.address
write-host "$idr"
#Write-Output "$addr"
foreach ($element in $idr) {
Write-Host "$element"
# start deleting the account
#For ($i=0; $i -lt $idr.Length; $i++) {
    function PASREST-Logon {

    # Declaration
    $webServicesLogon = "$PVWA_URL/PasswordVault/WebServices/auth/Cyberark/CyberArkAuthenticationService.svc/Logon"

    # Authentication
    $bodyParams = @{username = "local_user"; password = "password123"} | ConvertTo-JSON

    # Execution
    try {
        $logonResult = Invoke-RestMethod -Uri $webServicesLogon -Method POST -ContentType "application/json" -Body $bodyParams -ErrorVariable logonResultErr
        Return $logonResult.CyberArkLogonResult
    }
    catch {
        Write-Host "StatusCode: " $_.Exception.Response.StatusCode.value__
        Write-Host "StatusDescription: " $_.Exception.Response.StatusDescription
        Write-Host "Response: " $_.Exception.Message
        Return $false
    }
}

function PASREST-Logoff ([string]$Authorization) {

    # Declaration
    $webServicesLogoff = "$PVWA_URL/PasswordVault/WebServices/auth/Cyberark/CyberArkAuthenticationService.svc/Logoff"

    # Authorization
    $headerParams = @{}
    $headerParams.Add("Authorization",$Authorization)

    # Execution
    try {
        $logoffResult = Invoke-RestMethod -Uri $webServicesLogoff -Method POST -ContentType "application/json" -Header $headerParams -ErrorVariable logoffResultErr
        Return $true
    }
    catch {
        Write-Host "StatusCode: " $_.Exception.Response.StatusCode.value__
        Write-Host "StatusDescription: " $_.Exception.Response.StatusDescription
        Write-Host "Response: " $_.Exception.Message
        Return $false
    }
}

function Remove-PASAccount ([string]$Authorization) {

	#begin
 
        $URI = "$PVWA_URL/PasswordVault/WebServices/PIMServices.svc/Accounts/$element"
        write-host "$URI"
        $headerParams = @{}
        $headerParams.Add("Authorization",$sessionID)


# Execution
    try {
        $getAccountResult = Invoke-RestMethod -Uri $URI -Method DELETE -ContentType "application/json" -Headers $headerParams -ErrorVariable getAccountResultErr
        return $getAccountResult
       
    }
    catch {
        Write-Host "StatusCode:" $_.Exception.Response.StatusCode.value__
        Write-Host "StatusDescription:" $_.Exception.Response.StatusDescription
        Write-Host "Response:" $_.Exception.Message
        return $false
    }
}

# Global Declaration
$PVWA_URL = "https://pvwaabc_url.com"

# Execute Logon
$sessionID = PASREST-Logon

# Error Handling for Logon
if ($sessionID -eq $false) {Write-Host "[ERROR] There was an error logging into the Vault." -ForegroundColor Red; break}
else {Write-Host "[INFO] Logon completed successfully." -ForegroundColor Green}

# Execute Delete Accounts

$getAccountResult = Remove-PASAccount -Authorization $sessionID
if ($getAccountResult -eq $false) {Write-Host "[ERROR] There was an error remove the account from the Vault or account is not there."-ForegroundColor Red; break}
else {"Account deleted sucessfully from vault" }

# Execute Logoff
$logoffResult = PASREST-Logoff -Authorization $sessionID
if ($logoffResult -eq $true) {Write-Host "[INFO] Logoff completed successfully." -ForegroundColor Green}
else {Write-Host "[ERROR] Logoff was not completed successfully.  Please logout manually using Authorization token:" $sessionID -ForegroundColor Red}
}
}