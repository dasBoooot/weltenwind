#!/bin/bash

# Weltenwind Logging Setup Script
# Erweitert die bestehende systemd Service-Konfiguration um strukturiertes Logging

set -e

# Farben für Output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${GREEN}🔧 Weltenwind Logging Setup${NC}"
echo "=================================="

# Prüfe ob Script als root läuft
if [[ $EUID -ne 0 ]]; then
   echo -e "${RED}❌ Dieses Script muss als root ausgeführt werden${NC}"
   echo "   Verwende: sudo ./setup-logging.sh"
   exit 1
fi

# Prüfe ob weltenwind User existiert
if ! id "weltenwind" &>/dev/null; then
    echo -e "${RED}❌ User 'weltenwind' existiert nicht${NC}"
    echo "   Führe zuerst setup-systemd-service.sh aus"
    exit 1
fi

echo -e "${YELLOW}📁 Erstelle Log-Verzeichnisse...${NC}"

# Log-Verzeichnis erstellen
sudo mkdir -p /var/log/weltenwind
sudo chown weltenwind:weltenwind /var/log/weltenwind
sudo chmod 755 /var/log/weltenwind

# Grundlegende Log-Dateien erstellen (für logrotate)
sudo touch /var/log/weltenwind/backend.log
sudo touch /var/log/weltenwind/backend.error.log
sudo touch /var/log/weltenwind/app.log
sudo touch /var/log/weltenwind/auth.log
sudo touch /var/log/weltenwind/security.log
sudo touch /var/log/weltenwind/api.log
sudo touch /var/log/weltenwind/error.log

sudo chown weltenwind:weltenwind /var/log/weltenwind/*.log
sudo chmod 644 /var/log/weltenwind/*.log

echo -e "${YELLOW}🔄 Konfiguriere Log-Rotation...${NC}"

# Logrotate-Konfiguration installieren
sudo cp weltenwind-logrotate.conf /etc/logrotate.d/weltenwind
sudo chmod 644 /etc/logrotate.d/weltenwind

echo -e "${YELLOW}📋 Teste Logrotate-Konfiguration...${NC}"

# Teste Logrotate (dry-run)
sudo logrotate -d /etc/logrotate.d/weltenwind

echo -e "${YELLOW}🔧 Aktualisiere systemd Services...${NC}"

# Services neu laden (falls bereits installiert)
if systemctl is-enabled weltenwind-backend.service &>/dev/null; then
    sudo systemctl daemon-reload
    sudo systemctl restart weltenwind-backend.service
    echo -e "${GREEN}✅ weltenwind-backend.service neu gestartet${NC}"
fi

echo -e "${GREEN}✅ Logging Setup abgeschlossen!${NC}"
echo ""
echo -e "${YELLOW}📊 Log-Verzeichnisse:${NC}"
echo "   • systemd Standard:     /var/log/weltenwind/backend.log"
echo "   • systemd Errors:       /var/log/weltenwind/backend.error.log"
echo "   • Winston Structured:   /var/log/weltenwind/app.log"
echo "   • Auth Events:          /var/log/weltenwind/auth.log"
echo "   • Security Events:      /var/log/weltenwind/security.log"
echo "   • API Requests:         /var/log/weltenwind/api.log"
echo "   • Errors Only:          /var/log/weltenwind/error.log"
echo ""
echo -e "${YELLOW}🔍 Nützliche Befehle:${NC}"
echo "   # Live-Logs verfolgen:"
echo "     sudo tail -f /var/log/weltenwind/app.log"
echo "     sudo tail -f /var/log/weltenwind/security.log"
echo ""
echo "   # Log-Größen prüfen:"
echo "     sudo du -sh /var/log/weltenwind/*"
echo ""
echo "   # Log-Rotation manuell testen:"
echo "     sudo logrotate -f /etc/logrotate.d/weltenwind"
echo ""
echo -e "${GREEN}🎯 Log-Viewer Web-UI verfügbar unter:${NC}"
echo "   http://your-server:3000/log-viewer/"
echo ""