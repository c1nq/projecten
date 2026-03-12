#Requires -RunAsAdministrator
<#
.SYNOPSIS
    User Management Script - c1nq
.DESCRIPTION
    Aanmaken, beheren en rapporteren van gebruikers op Windows systemen.
#>

$LogFile = "$PSScriptRoot\user-management.log"

function Write-Log {
    param($Message, $Level = "INFO")
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logEntry = "[$timestamp] [$Level] $Message"
    Add-Content -Path $LogFile -Value $logEntry
    switch ($Level) {
        "INFO"    { Write-Host $logEntry -ForegroundColor Green }
        "WARNING" { Write-Host $logEntry -ForegroundColor Yellow }
        "ERROR"   { Write-Host $logEntry -ForegroundColor Red }
    }
}

function Show-Menu {
    Clear-Host
    Write-Host "=================================" -ForegroundColor Red
    Write-Host "   c1nq - User Management Tool   " -ForegroundColor Red
    Write-Host "=================================" -ForegroundColor Red
    Write-Host ""
    Write-Host "  [1] Gebruiker aanmaken" -ForegroundColor White
    Write-Host "  [2] Gebruiker verwijderen" -ForegroundColor White
    Write-Host "  [3] Gebruiker toevoegen aan groep" -ForegroundColor White
    Write-Host "  [4] Wachtwoord resetten" -ForegroundColor White
    Write-Host "  [5] Gebruikersrapport genereren" -ForegroundColor White
    Write-Host "  [6] Alle gebruikers tonen" -ForegroundColor White
    Write-Host "  [0] Afsluiten" -ForegroundColor White
    Write-Host ""
}

function New-LocalUserAccount {
    Write-Host "`n=== Gebruiker Aanmaken ===" -ForegroundColor Red
    
    $username = Read-Host "Gebruikersnaam"
    if (Get-LocalUser -Name $username -ErrorAction SilentlyContinue) {
        Write-Log "Gebruiker $username bestaat al!" "ERROR"
        return
    }

    $fullname = Read-Host "Volledige naam"
    $description = Read-Host "Omschrijving"
    $password = Read-Host "Wachtwoord" -AsSecureString
    
    $expireChoice = Read-Host "Verloopdatum instellen? (j/n)"
    $expireDate = $null
    if ($expireChoice -eq "j") {
        $expireDateStr = Read-Host "Verloopdatum (dd-MM-yyyy)"
        $expireDate = [datetime]::ParseExact($expireDateStr, "dd-MM-yyyy", $null)
    }

    $groupChoice = Read-Host "Toevoegen aan groep? (Administrators/Users/beide)"

    try {
        $userParams = @{
            Name        = $username
            FullName    = $fullname
            Description = $description
            Password    = $password
        }
        if ($expireDate) { $userParams.AccountExpires = $expireDate }

        New-LocalUser @userParams
        
        switch ($groupChoice.ToLower()) {
            "administrators" { Add-LocalGroupMember -Group "Administrators" -Member $username }
            "users"          { Add-LocalGroupMember -Group "Users" -Member $username }
            "beide"          { 
                Add-LocalGroupMember -Group "Administrators" -Member $username
                Add-LocalGroupMember -Group "Users" -Member $username 
            }
        }

        Write-Log "Gebruiker '$username' ($fullname) aangemaakt door $env:USERNAME" "INFO"
        Write-Host "`nGebruiker succesvol aangemaakt!" -ForegroundColor Green
    }
    catch {
        Write-Log "Fout bij aanmaken gebruiker: $_" "ERROR"
    }
}

function Remove-LocalUserAccount {
    Write-Host "`n=== Gebruiker Verwijderen ===" -ForegroundColor Red
    $username = Read-Host "Gebruikersnaam"
    
    if (-not (Get-LocalUser -Name $username -ErrorAction SilentlyContinue)) {
        Write-Log "Gebruiker $username bestaat niet!" "ERROR"
        return
    }

    $confirm = Read-Host "Weet je zeker dat je $username wilt verwijderen? (j/n)"
    if ($confirm -eq "j") {
        Remove-LocalUser -Name $username
        Write-Log "Gebruiker '$username' verwijderd door $env:USERNAME" "WARNING"
        Write-Host "Gebruiker verwijderd!" -ForegroundColor Green
    }
}

function Add-UserToGroup {
    Write-Host "`n=== Toevoegen aan Groep ===" -ForegroundColor Red
    $username = Read-Host "Gebruikersnaam"
    $group = Read-Host "Groep (Administrators/Users/Remote Desktop Users)"
    
    try {
        Add-LocalGroupMember -Group $group -Member $username
        Write-Log "Gebruiker '$username' toegevoegd aan groep '$group' door $env:USERNAME" "INFO"
        Write-Host "Succesvol toegevoegd!" -ForegroundColor Green
    }
    catch {
        Write-Log "Fout: $_" "ERROR"
    }
}

function Reset-UserPassword {
    Write-Host "`n=== Wachtwoord Resetten ===" -ForegroundColor Red
    $username = Read-Host "Gebruikersnaam"
    $newPassword = Read-Host "Nieuw wachtwoord" -AsSecureString
    
    try {
        Set-LocalUser -Name $username -Password $newPassword
        Write-Log "Wachtwoord van '$username' gereset door $env:USERNAME" "WARNING"
        Write-Host "Wachtwoord succesvol gereset!" -ForegroundColor Green
    }
    catch {
        Write-Log "Fout: $_" "ERROR"
    }
}

function Get-UserReport {
    Write-Host "`n=== Gebruikersrapport ===" -ForegroundColor Red
    $reportFile = "$PSScriptRoot\user-report-$(Get-Date -Format 'yyyyMMdd-HHmmss').csv"
    
    Get-LocalUser | Select-Object Name, FullName, Enabled, LastLogon, PasswordLastSet, AccountExpires, Description |
        Export-Csv -Path $reportFile -NoTypeInformation -Encoding UTF8
    
    Write-Log "Rapport gegenereerd: $reportFile" "INFO"
    Write-Host "Rapport opgeslagen: $reportFile" -ForegroundColor Green
    
    Get-LocalUser | Select-Object Name, FullName, Enabled | Format-Table -AutoSize
}

function Show-AllUsers {
    Write-Host "`n=== Alle Gebruikers ===" -ForegroundColor Red
    Get-LocalUser | Select-Object Name, FullName, Enabled, LastLogon | Format-Table -AutoSize
}

# Main loop
Write-Log "User Management Tool gestart door $env:USERNAME" "INFO"

do {
    Show-Menu
    $choice = Read-Host "Keuze"
    
    switch ($choice) {
        "1" { New-LocalUserAccount }
        "2" { Remove-LocalUserAccount }
        "3" { Add-UserToGroup }
        "4" { Reset-UserPassword }
        "5" { Get-UserReport }
        "6" { Show-AllUsers }
        "0" { Write-Log "User Management Tool afgesloten" "INFO"; break }
        default { Write-Host "Ongeldige keuze!" -ForegroundColor Red }
    }
    
    if ($choice -ne "0") { Read-Host "`nDruk Enter om door te gaan" }

} while ($choice -ne "0")
