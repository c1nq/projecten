#!/bin/bash
WEBHOOK="YOUR_DISCORD_WEBHOOK_URL"
DATE=$(date '+%d-%m-%Y %H:%M')
CONTAINERS_UP=$(sudo docker ps --format "{{.Names}}" | wc -l)
TOTAL_BANNED=$(sudo fail2ban-client status sshd 2>/dev/null | grep "Total banned" | awk '{print $NF}' || echo "0")
BANNED=$(sudo fail2ban-client status sshd 2>/dev/null | grep "Banned IP list" | cut -d: -f2 | xargs || echo "Geen")
NEW_DEVICES=$(grep "NIEUW DEVICE" /var/log/device-scanner.log 2>/dev/null | wc -l)
DISK=$(df / | tail -1 | awk '{print $5}' | tr -d '%')
SURICATA_TOTAL=$(sudo wc -l < /var/log/suricata/fast.log 2>/dev/null || echo "0")
SURICATA_HIGH=$(sudo grep "Priority: 1\|Priority: 2" /var/log/suricata/fast.log 2>/dev/null | wc -l || echo "0")
if [ "$DISK" -gt 80 ] 2>/dev/null; then DISK_MSG="⚠️ Schijf ${DISK}% vol!"; else DISK_MSG="✅ Schijf: ${DISK}%"; fi

CONTAINER_LIST=$(sudo docker ps -a --format "{{.Names}} {{.Status}}" | while read NAME STATUS; do
  if echo "$STATUS" | grep -q "Up"; then echo "🟢 $NAME"; else echo "🔴 $NAME gestopt"; fi
done | tr '\n' ', ' | sed 's/,$//')

python3 - <<PYEOF
import requests
data = {
  "embeds": [{
    "title": "📋 RPi Log Samenvatting",
    "description": f"**$DATE**",
    "color": 15844367,
    "fields": [
      {"name": "🐳 Containers ($CONTAINERS_UP actief)", "value": "$CONTAINER_LIST", "inline": False},
      {"name": "🔒 Fail2ban", "value": "Totaal geblokkeerd: **$TOTAL_BANNED**\nHuidige bans: **$BANNED**", "inline": True},
      {"name": "📡 Nieuwe Devices", "value": "**$NEW_DEVICES** gevonden", "inline": True},
      {"name": "🚨 Suricata IDS", "value": "Totaal alerts: **$SURICATA_TOTAL**\nHoge prioriteit: **$SURICATA_HIGH**", "inline": True},
      {"name": "💽 Opslag", "value": "$DISK_MSG", "inline": False}
    ],
    "footer": {"text": "RPi Monitor • Sem Enkelmans"}
  }]
}
r = requests.post("$WEBHOOK", json=data)
print(r.status_code)
PYEOF
echo "[$(date)] Log samenvatting verstuurd"
