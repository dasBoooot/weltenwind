#!/bin/bash

# Weltenwind Monitoring Stack Setup
# Installiert Uptime Kuma + Netdata für komplettes Service & System Monitoring

set -e

# Farben für Output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}🚀 Weltenwind Monitoring Stack Setup${NC}"
echo "======================================="
echo

# Prüfe ob als root ausgeführt
if [[ $EUID -ne 0 ]]; then
   echo -e "${RED}❌ Dieses Script muss als root ausgeführt werden${NC}"
   echo "   Verwende: sudo ./setup-monitoring.sh"
   exit 1
fi

# Prüfe ob Docker installiert ist
if ! command -v docker &> /dev/null; then
    echo -e "${YELLOW}📦 Docker wird installiert...${NC}"
    apt update
    apt install -y docker.io docker-compose
    systemctl enable docker
    systemctl start docker
    usermod -aG docker weltenwind
    echo -e "${GREEN}✅ Docker installiert${NC}"
fi

echo -e "${YELLOW}📊 Phase 1: Uptime Kuma Installation...${NC}"

# Erstelle Monitoring-Verzeichnis
mkdir -p /srv/monitoring/uptime-kuma
cd /srv/monitoring/uptime-kuma

# Docker Compose für Uptime Kuma
cat > docker-compose.yml << 'EOF'
version: '3.8'
services:
  uptime-kuma:
    image: louislam/uptime-kuma:1
    container_name: uptime-kuma
    volumes:
      - uptime-kuma-data:/app/data
    ports:
      - "3002:3001"  # Port 3002 extern (3001 ist von Swagger belegt)
    restart: unless-stopped
    environment:
      - UPTIME_KUMA_DISABLE_FRAME_SAMEORIGIN=true

volumes:
  uptime-kuma-data:
EOF

# Starte Uptime Kuma
docker-compose up -d

echo -e "${GREEN}✅ Uptime Kuma läuft auf Port 3002${NC}"

echo -e "${YELLOW}💻 Phase 2: Netdata Installation...${NC}"

# Netdata Installation (non-interactive)
bash <(curl -Ss https://my-netdata.io/kickstart.sh) --stable-channel --disable-telemetry --non-interactive --dont-wait

echo -e "${GREEN}✅ Netdata läuft auf Port 19999${NC}"

echo -e "${YELLOW}🔒 Phase 3: Firewall-Konfiguration...${NC}"

# Erlaube Monitoring-Ports
ufw allow 3002/tcp comment "Uptime Kuma"
ufw allow 19999/tcp comment "Netdata"

echo -e "${GREEN}✅ Firewall-Regeln hinzugefügt${NC}"

echo -e "${YELLOW}🎯 Phase 4: Health-Check-Integration...${NC}"

# Erstelle Health-Check-Endpoint für Backend (falls noch nicht vorhanden)
HEALTH_ENDPOINT="/srv/weltenwind/backend/src/routes/health.ts"
if [ ! -f "$HEALTH_ENDPOINT" ]; then
    cat > "$HEALTH_ENDPOINT" << 'EOF'
import { Router, Request, Response } from 'express';

const router = Router();

// Simple Health Check Endpoint
router.get('/health', async (req: Request, res: Response) => {
  const healthCheck = {
    uptime: process.uptime(),
    timestamp: Date.now(),
    status: 'OK',
    environment: process.env.NODE_ENV,
    version: '1.0.0',
    memory: {
      used: Math.round(process.memoryUsage().heapUsed / 1024 / 1024),
      total: Math.round(process.memoryUsage().heapTotal / 1024 / 1024)
    }
  };

  try {
    res.status(200).json(healthCheck);
  } catch (error) {
    healthCheck.status = 'ERROR';
    res.status(503).json(healthCheck);
  }
});

export default router;
EOF
    chown weltenwind:weltenwind "$HEALTH_ENDPOINT"
    echo -e "${GREEN}✅ Health-Check-Endpoint erstellt${NC}"
else
    echo -e "${YELLOW}⚠️  Health-Check-Endpoint bereits vorhanden${NC}"
fi

echo -e "${YELLOW}🎮 Phase 5: systemd Integration...${NC}"

# Erstelle Monitoring Health-Check Service
cat > /etc/systemd/system/weltenwind-health-check.service << 'EOF'
[Unit]
Description=Weltenwind Health Check Service
After=weltenwind-backend.service

[Service]
Type=oneshot
User=weltenwind
Group=weltenwind
WorkingDirectory=/srv/weltenwind/backend/services
ExecStart=/srv/weltenwind/backend/services/health-check.sh
StandardOutput=append:/var/log/weltenwind/health-check.log
StandardError=append:/var/log/weltenwind/health-check.error.log
EOF

# Erstelle Timer für regelmäßige Health-Checks
cat > /etc/systemd/system/weltenwind-health-check.timer << 'EOF'
[Unit]
Description=Run health check every 5 minutes
Requires=weltenwind-health-check.service

[Timer]
OnCalendar=*:0/5
Persistent=true

[Install]
WantedBy=timers.target
EOF

# Aktiviere Timer
systemctl daemon-reload
systemctl enable weltenwind-health-check.timer
systemctl start weltenwind-health-check.timer

echo -e "${GREEN}✅ Automatische Health-Checks aktiviert (alle 5 Minuten)${NC}"

# Setze Berechtigungen
chown -R weltenwind:weltenwind /srv/monitoring
chmod +x /srv/weltenwind/backend/services/health-check.sh

echo
echo "======================================="
echo -e "${GREEN}🎉 Monitoring Stack erfolgreich installiert!${NC}"
echo
echo -e "${BLUE}🎯 Zugriff auf deine Monitoring-Tools:${NC}"
echo "   - Uptime Kuma: http://192.168.2.168:3002"
echo "   - Netdata: http://192.168.2.168:19999"
echo
echo -e "${YELLOW}📋 Nächste Schritte:${NC}"
echo
echo "1. Öffne Uptime Kuma (http://192.168.2.168:3002) und erstelle einen Admin-Account"
echo
echo "2. Füge folgende Monitore hinzu:"
echo "   - HTTP: http://192.168.2.168:3000/api/health (Backend API)"
echo "   - TCP: 192.168.2.168:5432 (PostgreSQL)"
echo "   - TCP: 192.168.2.168:5555 (Prisma Studio)"
echo "   - HTTP: http://192.168.2.168:3001 (Swagger Docs)"
echo
echo "3. Konfiguriere Benachrichtigungen:"
echo "   - Discord Webhook für sofortige Alerts"
echo "   - Email für wichtige Ausfälle"
echo
echo "4. Erstelle eine Status-Page für Transparenz"
echo
echo "5. Öffne Netdata (http://192.168.2.168:19999) für System-Monitoring"
echo
echo -e "${GREEN}✅ Automatische Health-Checks laufen alle 5 Minuten${NC}"
echo -e "${GREEN}✅ Logs unter: /var/log/weltenwind/health-check.log${NC}"
echo
echo "🚀 Dein Weltenwind-System ist jetzt professionell überwacht!"