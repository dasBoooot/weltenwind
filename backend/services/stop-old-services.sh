#!/bin/bash

# Script zum Stoppen der alten Services und Cleanup

echo "=== Stoppe alte Weltenwind Services ==="
echo

# Stoppe alle alten Prozesse
echo "1. Stoppe laufende Prozesse..."

# Backend API
echo -n "   - Backend API (npm run dev)... "
pkill -f "npm run dev" 2>/dev/null && echo "gestoppt" || echo "nicht gefunden"

# Swagger Docs
echo -n "   - Swagger Docs (npx serve)... "
pkill -f "npx serve.*swagger-editor-dist" 2>/dev/null && echo "gestoppt" || echo "nicht gefunden"

# Prisma Studio
echo -n "   - Prisma Studio... "
pkill -f "prisma studio" 2>/dev/null && echo "gestoppt" || echo "nicht gefunden"

echo
echo "2. Prüfe auf verbleibende Prozesse..."

# Zeige noch laufende Prozesse auf den Ports
echo -n "   - Port 3000: "
lsof -i :3000 2>/dev/null | grep LISTEN > /dev/null && echo "BELEGT!" || echo "frei"

echo -n "   - Port 3001: "
lsof -i :3001 2>/dev/null | grep LISTEN > /dev/null && echo "BELEGT!" || echo "frei"

echo -n "   - Port 5555: "
lsof -i :5555 2>/dev/null | grep LISTEN > /dev/null && echo "BELEGT!" || echo "frei"

echo
echo "3. Alte Start-Scripts werden entfernt..."
echo "   Die folgenden Dateien können gelöscht werden:"
echo "   - /srv/weltenwind/backend/start-api.sh"
echo "   - /srv/weltenwind/backend/start-docs.sh"
echo "   - /srv/weltenwind/backend/start-studio.sh"

echo
echo "=== Cleanup abgeschlossen! ==="
echo
echo "Die alten Services wurden gestoppt."
echo "Du kannst jetzt die neuen systemd Services verwenden:"
echo "  sudo systemctl start weltenwind.target" 