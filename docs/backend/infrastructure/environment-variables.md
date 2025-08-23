# ⚙️ Environment Variables Configuration

**Komplette Übersicht aller Backend Environment Variables**

---

## 🎯 **Überblick**

Das Weltenwind Backend ist vollständig über Environment Variables konfigurierbar. Diese Dokumentation beschreibt alle verfügbaren Optionen und ihre Verwendung.

### **🔧 Template-Datei**
```bash
# Vollständiges Template verfügbar in:
backend/env-template.example
```

---

## 🌐 **URL & CORS Konfiguration**

### **URL-Struktur (SSL-Ready)**

```bash
# Backend Internal URLs (für Logs, Health-Checks, interne Calls)
BASE_URL="http://localhost:3000"

# Public/External URLs (für Clients über nginx)
PUBLIC_API_URL="https://192.168.2.168/api"      # API Endpoints
PUBLIC_CLIENT_URL="https://192.168.2.168"        # Frontend/Game
PUBLIC_ASSETS_URL="https://192.168.2.168"        # Static Assets

# CORS Configuration
ALLOWED_ORIGINS="https://192.168.2.168,http://localhost:8080,https://localhost:8080"
```

### **Dynamic URL Usage**
```typescript
// Verwendet in server.ts
console.log(`🎮 Flutter-Game verfügbar unter: ${PUBLIC_CLIENT_URL}/game`);
console.log(`🎨 Theme Editor verfügbar unter: ${PUBLIC_ASSETS_URL}/theme-editor/`);
console.log(`📘 Swagger verfügbar unter: ${PUBLIC_CLIENT_URL}/docs`);
```

---

## 🔐 **SSL & Security**

### **SSL Configuration**
```bash
SSL_ENABLED=true                          # Aktiviert SSL-Unterstützung
TRUST_PROXY=true                          # Nginx Reverse Proxy Trust (nur 1 Hop = SICHER)
```

### **JWT Configuration**
```bash
JWT_SECRET="your-super-secret-jwt-key-here-min-32-chars"
JWT_EXPIRES_IN=15m                        # Access Token Expiry
JWT_REFRESH_EXPIRES_IN=7d                 # Refresh Token Expiry
```

### **Session Management**
```bash
SESSION_SECRET="your-session-secret-here-min-32-chars"
ALLOW_MULTI_DEVICE_LOGIN=false
MAX_SESSIONS_PER_USER=1
```

### **Brute Force Protection**
```bash
MAX_LOGIN_ATTEMPTS=5
LOCKOUT_DURATION_MINUTES=15
```

### **CSRF Protection**
```bash
CSRF_AUTO_RECOVERY=true                   # Development: Auto-Recovery bei ungültigen Tokens
```

---

## ⚡ **Rate Limiting (SSL-Compatible)**

### **Authentication Rate Limits**
```bash
AUTH_RATE_LIMIT_WINDOW_MINUTES=5          # Login/Register: 5 Min Window
AUTH_RATE_LIMIT_MAX_REQUESTS=20           # Login/Register: Max 20 Requests
AUTH_SLOWDOWN_WINDOW_MINUTES=15           # Login SlowDown: 15 Min Window
```

### **API Rate Limits**
```bash
API_RATE_LIMIT_WINDOW_MINUTES=1           # General API: 1 Min Window
API_RATE_LIMIT_MAX_REQUESTS=100           # General API: Max 100 Requests
```

### **Password Reset Limits**
```bash
PASSWORD_RESET_WINDOW_HOURS=1             # Password Reset: 1 Hour Window
PASSWORD_RESET_MAX_REQUESTS=3             # Password Reset: Max 3 Requests
```

### **Registration Limits**
```bash
REGISTRATION_LIMIT_WINDOW_HOURS=24        # Registration: 24 Hours Window
REGISTRATION_LIMIT_MAX_REQUESTS=5         # Registration: Max 5 per IP
```

---

## 🧹 **Cleanup & Maintenance**

### **Session Cleanup**
```bash
SESSION_CLEANUP_INTERVAL_MINUTES=5
AUTO_CLEANUP_EXPIRED_SESSIONS=true
```

### **Invite Configuration**
```bash
INVITE_EXPIRY_DAYS=7                      # Invite-Tokens 7 Tage gültig
```

---

## 📊 **Logging & Monitoring**

### **Log Level & Rotation**
```bash
LOG_LEVEL=info                            # debug, info, warn, error
LOG_FILE_MAX_SIZE="10m"                   # Log file size (k/m/g suffix)
LOG_FILE_MAX_FILES=5                      # Max log files to keep
ERROR_LOG_MAX_FILES=10                    # Max error log files
```

### **Log File Parsing**
```typescript
// Automatisches Parsing von Log-Größen
const parseLogFileSize = (sizeStr: string): number => {
  const match = sizeStr.match(/^(\d+)([kmg]?)$/i);
  const size = parseInt(match[1], 10);
  const unit = (match[2] || '').toLowerCase();
  
  switch (unit) {
    case 'k': return size * 1024;
    case 'm': return size * 1024 * 1024;
    case 'g': return size * 1024 * 1024 * 1024;
    default: return size;
  }
};
```

---

## 💾 **Database Configuration**

```bash
DATABASE_URL="postgresql://username:password@localhost:5432/weltenwind"
```

---

## 📧 **Mail Service (Optional)**

```bash
MAIL_SERVICE_ENABLED=false
SMTP_HOST="smtp.gmail.com"
SMTP_PORT=587
MAIL_USER="your-email@gmail.com"
MAIL_PASS="your-app-password"
MAIL_FROM="\"Weltenwind\" <your-email@gmail.com>"
```

---

## 🎮 **Game & Features**

```bash
MAX_WORLDS_PER_USER=5
ENABLE_WORLD_THEMES=true
ENABLE_ARB_MANAGEMENT=true
```

---

## 🔧 **Development vs. Production**

### **Environment Detection**
```typescript
const isDevelopment = process.env.NODE_ENV !== 'production';

// Development-spezifische Features
if (isDevelopment) {
  // CSRF Auto-Recovery
  // Entspannte CORS-Rules
  // Zusätzliche Debug-Logs
}
```

### **Development Defaults**
```bash
NODE_ENV=development
PORT=3000
LOG_LEVEL=debug
LOG_FILE_MAX_SIZE="50m"
AUTH_RATE_LIMIT_MAX_REQUESTS=20           # Höher für Development
CSRF_AUTO_RECOVERY=true                   # Nur Development
```

### **Production Hardening**
```bash
NODE_ENV=production
LOG_LEVEL=info
LOG_FILE_MAX_SIZE="100m"
AUTH_RATE_LIMIT_MAX_REQUESTS=5            # Strenger für Production
CSRF_AUTO_RECOVERY=false                  # Security: Kein Auto-Recovery
SSL_ENABLED=true                          # Zwingend für Production
```

---

## 🧪 **Testing & Validation**

### **Environment Validation** 
```typescript
// JWT Secret Validation
if (secret.length < MIN_SECRET_LENGTH) {
  console.warn(`⚠️  JWT_SECRET ist zu kurz (${secret.length} Zeichen)`);
  console.warn(`   Empfohlen: Mindestens ${MIN_SECRET_LENGTH} Zeichen`);
}

// Production Checks
if (!isDevelopment && !process.env.SSL_ENABLED) {
  console.error('❌ SSL_ENABLED ist für Production erforderlich!');
}
```

### **Dynamic Value Testing**
```bash
# Test Rate Limiting Configuration
curl -X POST https://your-domain/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"username":"test","password":"wrong"}' \
  --repeat 25
```

---

## 📋 **Migration Checklist**

### **Von HTTP zu HTTPS**
- [ ] `SSL_ENABLED=true` setzen
- [ ] `TRUST_PROXY=true` aktivieren  
- [ ] `PUBLIC_*_URL` auf HTTPS umstellen
- [ ] `ALLOWED_ORIGINS` HTTPS-URLs hinzufügen
- [ ] `CSRF_AUTO_RECOVERY=true` für sanfte Migration
- [ ] Rate Limiting mit `trustProxy: 1` testen
- [ ] Flutter App mit HTTPS URLs neu builden

### **Production Deployment**
- [ ] Alle Secrets generieren (`JWT_SECRET`, `SESSION_SECRET`)
- [ ] Database URL konfigurieren
- [ ] Mail Service einrichten
- [ ] Log Rotation einrichten
- [ ] Rate Limits produktionsgerecht setzen
- [ ] `CSRF_AUTO_RECOVERY=false` für Production
- [ ] Health Checks einrichten

---

## 🚨 **Security Best Practices**

### **Secrets Management**
```bash
# Sichere Secret-Generierung
JWT_SECRET=$(openssl rand -base64 64)
SESSION_SECRET=$(openssl rand -hex 64)
```

### **Production Security**
- ✅ **SSL/TLS** zwingend aktiviert
- ✅ **Trust Proxy** nur auf 1 gesetzt (nginx)
- ✅ **Rate Limiting** production-ready
- ✅ **CORS** restriktiv konfiguriert
- ✅ **Secrets** mindestens 256-bit
- ✅ **Log Level** nicht auf debug
- ✅ **CSRF Recovery** deaktiviert

---

**🎯 Mit dieser Environment-Konfiguration ist das Weltenwind Backend vollständig produktionstauglich und sicher!**