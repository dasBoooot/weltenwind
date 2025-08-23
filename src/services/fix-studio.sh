#!/bin/bash

# Quick-Fix Script für Prisma Studio Service

echo "=== Prisma Studio Quick Fix ==="
echo

# Als root ausführen
if [ "$EUID" -ne 0 ]; then 
   echo "Bitte als root ausführen (sudo $0)"
   exit 1
fi

echo "1. Stoppe Prisma Studio Service..."
systemctl stop weltenwind-studio

echo
echo "2. Installiere npm Pakete als weltenwind User..."
cd /srv/weltenwind/backend
sudo -u weltenwind npm install

echo
echo "3. Generiere Prisma Client..."
sudo -u weltenwind npx prisma generate

echo
echo "4. Prüfe .env Datei..."
if [ ! -f ".env" ]; then
    echo "   ✗ FEHLER: .env fehlt!"
    echo "   Erstelle .env mit DATABASE_URL"
    exit 1
fi

echo
echo "5. Teste Prisma Studio manuell..."
echo "   Starte Test (Ctrl+C zum Beenden):"
sudo -u weltenwind timeout 5 npx prisma studio --port 5555 --browser none --hostname 0.0.0.0 || true

echo
echo "6. Lade Service neu und starte..."
systemctl daemon-reload
systemctl start weltenwind-studio

echo
echo "7. Prüfe Status..."
systemctl status weltenwind-studio --no-pager

echo
echo "=== Fertig! ==="
echo "Prisma Studio sollte jetzt laufen auf: http://192.168.2.168:5555"
echo
echo "Falls immer noch Fehler:"
echo "  sudo journalctl -u weltenwind-studio -f" 