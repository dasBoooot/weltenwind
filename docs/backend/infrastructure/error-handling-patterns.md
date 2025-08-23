# Weltenwind Error-Handling Patterns

## 🎯 **Übersicht**

Nach der Console-Output-Migration haben wir einheitliche Error-Handling Patterns etabliert:

---

## 📊 **Pattern-Kategorien**

### 1. **🔐 Auth/Security Events**
```typescript
// ✅ DO: Strukturierte Security-Logs
loggers.auth.login(username, ip, false, { 
  reason: 'invalid_password',
  remainingAttempts: attemptResult.remainingAttempts,
  userAgent: req.headers['user-agent']
});

// ❌ DON'T: Nur console.warn
console.warn(`Login-Fail for ${username}`);
```

### 2. **🚀 System Events**
```typescript
// ✅ DO: Console für Live-Feedback + strukturierte Logs
console.log(`🚀 Weltenwind-API läuft auf Port ${PORT}`);
loggers.system.info('Weltenwind Backend started successfully', {
  port: PORT,
  nodeEnv: process.env.NODE_ENV,
  version: require('../package.json').version,
  endpoints: { /* ... */ }
});

// ❌ DON'T: Nur console ohne Struktur
console.log('Server started');
```

### 3. **💥 Error-Handling**
```typescript
// ✅ DO: Strukturierte Error-Logs mit Context
try {
  await riskyOperation();
} catch (error) {
  loggers.system.error('Operation failed', error, {
    userId: user.id,
    operation: 'specific_operation',
    ip: req.ip,
    userAgent: req.headers['user-agent']
  });
  return res.status(500).json({ error: 'Fehler aufgetreten' });
}

// ❌ DON'T: Nur console.error
catch (error) {
  console.error('Error:', error);
}
```

### 4. **🛡️ Security-kritische Warnungen**
```typescript
// ✅ DO: Console + strukturierte Logs für kritische Security-Events
console.error('❌ KRITISCHER FEHLER: JWT_SECRET ist nicht definiert!');
loggers.security.criticalError('JWT_SECRET missing', {
  environment: process.env.NODE_ENV,
  severity: 'critical'
});

// ✅ BEHALTEN: Für Live-Feedback bei kritischen Security-Problemen
```

---

## 🗂️ **Logger-Kategorien**

### **loggers.auth.**
- `login(username, ip, success, metadata)`
- `register(username, email, ip, metadata)`
- `logout(username, ip, metadata)`
- `passwordChange(username, ip, metadata)`

### **loggers.security.**
- `rateLimitHit(ip, endpoint, metadata)`
- `csrfTokenInvalid(username, ip, endpoint, metadata)`
- `accountLocked(username, ip, metadata)`
- `sessionRotation(username, ip, action, metadata)`

### **loggers.system.**
- `info(message, metadata)`
- `warn(message, metadata)`
- `error(message, error, metadata)`

### **loggers.api.**
- `request(method, url, ip, username, status, duration, metadata)`
- `error(method, url, ip, error, username, metadata)`

---

## 📜 **Verbleibende Console-Statements (begründet)**

### ✅ **SOLLEN bleiben (System-kritisch):**
- **server.ts**: Startup/Shutdown Messages für Live-Feedback
- **jwt.config.ts**: Security-kritische JWT-Warnungen

### ⚪ **KÖNNEN bleiben (weniger kritisch):**
- **session.service.ts**: Session-Security-Warnungen
- **session-rotation.service.ts**: Security-Debug-Info

---

## 🎯 **Neue Regeln für Entwickler**

### 1. **Console-Statements nur für:**
- ‼️ **System-kritische Startup/Shutdown Messages**
- ‼️ **Security-kritische Warnungen (JWT, etc.)**
- 🛠️ **Temporäres Debugging (vor Commit entfernen!)**

### 2. **Strukturierte Logs für:**
- 🔐 **Alle Auth/Security Events**
- 💥 **Alle Error-Handling Situations**
- 📊 **Business-Logic Events**
- 🔍 **Audit-Trail Events**

### 3. **Immer context-reiche Metadaten hinzufügen:**
```typescript
{
  userId: user.id,
  ip: req.ip,
  userAgent: req.headers['user-agent'],
  operation: 'specific_action',
  // ... weitere relevante Daten
}
```

---

## 🚀 **Nächste Schritte**

1. **Neue Features**: Direkt mit strukturierten Logs entwickeln
2. **Code Reviews**: Console-Statements hinterfragen
3. **Monitoring**: Log-Aggregation für Production erwägen
4. **Alerts**: Kritische Error-Patterns automatisch überwachen

---

*Erstellt: Juli 2025 | Weltenwind Backend Team*