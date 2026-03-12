# System Health Check

PowerShell script voor automatische gezondheidscontrole van Windows systemen.

## Features
- CPU gebruik en status
- RAM gebruik en vrije ruimte
- Schijf gebruik per drive
- Status van kritieke Windows services
- Netwerk adapters en IP adressen
- Logging van alle checks

## Gebruik
Uitvoeren als Administrator:
```powershell
.\Get-SystemHealth.ps1
```

## Status indicators
- OK - Groen
- WAARSCHUWING - Geel (>75%)
- KRITIEK - Rood (>90%)
