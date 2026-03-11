# Installatie handleiding - WSL2

## Stap 1 - WSL2 installeren
wsl --install

## Stap 2 - Oh My Posh installeren
sudo apt install -y unzip
curl -s https://ohmyposh.dev/install.sh | bash -s
export PATH=$PATH:/home/<gebruiker>/.local/bin

## Stap 3 - Thema instellen
Kopieer je .omp.json thema naar ~/.c1nq.omp.json

## Stap 4 - FastFetch installeren
sudo add-apt-repository ppa:zhangsongcui3371/fastfetch -y
sudo apt update && sudo apt install -y fastfetch
mkdir -p ~/.config/fastfetch
Kopieer je fastfetch config naar ~/.config/fastfetch/config.jsonc

## Stap 5 - Bashrc instellen
Voeg toe aan ~/.bashrc:
- PATH export
- oh-my-posh init
- ASCII art
- fastfetch
