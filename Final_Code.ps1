#$snow = (Get-Content "C:\Test\example_2.JSON" | ConvertFrom-Json)
$host1 = "1.1.1.1"
#$fdqn = " abc "
#$name = "satya chhotu"
$var = $host1
Write-Host "`nBelow are the Retired server found from SNOW :- `n" -ForegroundColor Yellow
Write-Host "$var`n"
# Passing the JSON value one by one to the get account script.
foreach ($element2 in $var) {
if ($element2 -eq "") {
write-host "Null value as per JSON response"
}
else {
Write-Host "Passing the retired server **" $element2 "** for getting accounts form PVWA" -ForegroundColor Green
# Get account script start execution.
$var = (& '.\Get-Accouts.ps1' -PVWAURL https://comp01a.cyber-ark-demo.local/PasswordVault -List -Address "$element2" -SortBy Address | Where {$_.address -eq "$element2"})
$idr = $var.id
Write-Host "Below are the Account id fount from PVWA :- `n $idr" -ForegroundColor Yellow

foreach ($element1 in $idr) {

Write-Host "Passing the id for account deletion :- $element1" -ForegroundColor Green
# start deleting the account from Cyberark
    function PASREST-Logon {
    # Declaration
    $webServicesLogon = "$PVWA_URL/PasswordVault/WebServices/auth/Cyberark/CyberArkAuthenticationService.svc/Logon"
    # Authentication
    $bodyParams = @{username = "Administrator"; password = "Cyberark1"} | ConvertTo-JSON
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
 
        $URI = "$PVWA_URL/PasswordVault/WebServices/PIMServices.svc/Accounts/$element1"
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
$PVWA_URL = "https://comp01a.cyber-ark-demo.local"
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
else {Write-Host "[ERROR] Logoff was not completed successfully.  Please logout manually using Authorization token:" $sessionID -ForegroundColor Red}}
}
}

