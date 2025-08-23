# 🛠️ Admin Tools - Weltenwind

**Zentrale Admin-Tools für System-Management und Content-Verwaltung**

---

## 📁 **Tools-Übersicht**

### **🌐 ARB-Editor** (`/arb-editor/`)
**Localization Management Tool**

- **Zweck**: Verwaltung von ARB-Dateien (App Resource Bundle) für Internationalisierung
- **URL**: `http://192.168.2.168:3000/arb-manager`
- **Features**:
  - ✅ **ARB-File Editor**: Bearbeitung von DE/EN Übersetzungen
  - ✅ **Key-Validation**: Überprüfung auf fehlende oder doppelte Keys
  - ✅ **Utility-Scripts**: `find-extra-keys.js`, `check-keys.js`
  - ✅ **Live-Preview**: Sofortige Vorschau der Übersetzungen

### **🎨 Theme-Editor** (`/theme-editor/`)
**Theme Management Tool**

- **Zweck**: Erstellung und Verwaltung von visuellen Themes für Welten
- **URL**: `http://192.168.2.168:3000/theme-editor`
- **Features**:
  - ✅ **Theme-Designer**: Visueller Theme-Editor mit Live-Preview
  - ✅ **Schema-Validation**: JSON-Schema basierte Theme-Validierung  
  - ✅ **Bundle-Management**: Theme-Bundle-Konfigurationen
  - ✅ **Modular Architecture**: Wiederverwendbare Theme-Komponenten

### **🔍 Log-Viewer** (`/log-viewer/`)
**System Log Monitoring Tool**

- **Zweck**: Real-time System-Log-Monitoring und -Analyse für Administratoren
- **URL**: `http://192.168.2.168:3000/log-viewer`
- **Features**:
  - ✅ **Multi-Source Logs**: Winston, System, Service-Logs
  - ✅ **Real-time Filtering**: Live-Suche und Auto-Refresh
  - ✅ **Professional UI**: Dark Theme mit Color-coded Log-Levels
  - ✅ **Secure Access**: JWT-basierte Authentifizierung mit Permissions

---

## 🏗️ **Architektur**

### **Server-Integration** (`backend/src/server.ts`):
```javascript
// ARB-Editor Static Files
app.use('/arb-manager', express.static('../tools/arb-editor'));

// Theme-Editor Static Files  
app.use('/theme-editor', express.static('../tools/theme-editor'));

// Log-Viewer Static Files
app.use('/log-viewer', express.static('../tools/log-viewer'));
```

### **API-Integration**:
- **ARB-API**: `/api/arb/*` → ARB-Content Management
- **Theme-API**: `/api/themes/*` → Theme-Data Management
- **Log-API**: `/api/logs/*` → System-Log-Data Management

### **File-Struktur**:
```
backend/tools/
├── arb-editor/              # 🌐 Localization Tool
│   ├── index.html           # Main UI
│   ├── arb.js               # Core Logic
│   ├── arb.css              # Styling
│   ├── find-extra-keys.js   # Utility: Find unused keys
│   ├── check-keys.js        # Utility: ARB validation
│   └── README.md            # Tool-specific docs
├── theme-editor/            # 🎨 Theme Management Tool
│   ├── index.html           # Main UI
│   ├── theme-editor.js      # Core Logic
│   ├── theme-editor.css     # Styling
│   ├── schemas/             # Theme JSON Schemas
│   ├── bundles/             # Theme Bundle Configs
│   └── schemas-modular-concept.md # Architecture docs
└── log-viewer/              # 🔍 System Log Monitoring Tool
    ├── index.html           # Main UI
    ├── log-viewer.js        # Core Logic
    ├── log-viewer.css       # Styling
    └── README.md            # Tool-specific docs
```

---

## 🔐 **Security & Access**

### **Access Control**:
- ✅ **Admin-Only**: Tools sind nur für Administratoren zugänglich
- ✅ **CSP-Headers**: Content Security Policy für XSS-Protection
- ✅ **Cache-Control**: No-Cache für sensible Admin-Daten
- ✅ **Frame-Protection**: X-Frame-Options gegen Clickjacking

### **Environment-based URLs**:
```javascript
// Development
const arbUrl = 'http://192.168.2.168:3000/arb-manager';
const themeUrl = 'http://192.168.2.168:3000/theme-editor';
const logUrl = 'http://192.168.2.168:3000/log-viewer';

// Production  
const arbUrl = 'https://admin.weltenwind.com/arb-manager';
const themeUrl = 'https://admin.weltenwind.com/theme-editor';
const logUrl = 'https://admin.weltenwind.com/log-viewer';
```

---

## 🚀 **Development Workflow**

### **Adding New Tools**:
1. **Create Tool Directory**: `backend/tools/new-tool/`
2. **Add Static Serving**: Update `server.ts` with new route
3. **Security Configuration**: Add CSP-Headers and Cache-Control
4. **API Integration**: Create corresponding API routes if needed
5. **Documentation**: Update this README with tool info

### **Tool Updates**:
1. **Development**: Make changes in tool directory
2. **Testing**: Test via `/tool-name` URL
3. **Cache-Busting**: Tools have no-cache headers for immediate updates
4. **Production**: Deploy entire `tools/` directory

### **Maintenance**:
- ✅ **Regular Updates**: Keep tool dependencies updated
- ✅ **Security Audits**: Review CSP-Headers and access controls
- ✅ **Performance**: Monitor tool loading times
- ✅ **Backup**: Include `tools/` in backup strategies

---

## 📊 **Usage Statistics & Monitoring**

### **Key Metrics**:
- **ARB-Editor**: Translation completion rates, key validation errors
- **Theme-Editor**: Active themes, bundle usage, validation failures

### **Health Checks**:
```bash
# Check if tools are accessible
curl http://192.168.2.168:3000/arb-manager
curl http://192.168.2.168:3000/theme-editor

# Check tool-specific files
curl http://192.168.2.168:3000/arb-manager/index.html
curl http://192.168.2.168:3000/theme-editor/index.html
```

---

## 🔧 **Troubleshooting**

### **Common Issues**:

#### **Tool Not Loading**:
```bash
# Check server configuration
grep -r "tools" backend/src/server.ts

# Verify file paths
ls -la backend/tools/
ls -la backend/tools/arb-editor/
ls -la backend/tools/theme-editor/
```

#### **Security Headers Blocking**:
- **CSP-Errors**: Check browser console for Content Security Policy violations
- **CORS-Issues**: Verify API-Calls are same-origin
- **Cache-Issues**: Tools have no-cache headers - check browser dev tools

#### **API-Integration Issues**:
```bash  
# Test API endpoints
curl http://192.168.2.168:3000/api/arb/languages
curl http://192.168.2.168:3000/api/themes
```

---

## 🎯 **Future Enhancements**

### **Planned Features**:
1. **User-Management-Tool**: Admin interface for user/world management
2. **Analytics-Dashboard**: System usage and performance metrics
3. **Backup-Manager**: Database and file backup management
4. **Log-Viewer**: Real-time system log monitoring
5. **API-Tester**: Interactive API testing interface

### **Architecture Improvements**:
- **Tool-Authentication**: Individual tool-based access controls
- **Tool-Versioning**: Version management for tool updates
- **Tool-APIs**: Standardized API interface for all tools
- **Tool-Theming**: Consistent UI theme across all admin tools

---

**Status**: 🚀 Production Ready  
**Last Updated**: Januar 2025  
**Maintainer**: Weltenwind Development Team