#!/bin/bash
WEBHOOK="YOUR_DISCORD_WEBHOOK_URL"
LOG="/var/log/suricata/fast.log"
LAST_RUN="/tmp/suricata_last_run"

touch "$LAST_RUN"
NEW_ALERTS=$(find "$LOG" -newer "$LAST_RUN" -exec tail -50 {} \; 2>/dev/null | grep "Priority: 1\|Priority: 2" | head -10)
touch "$LAST_RUN"

if [ -n "$NEW_ALERTS" ]; then
  COUNT=$(echo "$NEW_ALERTS" | wc -l)
  PREVIEW=$(echo "$NEW_ALERTS" | head -5 | sed 's/"/\\"/g' | tr '\n' '|' | sed 's/|/\\n/g')
  python3 - <<PYEOF
import requests
data = {
  "embeds": [{
    "title": "🚨 Suricata IDS Alert!",
    "description": f"**$COUNT nieuwe beveiligingswaarschuwingen gedetecteerd!**",
    "color": 15158332,
    "fields": [
      {"name": "📋 Alerts", "value": "$PREVIEW", "inline": False}
    ],
    "footer": {"text": "Suricata IDS • Sem Enkelmans"}
  }]
}
requests.post("$WEBHOOK", json=data)
PYEOF
  echo "[$(date)] $COUNT Suricata alerts verstuurd naar Discord"
fi
