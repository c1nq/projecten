# Installatie handleiding - Terminal Setup

## Vereisten
- Windows 11
- Windows Terminal (winget install Microsoft.WindowsTerminal)
- PowerShell 7 (winget install Microsoft.PowerShell)

## Stap 1 - Oh My Posh installeren
winget install XP8K0HKJFRXGCK

## Stap 2 - Nerd Font installeren
oh-my-posh font install
Kies: MesloLGM Nerd Font
Stel in via Windows Terminal Settings > Appearance > Font

## Stap 3 - Oh My Posh thema instellen
Kopieer c1nq.omp.json naar ~/.c1nq.omp.json

## Stap 4 - FastFetch installeren
winget install fastfetch-cli.fastfetch
Kopieer fastfetch.jsonc naar ~/.config/fastfetch/config.jsonc

## Stap 5 - PowerShell profiel instellen
Kopieer powershell_profile.ps1 naar:
C:\Users\<gebruiker>\Documents\PowerShell\Microsoft.PowerShell_profile.ps1

## Stap 6 - Windows Terminal kleuren instellen
Voer het kleurenscript uit via PowerShell om het rode thema toe te passen.

## Resultaat
- C1NQ ASCII art bij opstarten
- Rode kleurenthema met glaseffect
- Titelbar met batterij, IP, uptime en tijd
- Autocomplete en syntax highlighting
