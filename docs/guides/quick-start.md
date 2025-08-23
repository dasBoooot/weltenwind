# 🚀 Weltenwind - Quick Start Guide

**Willkommen bei Weltenwind!** Diese Anleitung bringt dich in wenigen Minuten von Zero zu Hero - egal ob du Entwickler, Administrator oder neugieriger Benutzer bist.

---

## 👨‍💻 **Für Entwickler**

### **Schritt 1: Repository klonen**
```bash
git clone https://github.com/dasBoooot/weltenwind.git
cd weltenwind
```

### **Schritt 2: Backend Setup** 
```bash
cd backend

# Dependencies installieren
npm install

# Environment Variables konfigurieren
cp .env.example .env
# Editiere .env mit deinen Datenbank-Credentials

# Datenbank Setup
npx prisma migrate dev
npx prisma db seed

# Backend starten
npm run dev
```
**Backend läuft auf**: `http://localhost:3000`

### **Schritt 3: Frontend Setup**
```bash
cd ../client

# Flutter Dependencies
flutter pub get

# Localization generieren  
flutter gen-l10n

# Frontend starten
flutter run -d chrome --web-port 8080
```
**Frontend läuft auf**: `http://localhost:8080`

### **Schritt 4: Erste Schritte**
1. **Öffne Browser**: `http://localhost:8080`
2. **Registriere Account**: Klicke auf "Registrieren"
3. **Erkunde Welten**: Gehe zu World List
4. **API testen**: Besuche `http://localhost:3000/api/docs` für Swagger

**🎉 Fertig! Du hast Weltenwind lokal am Laufen!**

---

## 🖥️ **Für Administratoren**

### **System-Requirements**
- **Node.js**: 18.x oder höher
- **PostgreSQL**: 14.x oder höher  
- **Flutter**: 3.x oder höher (für Builds)
- **RAM**: Minimum 4GB, empfohlen 8GB
- **Storage**: Minimum 5GB freier Speicher

### **Production Deployment**

#### **1. Backend-Server Setup**
```bash
# Production Build
npm run build

# Process Manager (PM2)
npm install -g pm2
pm2 start dist/index.js --name "weltenwind-backend"

# Nginx Reverse Proxy
# Konfiguration siehe: docs/backend/infrastructure/ssl-nginx-setup.md
```

#### **2. Frontend Build & Deploy**
```bash
# Production Web Build
flutter build web --base-href /game/

# Deploy zu Web-Server (Nginx/Apache)
cp -r build/web/* /var/www/weltenwind/
```

#### **3. Datenbank Setup**
```sql
-- PostgreSQL Database erstellen
CREATE DATABASE weltenwind;
CREATE USER weltenwind_user WITH PASSWORD 'secure_password';
GRANT ALL PRIVILEGES ON DATABASE weltenwind TO weltenwind_user;
```

### **Monitoring & Logs**
```bash
# Backend Logs
pm2 logs weltenwind-backend

# System Health Check
curl http://localhost:3000/api/health

# Database Status
psql -U weltenwind_user -d weltenwind -c "\\dt"
```

---

## 🎮 **Für Benutzer**

### **Account erstellen**
1. **Besuche Weltenwind**: [Deine Weltenwind URL]
2. **Klicke "Registrieren"**: Oben rechts
3. **Fülle das Formular aus**:
   - Username (einzigartig)
   - Email (für Einladungen)
   - Sicheres Passwort
4. **Bestätige Registration**: Check deine Email

### **Erste Welt beitreten**
1. **Welt-Liste öffnen**: Navigation → "Welten"
2. **Welt auswählen**: Klicke auf interessante Welt
3. **Beitreten**: "Der Welt beitreten" Button
4. **Loslegen**: Du bist jetzt Teil der Welt!

### **Freunde einladen**
1. **Welt öffnen**: Gehe zu einer Welt wo du Mitglied bist
2. **Einladung erstellen**: "Freunde einladen" Button
3. **Email eingeben**: Email-Adresse deines Freundes
4. **Senden**: Dein Freund bekommt eine persönliche Einladung

### **Einladung erhalten?**
1. **Email öffnen**: Check deine Inbox
2. **Link klicken**: "Zur Einladung" in der Email
3. **Account erstellen**: Falls noch nicht registriert
4. **Einladung annehmen**: "Einladung annehmen" Button
5. **Willkommen**: Du bist jetzt Teil der Welt!

---

## 🆘 **Probleme lösen**

### **Backend startet nicht**
```bash
# Port bereits in Verwendung?
netstat -tlnp | grep :3000

# Dependencies aktuell?
npm install

# Datenbank erreichbar?
psql -U weltenwind_user -d weltenwind -c "SELECT 1;"
```

### **Frontend lädt nicht**
```bash
# Flutter Dependencies OK?
flutter doctor

# Port bereits in Verwendung?
netstat -tlnp | grep :8080

# Localization generiert?
flutter gen-l10n
```

### **API-Fehler**
```bash
# Backend läuft?
curl http://localhost:3000/api/health

# Swagger-Docs verfügbar?
curl http://localhost:3000/api/docs

# Logs checken
pm2 logs weltenwind-backend
```

---

## 📚 **Nächste Schritte**

### **Als Entwickler**  
- 📖 [Frontend-Architektur](../frontend/README.md) verstehen
- 🔧 [API-Referenz](../api/README.md) studieren  
- 🎨 [Theme-System](../frontend/THEME_SYSTEM.md) erkunden
  

### **Als Administrator**  
- 🚀 [Production Deployment](../backend/operations/production-updates.md)
- 🔐 [API Security](../backend/security/api-security.md)
- 📊 [Logging & Monitoring](../backend/infrastructure/logging-implementation.md)

### **Als Benutzer**
- 🎮 [User-Guide](user-guide.md) für erweiterte Features
- 🌍 [Welt-Management](user-guide.md#worlds) lernen
- 👥 [Community-Features](user-guide.md#community) entdecken
- 🎨 [Personalisierung](user-guide.md#customization) anpassen

---

## 💡 **Tipps & Tricks**

### **Development Workflow**
- **Hot Reload nutzen**: Änderungen sind sofort sichtbar
- **Flutter Inspector**: Für UI-Debugging öffnen
- **API-Docs verwenden**: Swagger unter `/api/docs`
- **Logs verfolgen**: Sowohl Backend als auch Frontend

### **Performance-Tipps**
- **Development Mode**: Nur für Entwicklung, nicht Production
- **Database Indexing**: Für bessere API-Performance
- **Image Optimization**: Komprimierte Assets verwenden
- **Caching nutzen**: Browser- und Service-Caching aktivieren

### **Security-Basics**
- **Starke Passwörter**: Für alle Accounts
- **HTTPS verwenden**: In Production immer
- **Updates einspielen**: Regelmäßig Dependencies updaten
- **Backups machen**: Datenbank regelmäßig sichern

---

**🎉 Welcome to Weltenwind! Ready to explore infinite worlds?**

**Erstellt**: Januar 2025  
**Version**: 1.0  
**Support**: [GitHub Issues](https://github.com/dasBoooot/weltenwind/issues)