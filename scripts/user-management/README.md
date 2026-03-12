# User Management Tool

PowerShell script voor het beheren van lokale Windows gebruikers.

## Features
- Gebruiker aanmaken met wachtwoord en groep
- Gebruiker verwijderen
- Gebruiker toevoegen aan groep
- Wachtwoord resetten
- Gebruikersrapport genereren als CSV
- Logging van alle acties

## Gebruik
Uitvoeren als Administrator:
```powershell
.\New-User.ps1
```

## Logging
Alle acties worden gelogd in `user-management.log`

## Rapport
Optie 5 genereert een CSV rapport van alle gebruikers
