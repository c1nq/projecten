#!/bin/bash
WEBHOOK="YOUR_DISCORD_WEBHOOK_URL"
CPU=$(top -bn1 | grep "Cpu(s)" | awk '{print $2}' | cut -d. -f1)
RAM=$(free | grep Mem | awk '{printf "%.0f", $3/$2*100}')
TEMP=$(cat /sys/class/thermal/thermal_zone0/temp | awk '{printf "%.1f", $1/1000}')
DISK=$(df / | tail -1 | awk '{print $5}' | tr -d '%')
UPTIME=$(uptime -p | sed 's/up //')
DEVICES=$(cat /var/lib/node_exporter/textfile_collector/devices.prom 2>/dev/null | grep "lan_devices_total" | grep -v "#" | awk '{print $2}' | head -1)
DATE=$(date '+%A %d %B %Y')
TIME=$(date '+%H:%M')
PIHOLE_QUERIES=$(curl -s "http://localhost/api/stats/summary" 2>/dev/null | python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('queries',{}).get('total',0))" 2>/dev/null || echo "?")
PIHOLE_BLOCKED=$(curl -s "http://localhost/api/stats/summary" 2>/dev/null | python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('queries',{}).get('blocked',0))" 2>/dev/null || echo "?")
PIHOLE_PERCENT=$(curl -s "http://localhost/api/stats/summary" 2>/dev/null | python3 -c "import sys,json; d=json.load(sys.stdin); print(round(d.get('queries',{}).get('percent_blocked',0),1))" 2>/dev/null || echo "?")
if [ "$CPU" -gt 85 ] 2>/dev/null; then CPU_ICON="🔴"; elif [ "$CPU" -gt 60 ] 2>/dev/null; then CPU_ICON="🟡"; else CPU_ICON="🟢"; fi
if [ "$DISK" -gt 85 ] 2>/dev/null; then DISK_ICON="🔴"; elif [ "$DISK" -gt 70 ] 2>/dev/null; then DISK_ICON="🟡"; else DISK_ICON="🟢"; fi
curl -s -X POST "$WEBHOOK" -H "Content-Type: application/json" -d "{\"embeds\":[{\"title\":\"📊 RPi Dagelijkse Samenvatting\",\"description\":\"**$DATE — $TIME**\",\"color\":3066993,\"fields\":[{\"name\":\"🖥️ Systeem\",\"value\":\"${CPU_ICON} CPU: **${CPU}%**\\n💾 RAM: **${RAM}%**\\n🌡️ Temp: **${TEMP}°C**\\n${DISK_ICON} Schijf: **${DISK}%**\",\"inline\":true},{\"name\":\"🌐 Netwerk\",\"value\":\"📡 Devices: **${DEVICES:-?}**\\n⏱️ Uptime: **${UPTIME}**\",\"inline\":true},{\"name\":\"🛡️ Pi-hole\",\"value\":\"🔍 Queries: **${PIHOLE_QUERIES}**\\n🚫 Geblokkeerd: **${PIHOLE_BLOCKED}**\\n📊 Percentage: **${PIHOLE_PERCENT}%**\",\"inline\":true}],\"footer\":{\"text\":\"RPi Monitor • Sem Enkelmans\"},\"timestamp\":\"$(date -u +%Y-%m-%dT%H:%M:%SZ)\"}]}" > /dev/null
echo "[$(date)] Dagelijkse samenvatting verstuurd"
