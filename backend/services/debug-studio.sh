#!/bin/bash

# Debug-Script für Prisma Studio Service

echo "=== Prisma Studio Debug ==="
echo

# 1. Prüfe ob Prisma installiert ist
echo "1. Prüfe Prisma Installation..."
cd /srv/weltenwind/backend
if [ -f "node_modules/.bin/prisma" ]; then
    echo "   ✓ Prisma gefunden"
    echo "   Version: $(npx prisma --version 2>/dev/null | head -1)"
else
    echo "   ✗ FEHLER: Prisma nicht installiert!"
    echo "   Führe aus: npm install"
fi

echo
echo "2. Prüfe .env Datei..."
if [ -f ".env" ]; then
    echo "   ✓ .env gefunden"
    # Prüfe ob DATABASE_URL gesetzt ist
    if grep -q "DATABASE_URL" .env; then
        echo "   ✓ DATABASE_URL gefunden"
    else
        echo "   ✗ FEHLER: DATABASE_URL fehlt in .env!"
    fi
else
    echo "   ✗ FEHLER: .env Datei fehlt!"
fi

echo
echo "3. Prüfe Datenbank-Verbindung..."
# Teste Prisma DB Verbindung
if npx prisma db pull --print 2>&1 | grep -q "successfully"; then
    echo "   ✓ Datenbankverbindung OK"
else
    echo "   ✗ FEHLER: Keine Datenbankverbindung!"
    echo "   Prüfe DATABASE_URL in .env"
fi

echo
echo "4. Teste Prisma Studio manuell..."
echo "   Führe aus als weltenwind User:"
echo "   sudo -u weltenwind npx prisma studio --port 5555 --browser none --hostname 0.0.0.0"

echo
echo "5. Vollständige Fehlerausgabe:"
echo "   sudo journalctl -u weltenwind-studio -n 50 --no-pager"

echo
echo "=== Mögliche Lösungen ==="
echo
echo "A) Wenn Prisma nicht installiert ist:"
echo "   cd /srv/weltenwind/backend"
echo "   sudo -u weltenwind npm install"
echo
echo "B) Wenn .env fehlt:"
echo "   cp .env.example .env"
echo "   # Dann DATABASE_URL anpassen"
echo
echo "C) Wenn Berechtigungen fehlen:"
echo "   sudo chown -R weltenwind:weltenwind /srv/weltenwind/backend" 