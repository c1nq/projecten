#Requires -RunAsAdministrator
<#
.SYNOPSIS
    Backup Script - c1nq
.DESCRIPTION
    Automatisch backuppen van mappen met logging en rotatie.
#>

$LogFile = "$PSScriptRoot\backup.log"
$ConfigFile = "$PSScriptRoot\backup-config.json"

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

function Get-Config {
    if (Test-Path $ConfigFile) {
        return Get-Content $ConfigFile | ConvertFrom-Json
    }
    return $null
}

function New-BackupConfig {
    Write-Host "`n=== Backup Configuratie ===" -ForegroundColor Red
    $source = Read-Host "Bronmap (bijv. C:\Users\c1nqc\Documents)"
    $destination = Read-Host "Doelmap (bijv. D:\Backups)"
    $keepDays = Read-Host "Hoeveel dagen backups bewaren? (bijv. 7)"

    $config = @{
        Source      = $source
        Destination = $destination
        KeepDays    = [int]$keepDays
        CreatedAt   = (Get-Date -Format "yyyy-MM-dd HH:mm:ss")
    }

    $config | ConvertTo-Json | Set-Content $ConfigFile
    Write-Log "Configuratie opgeslagen" "INFO"
    return $config
}

function Start-Backup {
    param($Config)

    $timestamp = Get-Date -Format "yyyyMMdd-HHmmss"
    $backupFolder = Join-Path $Config.Destination "backup-$timestamp"

    Write-Log "Backup gestart van '$($Config.Source)' naar '$backupFolder'" "INFO"

    try {
        if (-not (Test-Path $Config.Source)) {
            Write-Log "Bronmap bestaat niet: $($Config.Source)" "ERROR"
            return
        }

        New-Item -Path $backupFolder -ItemType Directory -Force | Out-Null
        
        $files = Get-ChildItem -Path $Config.Source -Recurse
        $total = $files.Count
        $current = 0

        foreach ($file in $files) {
            $current++
            $pct = [math]::Round(($current / $total) * 100, 0)
            Write-Progress -Activity "Backup bezig..." -Status "$pct% - $($file.Name)" -PercentComplete $pct
            
            $dest = $file.FullName.Replace($Config.Source, $backupFolder)
            if ($file.PSIsContainer) {
                New-Item -Path $dest -ItemType Directory -Force | Out-Null
            } else {
                Copy-Item -Path $file.FullName -Destination $dest -Force
            }
        }

        Write-Progress -Completed -Activity "Backup klaar"
        Write-Log "Backup succesvol — $total bestanden gekopieerd naar '$backupFolder'" "INFO"

        # Oude backups verwijderen
        $cutoff = (Get-Date).AddDays(-$Config.KeepDays)
        $oldBackups = Get-ChildItem -Path $Config.Destination -Directory | Where-Object { $_.CreationTime -lt $cutoff }
        foreach ($old in $oldBackups) {
            Remove-Item -Path $old.FullName -Recurse -Force
            Write-Log "Oude backup verwijderd: $($old.Name)" "WARNING"
        }

    } catch {
        Write-Log "Fout tijdens backup: $_" "ERROR"
    }
}

function Show-Menu {
    Clear-Host
    Write-Host "=================================" -ForegroundColor Red
    Write-Host "      c1nq - Backup Script       " -ForegroundColor Red
    Write-Host "=================================" -ForegroundColor Red
    Write-Host ""
    Write-Host "  [1] Backup starten" -ForegroundColor White
    Write-Host "  [2] Configuratie aanpassen" -ForegroundColor White
    Write-Host "  [3] Backup log bekijken" -ForegroundColor White
    Write-Host "  [4] Bestaande backups tonen" -ForegroundColor White
    Write-Host "  [0] Afsluiten" -ForegroundColor White
    Write-Host ""
}

# Main
Write-Log "Backup script gestart door $env:USERNAME" "INFO"

do {
    Show-Menu
    $choice = Read-Host "Keuze"

    switch ($choice) {
        "1" {
            $config = Get-Config
            if (-not $config) {
                Write-Host "Geen configuratie gevonden, eerst instellen." -ForegroundColor Yellow
                $config = New-BackupConfig
            }
            Start-Backup -Config $config
        }
        "2" { New-BackupConfig }
        "3" { Get-Content $LogFile | Select-Object -Last 20 }
        "4" {
            $config = Get-Config
            if ($config) {
                Get-ChildItem -Path $config.Destination -Directory | Select-Object Name, CreationTime | Format-Table -AutoSize
            } else {
                Write-Host "Geen configuratie gevonden!" -ForegroundColor Red
            }
        }
        "0" { Write-Log "Backup script afgesloten" "INFO"; break }
    }

    if ($choice -ne "0") { Read-Host "`nDruk Enter om door te gaan" }

} while ($choice -ne "0")
