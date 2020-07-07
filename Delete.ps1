function PASREST-Logon {

    # Declaration
    $webServicesLogon = "$PVWA_URL/PasswordVault/WebServices/auth/Cyberark/CyberArkAuthenticationService.svc/Logon"

    # Authentication
    $bodyParams = @{username = "username123"; password = "password123"} | ConvertTo-JSON

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
        $URI = "$PVWA_URL/PasswordVault/api/Accounts/$AccountID"

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
$PVWA_URL = "https://abc.url.com/"
# Execute Logon
$sessionID = PASREST-Logon

# Error Handling for Logon
if ($sessionID -eq $false) {Write-Host "[ERROR] There was an error logging into the Vault." -ForegroundColor Red; break}
else {Write-Host "[INFO] Logon completed successfully." -ForegroundColor Green}

# Execute Delete Accounts
$getAccountResult = Remove-PASAccount -Authorization $sessionID
if ($getAccountResult -eq $false) {Write-Host "[ERROR] There was an error remove the account from the Vault or account is not there."-ForegroundColor Red; break}
else {"Account deleted sucessfully from vault" } ($AccountID)

# Execute Logoff
$logoffResult = PASREST-Logoff -Authorization $sessionID
if ($logoffResult -eq $true) {Write-Host "[INFO] Logoff completed successfully." -ForegroundColor Green}
else {Write-Host "[ERROR] Logoff was not completed successfully.  Please logout manually using Authorization token:" $sessionID -ForegroundColor Red}