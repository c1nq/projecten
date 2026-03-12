#Requires -RunAsAdministrator
<#
.SYNOPSIS
    System Health Check - c1nq
.DESCRIPTION
    Automatische gezondheidscontrole van Windows systemen.
    Controleert CPU, RAM, schijf, services en netwerk.
#>

$LogFile = "$PSScriptRoot\health-check.log"
$ReportFile = "$PSScriptRoot\health-report-$(Get-Date -Format 'yyyyMMdd-HHmmss').html"

function Write-Log {
    param($Message, $Level = "INFO")
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logEntry = "[$timestamp] [$Level] $Message"
    Add-Content -Path $LogFile -Value $logEntry
}

function Get-CPUHealth {
    $cpu = Get-WmiObject Win32_Processor
    $load = (Get-WmiObject Win32_Processor).LoadPercentage
    $status = if ($load -gt 90) { "KRITIEK" } elseif ($load -gt 70) { "WAARSCHUWING" } else { "OK" }
    
    [PSCustomObject]@{
        Component = "CPU"
        Name      = $cpu.Name
        Load      = "$load%"
        Status    = $status
    }
}

function Get-RAMHealth {
    $os = Get-WmiObject Win32_OperatingSystem
    $total = [math]::Round($os.TotalVisibleMemorySize / 1MB, 2)
    $free = [math]::Round($os.FreePhysicalMemory / 1MB, 2)
    $used = [math]::Round($total - $free, 2)
    $pct = [math]::Round(($used / $total) * 100, 0)
    $status = if ($pct -gt 90) { "KRITIEK" } elseif ($pct -gt 75) { "WAARSCHUWING" } else { "OK" }

    [PSCustomObject]@{
        Component = "RAM"
        Total     = "$total GB"
        Used      = "$used GB"
        Free      = "$free GB"
        Usage     = "$pct%"
        Status    = $status
    }
}

function Get-DiskHealth {
    $disks = Get-WmiObject Win32_LogicalDisk -Filter "DriveType=3"
    $results = foreach ($disk in $disks) {
        $total = [math]::Round($disk.Size / 1GB, 2)
        $free = [math]::Round($disk.FreeSpace / 1GB, 2)
        $used = [math]::Round($total - $free, 2)
        $pct = [math]::Round(($used / $total) * 100, 0)
        $status = if ($pct -gt 90) { "KRITIEK" } elseif ($pct -gt 75) { "WAARSCHUWING" } else { "OK" }

        [PSCustomObject]@{
            Drive  = $disk.DeviceID
            Total  = "$total GB"
            Used   = "$used GB"
            Free   = "$free GB"
            Usage  = "$pct%"
            Status = $status
        }
    }
    $results
}

function Get-ServiceHealth {
    $criticalServices = @("wuauserv", "WinDefend", "EventLog", "Dnscache", "LanmanServer")
    $results = foreach ($svc in $criticalServices) {
        $service = Get-Service -Name $svc -ErrorAction SilentlyContinue
        if ($service) {
            [PSCustomObject]@{
                Service = $service.DisplayName
                Status  = $service.Status
                Health  = if ($service.Status -eq "Running") { "OK" } else { "KRITIEK" }
            }
        }
    }
    $results
}

function Get-NetworkHealth {
    $adapters = Get-NetAdapter | Where-Object { $_.Status -eq "Up" }
    $results = foreach ($adapter in $adapters) {
        $ip = (Get-NetIPAddress -InterfaceIndex $adapter.InterfaceIndex -AddressFamily IPv4 -ErrorAction SilentlyContinue).IPAddress
        [PSCustomObject]@{
            Adapter = $adapter.Name
            Status  = $adapter.Status
            IP      = $ip
            Speed   = $adapter.LinkSpeed
            Health  = "OK"
        }
    }
    $results
}

function Show-HealthReport {
    Clear-Host
    Write-Host "=================================" -ForegroundColor Red
    Write-Host "   c1nq - System Health Check    " -ForegroundColor Red
    Write-Host "   $(Get-Date -Format 'dd-MM-yyyy HH:mm:ss')    " -ForegroundColor Red
    Write-Host "   Computer: $env:COMPUTERNAME    " -ForegroundColor Red
    Write-Host "=================================" -ForegroundColor Red
    Write-Host ""

    # CPU
    Write-Host "[ CPU ]" -ForegroundColor Red
    $cpu = Get-CPUHealth
    $color = if ($cpu.Status -eq "OK") { "Green" } elseif ($cpu.Status -eq "WAARSCHUWING") { "Yellow" } else { "Red" }
    Write-Host "  Status: $($cpu.Status) | Load: $($cpu.Load)" -ForegroundColor $color
    Write-Host "  $($cpu.Name)" -ForegroundColor Gray
    Write-Host ""

    # RAM
    Write-Host "[ RAM ]" -ForegroundColor Red
    $ram = Get-RAMHealth
    $color = if ($ram.Status -eq "OK") { "Green" } elseif ($ram.Status -eq "WAARSCHUWING") { "Yellow" } else { "Red" }
    Write-Host "  Status: $($ram.Status) | Gebruik: $($ram.Usage) | Vrij: $($ram.Free)" -ForegroundColor $color
    Write-Host ""

    # Schijven
    Write-Host "[ SCHIJVEN ]" -ForegroundColor Red
    $disks = Get-DiskHealth
    foreach ($disk in $disks) {
        $color = if ($disk.Status -eq "OK") { "Green" } elseif ($disk.Status -eq "WAARSCHUWING") { "Yellow" } else { "Red" }
        Write-Host "  $($disk.Drive) - Status: $($disk.Status) | Gebruik: $($disk.Usage) | Vrij: $($disk.Free)" -ForegroundColor $color
    }
    Write-Host ""

    # Services
    Write-Host "[ SERVICES ]" -ForegroundColor Red
    $services = Get-ServiceHealth
    foreach ($svc in $services) {
        $color = if ($svc.Health -eq "OK") { "Green" } else { "Red" }
        Write-Host "  $($svc.Service): $($svc.Status)" -ForegroundColor $color
    }
    Write-Host ""

    # Netwerk
    Write-Host "[ NETWERK ]" -ForegroundColor Red
    $network = Get-NetworkHealth
    foreach ($net in $network) {
        Write-Host "  $($net.Adapter) | IP: $($net.IP) | Speed: $($net.Speed)" -ForegroundColor Green
    }
    Write-Host ""

    Write-Log "Health check uitgevoerd op $env:COMPUTERNAME door $env:USERNAME"
    Write-Host "Log opgeslagen: $LogFile" -ForegroundColor Gray
}

# Run
Show-HealthReport
Read-Host "`nDruk Enter om af te sluiten"
