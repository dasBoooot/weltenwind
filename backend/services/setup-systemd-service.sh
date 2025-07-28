#!/bin/bash

# Setup script für Weltenwind systemd Services
# Dieses Script muss als root oder mit sudo ausgeführt werden

set -e  # Exit on error

echo "=== Weltenwind Services Setup ==="
echo

# Prüfe ob als root ausgeführt
if [ "$EUID" -ne 0 ]; then 
   echo "Bitte als root ausführen (sudo $0)"
   exit 1
fi

# Variablen - ANPASSEN AN DEINE UMGEBUNG!
SERVICE_USER="weltenwind"
SERVICE_GROUP="weltenwind"
BACKEND_DIR="/srv/weltenwind/backend"
SERVICES_DIR="/srv/weltenwind/backend/services"
LOG_DIR="/var/log/weltenwind"

echo "1. Erstelle Service-User (falls nicht vorhanden)..."
if ! id "$SERVICE_USER" &>/dev/null; then
    useradd -r -s /bin/false -d /nonexistent -c "Weltenwind Service" $SERVICE_USER
    echo "   User $SERVICE_USER erstellt"
else
    echo "   User $SERVICE_USER existiert bereits"
fi

echo
echo "2. Erstelle Log-Verzeichnis..."
mkdir -p $LOG_DIR
chown $SERVICE_USER:$SERVICE_GROUP $LOG_DIR
chmod 755 $LOG_DIR
echo "   $LOG_DIR erstellt"

echo
echo "3. Setze Berechtigungen für Backend-Verzeichnis..."
chown -R $SERVICE_USER:$SERVICE_GROUP $BACKEND_DIR
# Wichtig: node_modules sollte auch dem Service-User gehören
chown -R $SERVICE_USER:$SERVICE_GROUP /srv/weltenwind/node_modules
echo "   Berechtigungen gesetzt"

echo
echo "4. Kopiere Service-Dateien..."
cp $SERVICES_DIR/weltenwind.target /etc/systemd/system/
cp $SERVICES_DIR/weltenwind-backend.service /etc/systemd/system/
cp $SERVICES_DIR/weltenwind-docs.service /etc/systemd/system/
cp $SERVICES_DIR/weltenwind-studio.service /etc/systemd/system/
echo "   Service-Dateien kopiert"

echo
echo "5. Lade systemd neu..."
systemctl daemon-reload
echo "   systemd neu geladen"

echo
echo "6. Aktiviere Services..."
systemctl enable weltenwind.target
systemctl enable weltenwind-backend.service
systemctl enable weltenwind-docs.service
systemctl enable weltenwind-studio.service
echo "   Services aktiviert"

echo
echo "=== Setup abgeschlossen! ==="
echo
echo "Nützliche Befehle:"
echo "  sudo systemctl start weltenwind.target    # Alle Services starten"
echo "  sudo systemctl stop weltenwind.target     # Alle Services stoppen"
echo "  sudo systemctl restart weltenwind.target  # Alle Services neu starten"
echo "  sudo systemctl status weltenwind.target   # Status aller Services"
echo
echo "Einzelne Services:"
echo "  sudo systemctl restart weltenwind-backend  # Nur Backend neu starten"
echo "  sudo systemctl restart weltenwind-docs     # Nur Docs neu starten"
echo "  sudo systemctl restart weltenwind-studio   # Nur Studio neu starten"
echo
echo "Logs anzeigen:"
echo "  sudo journalctl -u weltenwind-backend -f"
echo "  tail -f $LOG_DIR/backend.log"
echo "  tail -f $LOG_DIR/docs.log"
echo "  tail -f $LOG_DIR/studio.log"
echo
echo "Services werden gestartet auf:"
echo "  - Backend API: http://localhost:3000"
echo "  - Swagger Docs: http://localhost:3001"
echo "  - Prisma Studio: http://localhost:5555"
echo
echo "Starte alle Services jetzt mit:"
echo "  sudo systemctl start weltenwind.target" 