# Installatie handleiding - WSL2

## Vereisten
- Windows 11
- Windows Terminal

## Stap 1 - WSL2 installeren
wsl --install

## Stap 2 - Basis tools installeren
sudo apt update && sudo apt upgrade -y
sudo apt install -y git curl wget vim net-tools htop tree unzip figlet toilet

## Stap 3 - Oh My Posh installeren
curl -s https://ohmyposh.dev/install.sh | bash -s
export PATH=$PATH:/home/<gebruiker>/.local/bin
Kopieer je .omp.json thema naar ~/.c1nq.omp.json

## Stap 4 - FastFetch installeren
sudo add-apt-repository ppa:zhangsongcui3371/fastfetch -y
sudo apt update && sudo apt install -y fastfetch
mkdir -p ~/.config/fastfetch
Kopieer je fastfetch config naar ~/.config/fastfetch/config.jsonc

## Stap 5 - Bashrc instellen
Inhoud van ~/.bashrc:
export PATH=$PATH:/home/<gebruiker>/.local/bin
eval "$(oh-my-posh init bash --config ~/.c1nq.omp.json)"
cd ~
echo + ASCII art regels
fastfetch

## Resultaat
- ASCII art met gradient bij opstarten
- Oh My Posh thema
- FastFetch systeeminfo
