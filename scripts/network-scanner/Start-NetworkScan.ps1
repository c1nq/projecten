#Requires -RunAsAdministrator
<#
.SYNOPSIS
    Network Scanner - c1nq
.DESCRIPTION
    Scant het netwerk razendsnel via parallelle pings.
#>

$LogFile = "$PSScriptRoot\network-scan.log"

function Write-Log {
    param($Message)
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    Add-Content -Path $LogFile -Value "[$timestamp] $Message"
}

function Start-NetworkScan {
    param($Subnet)

    Clear-Host
    Write-Host "=================================" -ForegroundColor Red
    Write-Host "    c1nq - Network Scanner       " -ForegroundColor Red
    Write-Host "    Subnet: $Subnet.0/24         " -ForegroundColor Red
    Write-Host "    $(Get-Date -Format 'dd-MM-yyyy HH:mm:ss')" -ForegroundColor Red
    Write-Host "=================================" -ForegroundColor Red
    Write-Host ""
    Write-Host "Scannen... even geduld" -ForegroundColor Yellow
    Write-Host ""

    $IPs = 1..254 | ForEach-Object { "$Subnet.$_" }

    $results = $IPs | ForEach-Object -ThrottleLimit 100 -Parallel {
        $ping = New-Object System.Net.NetworkInformation.Ping
        try {
            $reply = $ping.Send($_, 500)
            if ($reply.Status -eq "Success") {
                [PSCustomObject]@{
                    IP      = $_
                    Ping    = "$($reply.RoundtripTime)ms"
                }
            }
        } catch {}
    }

    $online = $results | Where-Object { $_ } | Sort-Object { [version]$_.IP }

    $enriched = foreach ($r in $online) {
        $hostname = try { [System.Net.Dns]::GetHostEntry($r.IP).HostName } catch { "Onbekend" }
        $mac = ""
        $arpResult = arp -a $r.IP 2>$null
        if ($arpResult) {
            $mac = ($arpResult | Select-String "([0-9a-f]{2}[-]){5}[0-9a-f]{2}").Matches.Value | Select-Object -First 1
        }
        if (-not $mac) { $mac = "Onbekend" }

        [PSCustomObject]@{
            IP       = $r.IP
            Hostname = $hostname
            MAC      = $mac
            Ping     = $r.Ping
        }
    }

    Write-Host "=================================" -ForegroundColor Red
    Write-Host "  Gevonden: $($enriched.Count) apparaten" -ForegroundColor Green
    Write-Host "=================================" -ForegroundColor Red
    Write-Host ""
    $enriched | Format-Table -AutoSize

    $reportFile = "$PSScriptRoot\scan-$(Get-Date -Format 'yyyyMMdd-HHmmss').csv"
    $enriched | Export-Csv -Path $reportFile -NoTypeInformation -Encoding UTF8
    Write-Log "Scan op $Subnet.0/24 — $($enriched.Count) apparaten gevonden"
    Write-Host "Rapport opgeslagen: $reportFile" -ForegroundColor Gray
}

function Get-LocalSubnet {
    $ip = (Get-NetIPAddress -AddressFamily IPv4 | Where-Object {
        $_.IPAddress -notlike "127.*" -and $_.IPAddress -notlike "169.*" -and $_.PrefixOrigin -eq "Dhcp"
    } | Select-Object -First 1).IPAddress
    if (-not $ip) {
        $ip = (Get-NetIPAddress -AddressFamily IPv4 | Where-Object {
            $_.IPAddress -notlike "127.*" -and $_.IPAddress -notlike "169.*"
        } | Select-Object -First 1).IPAddress
    }
    return $ip -replace "\.\d+$", "", $ip
}

function Show-Menu {
    Clear-Host
    Write-Host "=================================" -ForegroundColor Red
    Write-Host "    c1nq - Network Scanner       " -ForegroundColor Red
    Write-Host "=================================" -ForegroundColor Red
    Write-Host ""
    Write-Host "  [1] Automatisch scannen" -ForegroundColor White
    Write-Host "  [2] Handmatig subnet invoeren" -ForegroundColor White
    Write-Host "  [3] Vorige scans bekijken" -ForegroundColor White
    Write-Host "  [0] Afsluiten" -ForegroundColor White
    Write-Host ""
}

Write-Log "Network Scanner gestart door $env:USERNAME"

do {
    Show-Menu
    $choice = Read-Host "Keuze"
    switch ($choice) {
        "1" {
            $subnet = Get-LocalSubnet
            Write-Host "Subnet: $subnet.0/24" -ForegroundColor Yellow
            Start-NetworkScan -Subnet $subnet
        }
        "2" {
            $subnet = Read-Host "Subnet (bijv. 192.168.1)"
            Start-NetworkScan -Subnet $subnet
        }
        "3" {
            Get-ChildItem -Path $PSScriptRoot -Filter "scan-*.csv" | Select-Object Name, CreationTime | Format-Table -AutoSize
        }
        "0" { Write-Log "Network Scanner afgesloten"; break }
    }
    if ($choice -ne "0") { Read-Host "`nDruk Enter om door te gaan" }
} while ($choice -ne "0")
