# 📊 Self-Hosted Monitoring-Lösungen für Weltenwind

Übersicht über kostenfreie, self-hosted Monitoring-Tools die perfekt auf den Weltenwind Backend-Server integriert werden können.

## 🏆 **Top-Empfehlungen** (Einfach & Effektiv)

### 1. 🚀 **Uptime Kuma** - Simple aber Mächtig
**⭐ BESTE WAHL für den Start!**

```bash
# Docker Installation (Empfohlen)
mkdir -p /srv/monitoring/uptime-kuma
cd /srv/monitoring/uptime-kuma

# Docker Compose Setup
cat > docker-compose.yml << 'EOF'
version: '3.8'
services:
  uptime-kuma:
    image: louislam/uptime-kuma:1
    container_name: uptime-kuma
    volumes:
      - ./data:/app/data
    ports:
      - "3002:3001"  # Port 3002 extern (3001 ist schon von Swagger belegt)
    restart: unless-stopped
EOF

docker-compose up -d
```

**✅ Was du bekommst:**
- **Uptime-Monitoring** für alle deine Services (Backend, Studio, Docs)
- **HTTP/HTTPS Checks** mit Response-Zeit-Messung
- **TCP Port Monitoring** (Postgres, alle Services)
- **Keyword-Monitoring** (prüft ob bestimmte Inhalte auf der Seite stehen)
- **Push Notifications** (Discord, Telegram, Email, etc.)
- **Status Pages** (öffentlich oder privat)
- **Grafiken & Dashboards**
- **Multi-User Support**

**🎯 URL:** `http://192.168.2.168:3002`

---

### 2. 💎 **Netdata** - Real-Time System Monitoring
**⭐ PERFEKT für System-Metriken!**

```bash
# Native Installation (super einfach)
bash <(curl -Ss https://my-netdata.io/kickstart.sh) --stable-channel --disable-telemetry

# Oder Docker (falls bevorzugt)
docker run -d --name=netdata \
  -p 19999:19999 \
  -v netdataconfig:/etc/netdata \
  -v netdatalib:/var/lib/netdata \
  -v netdatacache:/var/cache/netdata \
  -v /etc/passwd:/host/etc/passwd:ro \
  -v /etc/group:/host/etc/group:ro \
  -v /proc:/host/proc:ro \
  -v /sys:/host/sys:ro \
  -v /etc/os-release:/host/etc/os-release:ro \
  --restart unless-stopped \
  --cap-add SYS_PTRACE \
  --security-opt apparmor=unconfined \
  netdata/netdata
```

**✅ Was du bekommst:**
- **Real-Time Metriken** (CPU, RAM, Disk, Network)
- **Node.js Process Monitoring**
- **PostgreSQL Monitoring** (Connections, Queries, Performance)
- **systemd Services Monitoring**
- **Log-File Monitoring**
- **Alerting** (Email, Discord, etc.)
- **Zero-Configuration** - läuft sofort!

**🎯 URL:** `http://192.168.2.168:19999`

---

## 🔥 **Advanced Options** (Für Profis)

### 3. 📈 **Prometheus + Grafana Stack**
**⭐ ENTERPRISE-GRADE Monitoring!**

#### Installation Script:
```bash
#!/bin/bash
# monitoring-stack-setup.sh

mkdir -p /srv/monitoring/prometheus
cd /srv/monitoring/prometheus

# Prometheus Configuration
cat > prometheus.yml << 'EOF'
global:
  scrape_interval: 15s
  
scrape_configs:
  - job_name: 'weltenwind-backend'
    static_configs:
      - targets: ['localhost:3000']
    metrics_path: '/api/metrics'  # Du musst diesen Endpoint erstellen
    
  - job_name: 'node-exporter'
    static_configs:
      - targets: ['localhost:9100']
      
  - job_name: 'postgres-exporter'
    static_configs:
      - targets: ['localhost:9187']
EOF

# Docker Compose für kompletten Stack
cat > docker-compose.yml << 'EOF'
version: '3.8'

services:
  prometheus:
    image: prom/prometheus:latest
    container_name: prometheus
    ports:
      - "9090:9090"
    volumes:
      - ./prometheus.yml:/etc/prometheus/prometheus.yml
      - prometheus_data:/prometheus
    command:
      - '--config.file=/etc/prometheus/prometheus.yml'
      - '--storage.tsdb.path=/prometheus'
      - '--web.console.libraries=/etc/prometheus/console_libraries'
      - '--web.console.templates=/etc/prometheus/consoles'
      - '--storage.tsdb.retention.time=200h'
      - '--web.enable-lifecycle'
    restart: unless-stopped

  grafana:
    image: grafana/grafana:latest
    container_name: grafana
    ports:
      - "3003:3000"
    environment:
      - GF_SECURITY_ADMIN_PASSWORD=admin123
    volumes:
      - grafana_data:/var/lib/grafana
    restart: unless-stopped

  node-exporter:
    image: prom/node-exporter:latest
    container_name: node_exporter
    ports:
      - "9100:9100"
    volumes:
      - /proc:/host/proc:ro
      - /sys:/host/sys:ro
      - /:/rootfs:ro
    command:
      - '--path.procfs=/host/proc'
      - '--path.rootfs=/rootfs'
      - '--path.sysfs=/host/sys'
      - '--collector.filesystem.mount-points-exclude=^/(sys|proc|dev|host|etc)($$|/)'
    restart: unless-stopped

  postgres-exporter:
    image: prometheuscommunity/postgres-exporter:latest
    container_name: postgres_exporter
    ports:
      - "9187:9187"
    environment:
      DATA_SOURCE_NAME: "postgresql://username:password@localhost:5432/weltenwind?sslmode=disable"
    restart: unless-stopped

volumes:
  prometheus_data:
  grafana_data:
EOF

docker-compose up -d
```

**✅ Was du bekommst:**
- **Prometheus:** Metriken-Sammlung und -Speicherung
- **Grafana:** Wunderschöne Dashboards und Alerting
- **Node Exporter:** System-Metriken (CPU, RAM, Disk, Network)
- **Postgres Exporter:** Database-Performance-Metriken
- **Custom Metriken:** Deine eigenen API-Metriken

**🎯 URLs:**
- Prometheus: `http://192.168.2.168:9090`
- Grafana: `http://192.168.2.168:3003` (admin/admin123)

---

### 4. 🎯 **Prometheus Node.js Integration**

Für **deine Backend-API** kannst du Prometheus-Metriken hinzufügen:

```bash
# Im Backend-Verzeichnis
npm install prom-client express-prometheus-middleware
```

```javascript
// backend/src/monitoring/prometheus.ts
import client from 'prom-client';
import express from 'express';

// Register für alle Metriken
const register = new client.Registry();

// Standard-Metriken sammeln
client.collectDefaultMetrics({
  register,
  prefix: 'weltenwind_',
});

// Custom Metriken
const httpRequestsTotal = new client.Counter({
  name: 'weltenwind_http_requests_total',
  help: 'Total number of HTTP requests',
  labelNames: ['method', 'route', 'status_code'],
  registers: [register],
});

const httpRequestDuration = new client.Histogram({
  name: 'weltenwind_http_request_duration_seconds',
  help: 'Duration of HTTP requests in seconds',
  labelNames: ['method', 'route'],
  registers: [register],
});

// Active connections
const activeConnections = new client.Gauge({
  name: 'weltenwind_active_connections',
  help: 'Number of active connections',
  registers: [register],
});

// Database query duration
const dbQueryDuration = new client.Histogram({
  name: 'weltenwind_db_query_duration_seconds',
  help: 'Database query duration in seconds',
  labelNames: ['operation'],
  registers: [register],
});

export { register, httpRequestsTotal, httpRequestDuration, activeConnections, dbQueryDuration };
```

```javascript
// backend/src/routes/metrics.ts
import { Router } from 'express';
import { register } from '../monitoring/prometheus';

const router = Router();

router.get('/metrics', async (req, res) => {
  res.set('Content-Type', register.contentType);
  res.end(await register.metrics());
});

export default router;
```

---

## 🎚️ **Monitoring-Strategie-Empfehlung**

### **Phase 1: Quick Start (15 Minuten)**
```bash
# Uptime Kuma für Service-Monitoring
cd /srv/monitoring
git clone https://github.com/louislam/uptime-kuma.git
cd uptime-kuma
npm run setup
npm run start-server -- --port=3002
```

### **Phase 2: System-Monitoring (30 Minuten)**
```bash
# Netdata für System-Metriken
bash <(curl -Ss https://my-netdata.io/kickstart.sh) --stable-channel --disable-telemetry
```

### **Phase 3: Advanced (2-3 Stunden)**
```bash
# Prometheus + Grafana Stack
# (Script von oben verwenden)
```

---

## 🔥 **Sofort-Setup für Weltenwind**

### **monitoring-quick-setup.sh**
```bash
#!/bin/bash
# Komplettes Monitoring-Setup für Weltenwind

echo "🚀 Setting up Weltenwind Monitoring Stack..."

# 1. Uptime Kuma (Service Monitoring)
echo "📊 Installing Uptime Kuma..."
mkdir -p /srv/monitoring/uptime-kuma
cd /srv/monitoring/uptime-kuma
docker run -d --restart=unless-stopped --name uptime-kuma -p 3002:3001 -v uptime-kuma:/app/data louislam/uptime-kuma:1

# 2. Netdata (System Monitoring)
echo "💻 Installing Netdata..."
bash <(curl -Ss https://my-netdata.io/kickstart.sh) --stable-channel --disable-telemetry --non-interactive

# 3. Configure Firewall
echo "🔒 Configuring Firewall..."
ufw allow 3002/tcp  # Uptime Kuma
ufw allow 19999/tcp # Netdata

echo "✅ Monitoring Stack installed!"
echo
echo "🎯 Access your monitoring:"
echo "   - Uptime Kuma: http://192.168.2.168:3002"
echo "   - Netdata: http://192.168.2.168:19999"
echo
echo "📋 Next steps:"
echo "   1. Open Uptime Kuma and add monitors for:"
echo "      - http://localhost:3000/api/health (Backend)"
echo "      - tcp://localhost:5432 (PostgreSQL)" 
echo "      - tcp://localhost:5555 (Prisma Studio)"
echo "   2. Configure notifications (Discord/Email)"
echo "   3. Create status page"
```

---

## 💰 **Kosten-Nutzen-Analyse**

| Tool | Setup-Zeit | Ressourcen | Features | Empfehlung |
|------|------------|------------|----------|------------|
| **Uptime Kuma** | 5 min | ~50MB RAM | Service-Monitoring, Alerts, Status-Pages | ⭐⭐⭐⭐⭐ |
| **Netdata** | 10 min | ~100MB RAM | Real-time System-Metriken | ⭐⭐⭐⭐⭐ |
| **Prometheus+Grafana** | 60 min | ~300MB RAM | Enterprise-Grade, Custom-Metriken | ⭐⭐⭐⭐ |

---

## 🎯 **Meine Empfehlung für dich:**

### **Sofort starten:**
1. **Uptime Kuma** (5 Minuten) - Für Service-Monitoring
2. **Netdata** (10 Minuten) - Für System-Monitoring

### **Später erweitern:**
3. **Prometheus-Metriken** in deine Backend-API integrieren
4. **Grafana-Dashboards** für schöne Visualisierungen

**Das gibt dir 95% aller Monitoring-Features die du brauchst - komplett kostenfrei und self-hosted!** 🚀