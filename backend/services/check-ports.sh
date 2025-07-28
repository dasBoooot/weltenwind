#!/bin/bash

# Script zum Prüfen der Weltenwind Service Ports

echo "=== Weltenwind Service Port Check ==="
echo

# Funktion zum Prüfen eines Ports
check_port() {
    local port=$1
    local service=$2
    
    echo -n "Port $port ($service): "
    
    # Prüfe ob der Port belegt ist
    if lsof -i :$port 2>/dev/null | grep LISTEN > /dev/null; then
        echo -n "AKTIV - "
        # Zeige welcher Prozess den Port belegt
        lsof -i :$port 2>/dev/null | grep LISTEN | awk '{print $1, $2}' | head -1
    else
        echo "NICHT AKTIV"
    fi
}

# Prüfe alle Service-Ports
check_port 3000 "Backend API"
check_port 3001 "Swagger Docs"
check_port 5555 "Prisma Studio"

echo
echo "=== Externe Erreichbarkeit ==="
echo

# Prüfe ob Ports von außen erreichbar sind
echo "Prisma Studio sollte erreichbar sein unter:"
echo "  - http://localhost:5555 (lokal)"
echo "  - http://192.168.2.168:5555 (extern)"

echo
echo "Falls Prisma Studio nicht erreichbar ist:"
echo "1. Prüfe die Firewall: sudo ufw status"
echo "2. Erlaube Port 5555: sudo ufw allow 5555"
echo "3. Prüfe die Logs: sudo journalctl -u weltenwind-studio -f" 