#!/bin/bash
WEBHOOK="YOUR_DISCORD_WEBHOOK_URL"
STATE_FILE="/tmp/prometheus_alert_state"
touch "$STATE_FILE"

ALERTS=$(curl -s http://localhost:9090/api/v1/alerts | python3 -c "
import sys, json
data = json.load(sys.stdin)
for a in data['data']['alerts']:
    if a['state'] == 'firing':
        name = a['labels'].get('alertname','?')
        inst = a['labels'].get('instance','?')
        summary = a['annotations'].get('summary','?')
        desc = a['annotations'].get('description','')
        print(f'{name}|{inst}|{summary}|{desc}')
" 2>/dev/null)

while IFS='|' read -r name inst summary desc; do
    [ -z "$name" ] && continue
    KEY="${name}_${inst}"
    if ! grep -q "^${KEY}$" "$STATE_FILE" 2>/dev/null; then
        echo "$KEY" >> "$STATE_FILE"
        python3 - <<PYEOF
import requests
data = {
  "embeds": [{
    "title": "🚨 RPi Alert: $name",
    "description": "$summary\n$desc",
    "color": 15158332,
    "footer": {"text": "RPi Monitor • Sem Enkelmans"}
  }]
}
r = requests.post("$WEBHOOK", json=data)
print(r.status_code)
PYEOF
    fi
done <<< "$ALERTS"

# Opgeloste alerts uit state verwijderen
if [ -f "$STATE_FILE" ]; then
    ACTIVE_KEYS=$(echo "$ALERTS" | awk -F'|' '{print $1"_"$2}')
    while IFS= read -r key; do
        if ! echo "$ACTIVE_KEYS" | grep -q "^${key}$"; then
            sed -i "/^${key}$/d" "$STATE_FILE"
        fi
    done < "$STATE_FILE"
fi
