#!/bin/bash

# Fix für Prisma Studio Home-Verzeichnis Problem

echo "=== Fix Prisma Studio Home Directory ==="
echo

if [ "$EUID" -ne 0 ]; then 
   echo "Bitte als root ausführen (sudo $0)"
   exit 1
fi

echo "1. Erstelle Home-Verzeichnis für weltenwind User..."
mkdir -p /var/lib/weltenwind
chown weltenwind:weltenwind /var/lib/weltenwind
chmod 755 /var/lib/weltenwind
echo "   ✓ /var/lib/weltenwind erstellt"

echo
echo "2. Kopiere aktualisierte Service-Datei..."
cp weltenwind-studio.service /etc/systemd/system/
echo "   ✓ Service-Datei aktualisiert"

echo
echo "3. Lade systemd neu..."
systemctl daemon-reload
echo "   ✓ systemd neu geladen"

echo  
echo "4. Starte Prisma Studio neu..."
systemctl restart weltenwind-studio
echo "   ✓ Service neu gestartet"

echo
echo "5. Prüfe Status..."
sleep 2
systemctl status weltenwind-studio --no-pager

echo
echo "=== Fertig! ==="
echo "Prisma Studio sollte jetzt laufen auf: http://192.168.2.168:5555"
echo
echo "Falls nicht erreichbar, prüfe die Firewall:"
echo "  sudo ufw allow 5555" 