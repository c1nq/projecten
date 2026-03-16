#!/bin/bash
WEBHOOK="YOUR_DISCORD_WEBHOOK_URL"
DATE=$(date +%Y-%m-%d)
BACKUP_FILE="/tmp/rpi-backup-$DATE.tar.gz"
tar -czf "$BACKUP_FILE" \
  /home/semenkelmans/files/docker-compose.yml \
  /home/semenkelmans/files/prometheus/prometheus.yml \
  /home/semenkelmans/files/prometheus/alerts.yml \
  /home/semenkelmans/files/alertmanager/alertmanager.yml \
  /home/semenkelmans/files/blackbox/blackbox.yml \
  /home/semenkelmans/files/device-names.txt \
  /home/semenkelmans/files/device-scanner.sh \
  2>/dev/null
SIZE=$(du -sh "$BACKUP_FILE" | cut -f1)
curl -s -X POST "$WEBHOOK" -H "Content-Type: application/json" -d "{\"embeds\":[{\"title\":\"💾 Dagelijkse Backup — $DATE\",\"description\":\"Backup van alle configuratie bestanden.\",\"color\":5763719,\"fields\":[{\"name\":\"📦 Grootte\",\"value\":\"**$SIZE**\",\"inline\":true},{\"name\":\"📅 Datum\",\"value\":\"**$DATE**\",\"inline\":true}],\"footer\":{\"text\":\"RPi Monitor • Sem Enkelmans\"},\"timestamp\":\"$(date -u +%Y-%m-%dT%H:%M:%SZ)\"}]}" > /dev/null
curl -s -X POST "$WEBHOOK" -F "file=@$BACKUP_FILE" -F "payload_json={\"content\":\"📎 Backup bestand\"}" > /dev/null
rm -f "$BACKUP_FILE"
echo "[$(date)] Backup verstuurd"
