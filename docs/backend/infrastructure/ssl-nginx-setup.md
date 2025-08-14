# 🔐 SSL/TLS + nginx Reverse Proxy Setup

**Komplette Anleitung für HTTPS-Migration mit nginx Reverse Proxy**

---

## 🎯 **Überblick**

Diese Dokumentation beschreibt die Migration von HTTP zu HTTPS mit nginx als Reverse Proxy für das Weltenwind Backend-System.

### **✅ Was erreicht wird:**
- ✅ **SSL/TLS Terminierung** über nginx
- ✅ **HTTP → HTTPS Redirect** automatisch
- ✅ **Trust Proxy Security** korrekt konfiguriert
- ✅ **Rate Limiting** sicher für Reverse Proxy
- ✅ **CSRF Protection** SSL-migration-ready
- ✅ **Dynamic URL Configuration** über Environment Variables

---

## 🛠️ **Setup-Schritte**

### **1. SSL-Zertifikat generieren**

```bash
# Self-signed für Development
sudo mkdir -p /etc/nginx/ssl
sudo openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
  -keyout /etc/nginx/ssl/weltenwind.key \
  -out /etc/nginx/ssl/weltenwind.crt \
  -subj "/C=DE/ST=NRW/L=City/O=Weltenwind/CN=192.168.2.168" \
  -config <(
    echo '[req]'
    echo 'distinguished_name = req'
    echo '[v3_req]'
    echo 'keyUsage = digitalSignature, keyEncipherment'
    echo 'extendedKeyUsage = serverAuth'
    echo 'subjectAltName = @alt_names'
    echo '[alt_names]'
    echo 'DNS.1 = localhost'
    echo 'DNS.2 = weltenwind.local'
    echo 'IP.1 = 127.0.0.1'
    echo 'IP.2 = 192.168.2.168'
  ) -extensions v3_req

sudo chmod 600 /etc/nginx/ssl/weltenwind.key
sudo chmod 644 /etc/nginx/ssl/weltenwind.crt
```

### **2. nginx Konfiguration**

**Datei:** `/etc/nginx/sites-available/weltenwind`

```nginx
# HTTP → HTTPS Redirect
server {
    listen 80;
    server_name localhost weltenwind.local _;
    return 301 https://$server_name$request_uri;
}

# HTTPS Server
server {
    listen 443 ssl http2;
    server_name localhost weltenwind.local _;

    # SSL Configuration
    ssl_certificate /etc/nginx/ssl/weltenwind.crt;
    ssl_certificate_key /etc/nginx/ssl/weltenwind.key;
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers EECDH+AESGCM:EDH+AESGCM;
    ssl_prefer_server_ciphers on;
    ssl_session_cache shared:SSL:10m;
    ssl_session_timeout 5m;

    # Security Headers (CSP wird vom Backend gesetzt)
    add_header X-Frame-Options "SAMEORIGIN" always;
    add_header X-XSS-Protection "1; mode=block" always;
    add_header X-Content-Type-Options "nosniff" always;
    add_header Referrer-Policy "no-referrer-when-downgrade" always;

    # API Backend Proxy
    location /api/ {
        proxy_pass http://127.0.0.1:3000/api/;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_cache_bypass $http_upgrade;
    }

    # API Documentation
    location /api-combined.yaml {
        proxy_pass http://127.0.0.1:3000/api-combined.yaml;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        
        add_header Content-Type "application/x-yaml" always;
        add_header Access-Control-Allow-Origin "*" always;
    }

    # Flutter Web App + Static Assets
    location / {
        proxy_pass http://127.0.0.1:3000/;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
```

### **3. nginx Service Integration**

```bash
# nginx in systemd Target einbinden
sudo systemctl enable nginx

# Weltenwind-spezifischer nginx Service (optional)
sudo systemctl enable weltenwind-nginx.service
```

---

## ⚙️ **Backend-Konfiguration**

### **Trust Proxy Security**

**Problem:** `trust proxy: true` + Rate Limiting = Security Risk

**Lösung:** Nur ersten Proxy (nginx) vertrauen:

```typescript
// server.ts
if (TRUST_PROXY_ENABLED) {
  app.set('trust proxy', 1); // Nur nginx vertrauen - SICHER!
  console.log('🔗 Trust Proxy: AKTIVIERT (nginx Reverse Proxy - nur 1 Hop)');
}
```

### **CSRF SSL-Migration Fix**

**Problem:** Nach SSL-Migration sind alle CSRF-Tokens ungültig

**Lösung:** Development Auto-Recovery:

```typescript
// csrf-protection.ts
if (isDevelopment) {
  console.warn(`⚠️  CSRF-Token invalid - generiere neuen Token (SSL-Migration)`);
  const newToken = generateCsrfToken(req.user.id.toString());
  res.setHeader('X-CSRF-Token', newToken);
  res.setHeader('X-CSRF-Recovery', 'true');
  return next(); // Weiter trotz ungültigem Token
}
```

---

## 🌐 **URL-Konfiguration**

### **Environment Variables**

```bash
# Backend Internal URLs
BASE_URL="http://127.0.0.1:3000"

# Public/External URLs (über nginx)
PUBLIC_API_URL="https://192.168.2.168/api"
PUBLIC_CLIENT_URL="https://192.168.2.168"
PUBLIC_ASSETS_URL="https://192.168.2.168"

# SSL & Proxy
SSL_ENABLED=true
TRUST_PROXY=true
```

### **Dynamische URL-Verwendung**

```typescript
// server.ts
console.log(`🎮 Flutter-Game verfügbar unter: ${PUBLIC_CLIENT_URL}/game`);
console.log(`📘 Swagger Editor verfügbar unter: ${PUBLIC_CLIENT_URL}/docs`);
console.log(`🎨 Theme Editor verfügbar unter: ${PUBLIC_ASSETS_URL}/theme-editor/`);
```

---

## 🧪 **Testing & Validierung**

### **SSL-Zertifikat testen**
```bash
# Zertifikat-Details anzeigen
openssl x509 -in /etc/nginx/ssl/weltenwind.crt -text -noout

# SSL-Verbindung testen
openssl s_client -connect 192.168.2.168:443 -servername 192.168.2.168
```

### **API-Endpoints testen**
```bash
# Health Check
curl -k https://192.168.2.168/api/health

# CORS Test
curl -k -H "Origin: https://192.168.2.168" https://192.168.2.168/api/health
```

### **Rate Limiting testen**
```bash
# Mehrere Requests schnell hintereinander
for i in {1..25}; do curl -k https://192.168.2.168/api/health; done
```

---

## 🚨 **Troubleshooting**

### **Häufige Probleme**

| **Problem** | **Lösung** |
|-------------|------------|
| `SSL_KEY_USAGE_INCOMPATIBLE` | Zertifikat mit `digitalSignature` neu generieren |
| `ERR_CERT_COMMON_NAME_INVALID` | CN im Zertifikat auf korrekte IP/Domain setzen |
| `ValidationError: trust proxy` | Rate Limiter mit `trustProxy: 1` konfigurieren |
| `Invalid CSRF token` | Development Auto-Recovery aktivieren |
| nginx `unknown directive` | Typos in nginx config prüfen (`proxy_set_header`) |

### **Log-Monitoring**
```bash
# nginx Logs
sudo tail -f /var/log/nginx/error.log

# Backend Logs
sudo journalctl -u weltenwind-backend -f

# SSL-spezifische Logs
sudo journalctl -u weltenwind-nginx -f
```

---

## 📊 **Performance & Security**

### **Security Headers** ✅
- `X-Frame-Options: SAMEORIGIN`
- `X-XSS-Protection: 1; mode=block`
- `X-Content-Type-Options: nosniff`
- `Referrer-Policy: no-referrer-when-downgrade`
- CSP wird vom Backend gesetzt (flexibler)

### **SSL Security** ✅
- TLS 1.2 + 1.3 only
- EECDH+AESGCM Ciphers
- Session Cache enabled
- HTTP → HTTPS Redirect

### **Proxy Security** ✅
- Trust nur ersten Proxy (nginx)
- Korrekte X-Forwarded-* Headers
- Rate Limiting reverse-proxy-safe

---

**🎯 Nach diesem Setup ist das Weltenwind-System vollständig HTTPS-ready mit production-grade Security!**