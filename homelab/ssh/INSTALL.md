# Installatie handleiding - SSH Config

## Vereisten
- PowerShell 7
- Git for Windows (inclusief SSH)

## Stap 1 - SSH key aanmaken
ssh-keygen -t ed25519 -C "c1nqict@gmail.com"
Druk 3x Enter voor standaard instellingen.

## Stap 2 - SSH key toevoegen aan GitHub
type "C:\Users\c1nqc\.ssh\id_ed25519.pub"
Kopieer de output en voeg toe via:
github.com > Settings > SSH and GPG keys > New SSH key

## Stap 3 - SSH config instellen
Kopieer config naar ~/.ssh/config

## Stap 4 - SSH key kopiëren naar servers
type "C:\Users\c1nqc\.ssh\id_ed25519.pub" | ssh -p 2222 sem@127.0.0.1 "mkdir -p ~/.ssh && cat >> ~/.ssh/authorized_keys && chmod 600 ~/.ssh/authorized_keys"
type "C:\Users\c1nqc\.ssh\id_ed25519.pub" | ssh -p 2223 sem@127.0.0.1 "mkdir -p ~/.ssh && cat >> ~/.ssh/authorized_keys && chmod 600 ~/.ssh/authorized_keys"
type "C:\Users\c1nqc\.ssh\id_ed25519.pub" | ssh -p 2224 sem@127.0.0.1 "mkdir -p ~/.ssh && cat >> ~/.ssh/authorized_keys && chmod 600 ~/.ssh/authorized_keys"

## Stap 5 - Testen
ssh zabbix-server
ssh zabbix-client
ssh zabbix-switch

## Resultaat
- Inloggen zonder wachtwoord op alle servers
- Korte aliassen via SSH config
