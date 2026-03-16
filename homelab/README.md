# Homelab

Eigen lab projecten gebouwd op fysieke hardware en virtuele machines. Alles is gedocumenteerd en beschikbaar als referentie.

---

## RPi Netwerk Monitor

Complete netwerk monitoring en beveiligingsserver gebouwd op een Raspberry Pi 4. Het systeem draait 24/7 en monitort het hele thuisnetwerk.

**Wat het doet:**
- Pi-hole blokkeert 415.000+ advertentie en malware domeinen voor alle apparaten tegelijk
- Grafana dashboard met realtime data over CPU, temperatuur, netwerkverkeer en alle apparaten
- Suricata IDS analyseert elk pakketje met 49.000+ aanvalspatronen — zelfde software als banken gebruiken
- Versleuteld DNS via Unbound zodat de provider niet kan meekijken
- Automatische Discord meldingen bij problemen, dagelijkse samenvattingen en nachtelijke backups
- Tailscale VPN voor toegang van overal ter wereld

**Veiligheidsscore: van 2/10 naar 9/10**

![Dashboard](./rpi-netwerk-monitor/screenshots/dashboard.png)

[Bekijk project →](./rpi-netwerk-monitor)

---

## Terminal Setup

Persoonlijke PowerShell 7 terminal met Oh My Posh, FastFetch en custom rood thema. Gesynchroniseerd met WSL2 voor een consistente werkomgeving op Windows en Linux.

![Terminal Setup](./terminal-setup/screenshots/preview.png)

[Bekijk project →](./terminal-setup)

---

## WSL2 - Ubuntu

Ubuntu WSL2 setup gesynchroniseerd met de Windows terminal. Zelfde dotfiles en configuratie op zowel Windows als Linux.

![WSL2 Setup](./wsl/screenshots/preview.png)

[Bekijk project →](./wsl)

---

## SSH Config

SSH key authenticatie en config voor meerdere servers zonder wachtwoord. Inclusief uitleg over het aanmaken van keys en het beheren van de config file.

![SSH Setup](./ssh/screenshots/preview.png)

[Bekijk project →](./ssh)
