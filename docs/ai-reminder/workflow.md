# ⚡ Workflow-Regeln - Weltenwind

**Wie wir als Team zusammenarbeiten**

---

## 🤝 **Allgemeine Zusammenarbeits-Regeln**

### **1. 🗣️ Kommunikation auf Deutsch**

**Der User bevorzugt, dass der Assistant nur auf Deutsch kommuniziert.**

- ✅ **Alle Nachrichten**: Auf Deutsch
- ✅ **Code-Kommentare**: Auf Deutsch (außer technische APIs)
- ✅ **Dokumentation**: Auf Deutsch
- ✅ **Error-Messages für User**: AppLocalizations (DE/EN)
- ❌ **Logging/Console**: Englisch ist OK (technische Logs)

### **2. 🛑 Niemals unprompted Code-Änderungen**

**User verbietet explizit, dass der Assistant niemals Code-Änderungen oder Features unprompted hinzufügt.**

- ✅ **Nur implementieren** wenn explizit angefragt
- ✅ **Fragen stellen** bevor große Änderungen
- ✅ **Ein Widget nach dem anderen** und auf Review warten
- ❌ **Keine proaktiven Features** oder "Verbesserungen"

### **3. 📝 Gründlichkeit vor Geschwindigkeit**

**Gründliche, sorgfältige Arbeit hat Vorrang vor Geschwindigkeit.**

- ✅ **Minimale, präzise Änderungen** sind besser als komplette Neuschreibungen
- ✅ **Immer fragen** bevor etwas komplett neu gebaut wird
- ✅ **Schritt-für-Schritt verifizieren** dass Änderungen funktionieren
- ❌ **Niemals "sollte funktionieren"** → immer testen und bestätigen

---

## 🔄 **Development Workflow**

### **1. 📋 Vor jeder Code-Änderung**

**Systematische Vorbereitung:**

```
1. ✅ Relevante AI-Reminder Regeln checken
2. ✅ Bestehenden Code analysieren  
3. ✅ Architektur-Patterns verstehen
4. ✅ Minimale Änderung planen
5. ✅ Bei Unsicherheit: User fragen
```

### **2. 🛠️ Während der Implementierung**

**Qualitäts-Standards befolgen:**

```
1. ✅ Entwicklungsregeln befolgen (keine hardcoded UI-Texte, etc.)
2. ✅ System-Architektur-Prinzipien einhalten
3. ✅ Defensive Programming (Error Handling, Null Safety)
4. ✅ AppLogger statt print() für Logging
5. ✅ Cross-Platform Compatibility beachten
```

### **3. ✅ Nach der Implementierung**

**Systematische Verifikation:**

```bash
# 1. ✅ Code-Qualität prüfen:
flutter analyze

# 2. ✅ Build-Test:
flutter build web --base-href /game/

# 3. ✅ API-Dokumentation aktualisiert (falls nötig):
cd docs/openapi && node generate-openapi.js

# 4. ✅ Functionality testen:
# Manuelle Tests der geänderten Features

# 5. ✅ User informieren was genau geändert wurde
```

---

## 🧪 **Testing-Prinzipien**

### **1. 🎯 Manuelle Tests priorisieren**

**User bevorzugt manuelle Tests über automatisierte Tests.**

- ✅ **Funktionalität manuell testen** nach jeder Änderung
- ✅ **Cross-Platform testen** (verschiedene Browser/Devices)
- ✅ **Edge Cases prüfen** (Error States, Empty Data, etc.)
- ✅ **Performance beobachten** (Loading Times, Responsiveness)

### **2. 📱 Cross-Platform Testing**

**Code muss auf iOS und Android gleichwertig funktionieren.**

- ✅ **Web-Browser**: Chrome, Firefox, Safari
- ✅ **Mobile**: iOS Safari, Android Chrome
- ✅ **Responsive Design**: Verschiedene Bildschirmgrößen
- ❌ **Web-spezifische Lösungen** vermeiden

### **3. 🔍 Integration Testing**

**End-to-End Workflows testen:**

- ✅ **User-Journey**: Registration → Login → World Join → Gameplay
- ✅ **API-Integration**: Frontend ↔ Backend Communication
- ✅ **Theme-System**: Verschiedene Welten und Themes
- ✅ **Auth-Flow**: Login, Logout, Session Management

---

## 📚 **Code-Review Prinzipien**

### **1. 🎯 Selbst-Review vor User-Review**

**Bevor Code dem User präsentiert wird:**

```
1. ✅ AI-Reminder Regeln alle befolgt?
2. ✅ flutter analyze ohne Errors?
3. ✅ Alle hardcoded UI-Texte durch ARB-Keys ersetzt?
4. ✅ AppScaffold und Smart Navigation korrekt verwendet?
5. ✅ Error Handling implementiert?
6. ✅ Cross-Platform Compatibility geprüft?
```

### **2. 📝 Änderungen klar kommunizieren**

**User informieren was genau geändert wurde:**

```
✅ Klare Beschreibung: "Ich habe X geändert weil Y"
✅ Code-Beispiele: Vorher/Nachher Vergleiche zeigen
✅ Testing-Ergebnisse: "Ich habe Z getestet und es funktioniert"
✅ Potential Issues: "Beachte, dass A noch getestet werden sollte"

❌ Vage Aussagen: "Das sollte jetzt funktionieren"
❌ Feature-Creep: Unangefragte zusätzliche Features
```

### **3. 🔄 Iterative Verbesserung**

**Feedback konstruktiv annehmen:**

- ✅ **User-Feedback ernst nehmen** und umsetzen
- ✅ **Nachfragen bei Unklarheiten** statt raten
- ✅ **Schrittweise verfeinern** statt komplett neu machen
- ✅ **Lessons learned** in AI-Reminder Regeln aufnehmen

---

## 🚀 **Deployment Workflow**

### **1. 📦 Build-Prozess**

**Systematischer Build-Workflow:**

```bash
# 1. ✅ Code-Qualität prüfen:
flutter analyze

# 2. ✅ Localization updaten:
flutter gen-l10n

# 3. ✅ Production Build:
flutter build web --base-href /game/

# 4. ✅ API-Dokumentation generieren:
cd docs/openapi && node generate-openapi.js

# 5. ✅ Deployment-spezifische Tests
```

### **2. 🔧 Environment-Management**

**Verschiedene Umgebungen korrekt konfigurieren:**

```dart
// ✅ Development:
final apiUrl = 'http://192.168.2.168:3000/api';  // Server IP!

// ✅ Production:  
final apiUrl = 'https://api.weltenwind.com/api';

// ❌ NIEMALS localhost in Production:
// final apiUrl = 'http://localhost:3000/api';
```

### **3. 🔒 Security-Workflow**

**Security-relevante Deployments:**

- ✅ **API-Keys**: Nie in Code commiten
- ✅ **Environment Variables**: Für sensitive Daten
- ✅ **HTTPS**: In Production immer verwenden
- ✅ **CORS**: Korrekt konfiguriert für Frontend-Domains

---

## 📊 **Monitoring & Maintenance**

### **1. 📈 Performance Monitoring**

**Regelmäßige Performance-Checks:**

- ✅ **Loading Times**: Theme-Switch, Page-Navigation
- ✅ **Memory Usage**: Besonders bei Theme-Caching  
- ✅ **Bundle Size**: Flutter Web Bundle-Größe
- ✅ **API Response Times**: Backend-Performance

### **2. 🔄 Kontinuierliche Verbesserung**

**Lessons Learned systematisch aufnehmen:**

- ✅ **Häufige Bugs** → Neue Entwicklungsregeln
- ✅ **Performance-Issues** → Neue Architektur-Prinzipien
- ✅ **User-Feedback** → Workflow-Verbesserungen
- ✅ **Neue Technologien** → Evaluation und Integration

### **3. 📚 Dokumentations-Updates**

**AI-Reminder Regeln aktuell halten:**

- ✅ **Neue Erkenntnisse**: Wichtige Lessons in Regeln aufnehmen
- ✅ **Architektur-Änderungen**: System-Architektur-Dokument updaten
- ✅ **Tool-Updates**: Workflow an neue Tools anpassen
- ✅ **Team-Feedback**: Workflow-Regeln basierend auf Erfahrungen verfeinern

---

**Letztes Update**: Januar 2025  
**Status**: ⚡ Aktiver Workflow - Diese Regeln optimieren unsere Zusammenarbeit!