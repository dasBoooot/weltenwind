#!/bin/bash

# Weltenwind Log-Cleanup Script
# Entfernt nicht verwendete, leere Log-Dateien

LOG_DIR="/var/log/weltenwind"

echo "🧹 Weltenwind Log-Cleanup"
echo "========================="
echo "Log-Verzeichnis: $LOG_DIR"
echo ""

# Prüfe ob Verzeichnis existiert
if [ ! -d "$LOG_DIR" ]; then
    echo "❌ Log-Verzeichnis $LOG_DIR existiert nicht!"
    exit 1
fi

echo "📊 Aktuelle Log-Dateien:"
ls -la "$LOG_DIR"/*.log 2>/dev/null | awk '{print $5 " bytes\t" $9}' | sort -n
echo ""

# Liste der nicht mehr verwendeten Log-Dateien
UNUSED_LOGS=(
    "api.log"
    "client-config.log" 
    "database.log"
    "password-reset.log"
    "registration.log"
    "security.log"
    "tokens.log"
    "test.log"
    "nginx.log"
    "docs.log"
)

echo "🗑️ Leere/ungenutzte Log-Dateien entfernen:"
echo "==========================================="

for log_file in "${UNUSED_LOGS[@]}"; do
    log_path="$LOG_DIR/$log_file"
    if [ -f "$log_path" ]; then
        file_size=$(stat -f%z "$log_path" 2>/dev/null || stat -c%s "$log_path" 2>/dev/null)
        if [ "$file_size" -eq 0 ]; then
            echo "🗑️  Entferne leere Datei: $log_file"
            rm "$log_path"
        else
            echo "⚠️  Datei nicht leer ($file_size bytes): $log_file"
        fi
    else
        echo "✅ Bereits entfernt: $log_file"
    fi
done

echo ""
echo "📊 Nach Cleanup:"
ls -la "$LOG_DIR"/*.log 2>/dev/null | awk '{print $5 " bytes\t" $9}' | sort -n
echo ""

echo "✅ Log-Cleanup abgeschlossen!"
echo ""
echo "📋 Aktive Log-Kategorien:"
echo "  📋 Application: app.log, auth.log, error.log"
echo "  ⚙️  Services: backend.log, backend.error.log, studio.log"  
echo "  🌐 Infrastructure: nginx.error.log, docs.error.log"
echo ""
echo "💡 Tipp: Nach dem Cleanup systemd-Service neu starten:"
echo "   sudo systemctl restart weltenwind-backend.service"
