# 🔍 Log-Viewer - Weltenwind

**Professional System Log Monitoring & Analysis Tool**

---

## 🎯 **Zweck**

Der Log-Viewer ist ein webbasiertes Admin-Tool für Real-time System-Log-Monitoring und -Analyse. Er ermöglicht Administratoren, strukturierte Logs aus verschiedenen Quellen zu überwachen, zu filtern und zu analysieren.

---

## 🌐 **Zugang**

### **URL**: 
```
http://192.168.2.168:3000/log-viewer/
```

### **Authentifizierung**:
- ✅ **Admin-Login erforderlich**: Username + Password
- ✅ **Permission-basiert**: Benutzer müssen `system.logs` Permission haben
- ✅ **Session-persistent**: Login bleibt über Browser-Sessions bestehen
- ✅ **Auto-Logout**: Bei Token-Expiration automatische Umleitung zum Login

---

## 🏗️ **Architektur**

### **Frontend-Files**:
```
backend/tools/log-viewer/
├── index.html        # 🏠 Main UI - Login + Log Viewer Interface
├── log-viewer.css    # 🎨 Professional Dark Theme Styling
├── log-viewer.js     # ⚡ Interactive JavaScript Logic
└── README.md         # 📚 Diese Dokumentation
```

### **Backend-Integration**:
- **Static File Serving**: `/log-viewer/` → `express.static(tools/log-viewer)`
- **API-Integration**: JavaScript calls `/api/logs/*` für Daten
- **Security-Headers**: CSP, XSS-Protection, Cache-Control

### **API-Endpunkte**:
- `POST /api/auth/login` → User-Authentifizierung
- `GET /api/logs/categories` → Verfügbare Log-Kategorien
- `GET /api/logs/data` → Log-Inhalte mit Filtering
- `GET /api/logs/stats` → System-Log-Statistiken

---

## 🔧 **Features**

### **📂 Multi-Source Log Support**:
- ✅ **Winston Logs**: Strukturierte JSON-Logs (app.log, auth.log, security.log, etc.)
- ✅ **System Logs**: Linux-System-Logs (/var/log/*)
- ✅ **Service Logs**: systemd-Service-Logs (Development/Production)

### **🎛️ Interactive Controls**:
- ✅ **Category-Dropdown**: Winston, Services, System
- ✅ **File-Dropdown**: Dynamisch basierend auf verfügbaren Logs
- ✅ **Line-Count-Selector**: 100, 500, 1000 Zeilen
- ✅ **Real-time Filter**: Live-Suche in Log-Inhalten
- ✅ **Auto-Refresh**: 5-Sekunden-Intervall für Live-Monitoring

### **🎨 Professional UI**:
- ✅ **Dark Theme**: Augenfreundliche dunkle Oberfläche
- ✅ **Color-Coded Log Levels**: INFO (Green), WARN (Orange), ERROR (Red)
- ✅ **Structured Display**: Timestamp, Module, Username, IP, Message
- ✅ **Metadata Expansion**: JSON-Metadata mit Pretty-Print
- ✅ **Auto-Scroll**: Neueste Logs immer sichtbar

### **🔐 Security Features**:
- ✅ **JWT-Token-basierte Authentifizierung**
- ✅ **LocalStorage Session-Persistence**
- ✅ **Permission-Level Authorization** (`system.logs`)
- ✅ **CSP-Headers**: Content Security Policy Protection
- ✅ **XSS-Protection**: X-XSS-Protection Headers
- ✅ **No-Cache**: Sensible Log-Daten werden nicht gecacht

---

## 🚀 **Usage Workflow**

### **1. 🔐 Login**:
```
1. Navigate to /log-viewer/
2. Enter Admin-Username + Password
3. System validates credentials + permissions
4. Token saved in LocalStorage for persistence
```

### **2. 📂 Log-Category Selection**:
```
1. System loads available categories from backend
2. Select category: Winston, Services, oder System
3. File-Dropdown updates with available log files
4. Auto-load initial logs
```

### **3. 🔍 Log Analysis**:
```
1. Use Filter-Input for real-time search
2. Adjust line-count for more/less history
3. Enable Auto-Refresh for live monitoring
4. Click entries to expand metadata
```

### **4. 📊 Advanced Features**:
```
1. Multi-category switching ohne re-login
2. Real-time filtering across all loaded logs
3. Manual refresh for specific snapshots
4. Auto-logout on session expiration
```

---

## 🛠️ **Development**

### **Local Development**:
```bash
# Files are automatically served via express.static
# No build process required - direct file editing

# Test changes:
1. Edit HTML/CSS/JS files in tools/log-viewer/
2. Refresh browser (cache headers prevent caching)
3. Changes are immediately visible
```

### **Debugging**:
```javascript
// Browser Console debugging:
console.log('Access Token:', accessToken);
console.log('Available Categories:', availableCategories);

// Check localStorage:
localStorage.getItem('weltenwind_access_token');
localStorage.getItem('weltenwind_user');
```

### **API-Testing**:
```bash
# Test API endpoints directly:
curl -H "Authorization: Bearer <token>" http://192.168.2.168:3000/api/logs/categories
curl -H "Authorization: Bearer <token>" http://192.168.2.168:3000/api/logs/data?file=app.log&lines=100
```

---

## 🔧 **Configuration**

### **Log-Categories** (backend/src/routes/logs.ts):
```typescript
const logCategories = {
  winston: {
    'app.log': 'Main Application Log',
    'auth.log': 'Authentication Events',
    'security.log': 'Security Events',
    'api.log': 'API Requests',
    'error.log': 'Error Events'
  },
  services: {
    'weltenwind.service': 'Main Service Log',
    'nginx.service': 'Web Server Log'
  },
  system: {
    'syslog': 'System Log',
    'auth.log': 'System Authentication'
  }
};
```

### **Security-Headers** (backend/src/server.ts):
```javascript
res.setHeader('Content-Security-Policy', [
  "default-src 'self'",
  "script-src 'self' 'unsafe-inline'",
  "style-src 'self' 'unsafe-inline'",
  "connect-src 'self'"
].join('; '));
```

---

## 📊 **Performance & Monitoring**

### **Metrics**:
- **Load Time**: < 500ms für UI-Initialisierung
- **Log-Fetch**: < 2s für 1000 Zeilen
- **Filter-Response**: < 100ms für Live-Suche
- **Memory Usage**: ~5MB für 1000 Log-Einträge

### **Optimization**:
- ✅ **Client-side Filtering**: Keine Server-Round-trips für Suche
- ✅ **Lazy Loading**: Nur angeforderte Zeilen-Anzahl
- ✅ **Connection Reuse**: Persistent HTTP-Connections
- ✅ **LocalStorage Caching**: Token-basierte Session-Persistence

---

## 🚨 **Troubleshooting**

### **Common Issues**:

#### **Login Fails**:
```javascript
// Check:
1. User has 'system.logs' permission in database
2. JWT_SECRET is configured correctly
3. Backend server is running on correct port
4. Network connectivity to backend
```

#### **No Logs Visible**:
```javascript
// Check:
1. Log files exist in configured directories
2. File permissions allow reading
3. Log categories are configured correctly
4. API endpoints return valid data
```

#### **Performance Issues**:
```javascript
// Solutions:
1. Reduce line-count (use 100 instead of 1000)
2. Disable auto-refresh if not needed
3. Use specific filters to reduce data
4. Clear browser cache/localStorage
```

---

## 🔮 **Future Enhancements**

### **Planned Features**:
1. **Export-Functionality**: Download filtered logs as CSV/JSON
2. **Advanced Filtering**: Regex-support, date-range-filtering
3. **Log-Aggregation**: Multi-file search across categories
4. **Real-time Notifications**: Alert on ERROR-level events
5. **Dashboard-Integration**: Embed in main admin dashboard

### **Technical Improvements**:
1. **WebSocket-Integration**: Real-time log streaming
2. **Infinite Scrolling**: Load older logs on demand
3. **Client-side Storage**: IndexedDB for offline access
4. **Mobile-Responsive**: Touch-optimized interface
5. **Theming Support**: Light/Dark theme toggle

---

**Status**: 🚀 Production Ready  
**Last Updated**: Januar 2025  
**Migration**: Erfolgreich von embedded HTML-Route zu Static File Architecture  
**URL**: http://192.168.2.168:3000/log-viewer/