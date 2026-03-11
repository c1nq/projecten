$env:POWERSHELL_UPDATECHECK = "Off"
oh-my-posh init pwsh --config "$env:USERPROFILE\.c1nq.omp.json" | Invoke-Expression

# PSReadLine
Set-PSReadLineOption -PredictionSource History
Set-PSReadLineOption -PredictionViewStyle ListView
Set-PSReadLineOption -EditMode Windows
Set-PSReadLineOption -Colors @{
    Command   = '#FF0000'
    Parameter = '#FF6B6B'
    String    = '#FF8C00'
    Error     = '#8B0000'
}

# Aliassen
Set-Alias ll Get-ChildItem
function gs { git status }
function ga { git add . }
function gc { param($m) git commit -m $m }
function up { cd .. }
function home { cd ~ }
function reload { . $PROFILE }
function sysinfo { Get-ComputerInfo | Select-Object CsName, OsName, TotalPhysicalMemory }

# Welkomst ASCII
Write-Host @"
  ██████╗ ██╗███╗   ██╗ ██████╗ 
 ██╔════╝███║████╗  ██║██╔═══██╗
 ██║     ╚██║██╔██╗ ██║██║   ██║
 ██║      ██║██║╚██╗██║██║▄▄ ██║
 ╚██████╗ ██║██║ ╚████║╚██████╔╝
  ╚═════╝ ╚═╝╚═╝  ╚═══╝ ╚══▀▀═╝ 
"@ -ForegroundColor Red

# FastFetch
if (Get-Command fastfetch -ErrorAction SilentlyContinue) { fastfetch }
elseif (Get-Command neofetch -ErrorAction SilentlyContinue) { neofetch --colors 1 1 1 1 1 1 }

# Titelbar
$Global:_ompPrompt = $function:prompt
function prompt {
    $time = Get-Date -Format "HH:mm"
    $battery = (Get-WmiObject Win32_Battery).EstimatedChargeRemaining
    $uptime = (Get-Date) - (gcim Win32_OperatingSystem).LastBootUpTime
    $uptimeStr = "{0}h{1}m" -f [int]$uptime.TotalHours, $uptime.Minutes
    $ip = (Get-NetIPAddress -AddressFamily IPv4 | Where-Object { $_.IPAddress -notlike "127.*" -and $_.IPAddress -notlike "169.*" } | Select-Object -First 1).IPAddress
    $host.UI.RawUI.WindowTitle = "c1nq  |  $battery%  |  $ip  |  up $uptimeStr  |  $time"
    & $Global:_ompPrompt
}
